import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/services/storage_service.dart';
import 'package:logger/logger.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../models/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();

  AuthViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(AuthState.initial()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _logger.i('Auth state changed: User signed in - ${user.uid}');
        await _loadUserProfile(user);
      } else {
        _logger.i('Auth state changed: User signed out');
        state = AuthState.unauthenticated();
      }
    });
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      state = AuthState.loading();

      // Try to get user profile from Firestore
      UserProfile? userProfile =
          await _firestoreService.getUser(firebaseUser.uid);

      // If no profile exists, create one
      if (userProfile == null) {
        _logger.i(
            'No user profile found, creating new profile for: ${firebaseUser.uid}');

        userProfile = UserProfile(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Kullanıcı',
          photoUrl: firebaseUser.photoURL,
          isSubscriptionActive: false,
          subscriptionTier: 'free',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.createUser(firebaseUser.uid, userProfile);
      }

      state = AuthState.authenticated(
        firebaseUser: firebaseUser,
        userProfile: userProfile,
      );
    } catch (e) {
      _logger.e('Error loading user profile: $e');
      state = AuthState.error('Kullanıcı profili yüklenirken bir hata oluştu');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = AuthState.loading();

      final user =
          await _authService.signInWithEmailAndPassword(email, password);

      if (user == null) {
        state = AuthState.error('Giriş yapılamadı');
        return;
      }

      // Auth listener will handle the rest
    } catch (e) {
      _logger.e('Sign in error: $e');
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      state = AuthState.loading();

      final user = await _authService.createUserWithEmailAndPassword(
          email, password, name);

      if (user == null) {
        state = AuthState.error('Hesap oluşturulamadı');
        return;
      }

      // Auth listener will handle the rest
    } catch (e) {
      _logger.e('Sign up error: $e');
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = AuthState.loading();

      final user = await _authService.signInWithGoogle();

      if (user == null) {
        // User cancelled
        state = AuthState.unauthenticated();
        return;
      }

      // Auth listener will handle the rest
    } catch (e) {
      _logger.e('Google sign in error: $e');
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signOut() async {
    try {
      state = AuthState.loading();

      await _authService.signOut();

      // Auth listener will handle setting unauthenticated state
    } catch (e) {
      _logger.e('Sign out error: $e');
      state = AuthState.error('Çıkış yapılırken bir hata oluştu');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      _logger.i('Password reset email sent to: $email');
    } catch (e) {
      _logger.e('Password reset error: $e');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      if (state.firebaseUser == null || state.userProfile == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      state = state.copyWith(isLoading: true);

      // Update Firebase Auth profile
      await _authService.updateUserProfile(
        displayName: name,
        photoURL: photoUrl,
      );

      // Update Firestore profile
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await _firestoreService.updateUser(state.firebaseUser!.uid, updates);

        // Update local state
        final updatedProfile = state.userProfile!.copyWith(
          name: name ?? state.userProfile!.name,
          photoUrl: photoUrl ?? state.userProfile!.photoUrl,
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(
          userProfile: updatedProfile,
          isLoading: false,
        );
      }

      _logger.i('User profile updated successfully');
    } catch (e) {
      _logger.e('Update profile error: $e');
      state = state.copyWith(isLoading: false);
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (state.firebaseUser == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      state = AuthState.loading();

      // Delete Firestore data
      await _firestoreService.deleteUser(state.firebaseUser!.uid);

      // Delete Firebase Auth account
      await _authService.deleteAccount();

      _logger.i('User account deleted successfully');
    } catch (e) {
      _logger.e('Delete account error: $e');
      state = AuthState.error('Hesap silinirken bir hata oluştu');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    authService: ref.watch(authServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});
