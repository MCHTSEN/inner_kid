import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_profile.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? firebaseUser;
  final UserProfile? userProfile;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.firebaseUser,
    this.userProfile,
    this.errorMessage,
    this.isLoading = false,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      isLoading: false,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
      isLoading: true,
    );
  }

  factory AuthState.authenticated({
    required User firebaseUser,
    UserProfile? userProfile,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      firebaseUser: firebaseUser,
      userProfile: userProfile,
      isLoading: false,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: false,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
      isLoading: false,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    User? firebaseUser,
    UserProfile? userProfile,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, firebaseUser: ${firebaseUser?.uid}, userProfile: ${userProfile?.id}, errorMessage: $errorMessage, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.firebaseUser?.uid == firebaseUser?.uid &&
        other.userProfile?.id == userProfile?.id &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        firebaseUser.hashCode ^
        userProfile.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode;
  }
}
