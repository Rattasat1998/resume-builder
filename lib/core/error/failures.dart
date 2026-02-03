import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to server/API errors
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Failure related to local cache/storage errors
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Failure related to network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Failure related to validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure related to PDF export
class ExportFailure extends Failure {
  const ExportFailure({required super.message, super.code});
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

/// Failure related to authentication
class AuthFailure extends Failure {
  final AuthFailureType type;

  const AuthFailure({
    required super.message,
    super.code,
    this.type = AuthFailureType.unknown,
  });

  @override
  List<Object?> get props => [message, code, type];
}

/// Types of authentication failures
enum AuthFailureType {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  userNotFound,
  networkError,
  sessionExpired,
  emailVerificationRequired,
  unknown,
}

/// Unknown/unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}

/// Failure when a feature limit is reached
class LimitFailure extends Failure {
  const LimitFailure({required super.message, super.code});
}
