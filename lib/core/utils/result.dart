import '../error/failures.dart';

/// A Result type that represents either a success value or a failure
/// Similar to Either from dartz or fpdart
sealed class Result<T> {
  const Result();

  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Error<T>;

  /// Gets the value if Success, otherwise returns null
  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Error() => null,
  };

  /// Gets the failure if Error, otherwise returns null
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Error(failure: final f) => f,
  };

  /// Maps the success value to a new value
  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
    Success(value: final v) => Success(mapper(v)),
    Error(failure: final f) => Error(f),
  };

  /// Maps the success value to a new Result
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) => switch (this) {
    Success(value: final v) => mapper(v),
    Error(failure: final f) => Error(f),
  };

  /// Folds the Result into a single value
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success(value: final v) => onSuccess(v),
        Error(failure: final f) => onFailure(f),
      };

  /// Gets the value or throws if Error
  T getOrThrow() => switch (this) {
    Success(value: final v) => v,
    Error(failure: final f) => throw Exception(f.message),
  };

  /// Gets the value or returns a default value
  T getOrElse(T defaultValue) => switch (this) {
    Success(value: final v) => v,
    Error() => defaultValue,
  };
}

/// Represents a successful result with a value
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result with a failure
final class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Error($failure)';
}

