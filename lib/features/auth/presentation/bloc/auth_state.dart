import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

/// Possible authentication states
enum AuthStatus {
  /// Initial state, checking auth status
  initial,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Authentication operation in progress
  loading,
}

/// State for authentication
class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;
  final bool passwordResetSent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.passwordResetSent = false,
  });

  /// Initial state
  const AuthState.initial() : this();

  /// Loading state
  const AuthState.loading() : this(status: AuthStatus.loading);

  /// Authenticated state
  AuthState.authenticated(AppUser user)
    : this(status: AuthStatus.authenticated, user: user);

  /// Unauthenticated state
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  /// Error state (stays on current screen)
  AuthState withError(String message) {
    return AuthState(
      status: status == AuthStatus.loading
          ? AuthStatus.unauthenticated
          : status,
      user: user,
      errorMessage: message,
      passwordResetSent: false,
    );
  }

  /// Password reset sent state
  AuthState withPasswordResetSent() {
    return AuthState(
      status: status,
      user: user,
      errorMessage: null,
      passwordResetSent: true,
    );
  }

  /// Clear error
  AuthState clearError() {
    return AuthState(
      status: status,
      user: user,
      errorMessage: null,
      passwordResetSent: passwordResetSent,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [status, user, errorMessage, passwordResetSent];
}
