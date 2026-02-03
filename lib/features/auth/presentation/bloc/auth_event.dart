import 'package:equatable/equatable.dart';

/// Base class for all auth events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

/// Sign out current user
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Send password reset email
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Update user profile
class AuthProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? avatarUrl;

  const AuthProfileUpdateRequested({this.fullName, this.avatarUrl});

  @override
  List<Object?> get props => [fullName, avatarUrl];
}

/// Sign in with Google
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Clear any error state
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
