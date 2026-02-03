/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception related to server/API errors
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

/// Exception related to local cache/storage errors
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Exception related to network connectivity
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception related to validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception related to PDF export
class ExportException extends AppException {
  const ExportException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ExportException: $message';
}

/// Exception when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

