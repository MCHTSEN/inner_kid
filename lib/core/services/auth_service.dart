import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _logger.i('Attempting to sign in with email: $email');

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.i('Sign in successful for user: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      _logger.i('Attempting to create user with email: $email');

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      _logger.i('User created successfully: ${result.user?.uid}');
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during user creation: $e');
      throw Exception('An unexpected error occurred during account creation');
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      _logger.i('Attempting to sign in with Google');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('Google sign in was cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential result =
          await _auth.signInWithCredential(credential);

      _logger.i('Google sign in successful for user: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during Google sign in: $e');
      throw Exception('An unexpected error occurred during Google sign in');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i('Attempting to sign out');

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      _logger.i('Sign out successful');
    } catch (e) {
      _logger.e('Error during sign out: $e');
      throw Exception('An error occurred during sign out');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');

      await _auth.sendPasswordResetEmail(email: email);

      _logger.i('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during password reset: $e');
      throw Exception('An unexpected error occurred while sending reset email');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is currently signed in');

      _logger.i('Updating user profile for: ${user.uid}');

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await user.reload();

      _logger.i('User profile updated successfully');
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is currently signed in');

      _logger.i('Deleting user account: ${user.uid}');

      await user.delete();

      _logger.i('User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Error deleting user account: $e');
      throw Exception('Failed to delete user account');
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.');
      case 'wrong-password':
        return Exception('Hatalı şifre girdiniz.');
      case 'email-already-in-use':
        return Exception('Bu e-posta adresi zaten kullanımda.');
      case 'weak-password':
        return Exception('Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.');
      case 'invalid-email':
        return Exception('Geçersiz e-posta adresi.');
      case 'user-disabled':
        return Exception('Bu kullanıcı hesabı devre dışı bırakılmış.');
      case 'too-many-requests':
        return Exception(
            'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.');
      case 'network-request-failed':
        return Exception('İnternet bağlantınızı kontrol edin.');
      case 'invalid-credential':
        return Exception('Geçersiz giriş bilgileri.');
      case 'account-exists-with-different-credential':
        return Exception(
            'Bu e-posta adresi farklı bir giriş yöntemi ile kayıtlı.');
      case 'requires-recent-login':
        return Exception('Bu işlem için yeniden giriş yapmanız gerekiyor.');
      default:
        return Exception('Bir hata oluştu: ${e.message}');
    }
  }
}
