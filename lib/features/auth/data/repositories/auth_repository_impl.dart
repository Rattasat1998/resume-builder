import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser?.toEntity();

  @override
  Stream<AppUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((dto) => dto?.toEntity());
  }

  @override
  bool get isSignedIn => _remoteDataSource.isSignedIn;

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final userDto = await _remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Error(_mapAuthException(e));
    } catch (e) {
      return Error(
        AuthFailure(message: e.toString(), type: AuthFailureType.unknown),
      );
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userDto = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Error(_mapAuthException(e));
    } catch (e) {
      return Error(
        AuthFailure(message: e.toString(), type: AuthFailureType.unknown),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Success(null);
    } on ServerException catch (e) {
      return Error(AuthFailure(message: e.message));
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(_mapAuthException(e));
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      final userDto = await _remoteDataSource.signInWithGoogle();
      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Error(_mapAuthException(e));
    } catch (e) {
      return Error(
        AuthFailure(message: e.toString(), type: AuthFailureType.unknown),
      );
    }
  }

  @override
  Future<Result<AppUser>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final userDto = await _remoteDataSource.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Error(AuthFailure(message: e.message));
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      return const Success(null);
    } on ServerException catch (e) {
      return Error(AuthFailure(message: e.message));
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateSubscriptionStatus({
    required String tier,
    DateTime? expiryDate,
  }) async {
    try {
      await _remoteDataSource.updateSubscriptionStatus(
        tier: tier,
        expiryDate: expiryDate,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Error(AuthFailure(message: e.message));
    } catch (e) {
      return Error(AuthFailure(message: e.toString()));
    }
  }

  /// Map server exceptions to auth failures
  AuthFailure _mapAuthException(ServerException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login') ||
        message.contains('invalid credentials') ||
        message.contains('wrong password')) {
      return AuthFailure(
        message: 'Invalid email or password',
        code: e.code,
        type: AuthFailureType.invalidCredentials,
      );
    }

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('duplicate')) {
      return AuthFailure(
        message: 'Email is already registered',
        code: e.code,
        type: AuthFailureType.emailAlreadyInUse,
      );
    }

    if (message.contains('weak password') ||
        message.contains('password should')) {
      return AuthFailure(
        message: 'Password is too weak. Use at least 6 characters.',
        code: e.code,
        type: AuthFailureType.weakPassword,
      );
    }

    if (message.contains('user not found') || message.contains('no user')) {
      return AuthFailure(
        message: 'User not found',
        code: e.code,
        type: AuthFailureType.userNotFound,
      );
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return AuthFailure(
        message: 'Network error. Please check your connection.',
        code: e.code,
        type: AuthFailureType.networkError,
      );
    }

    if (message.contains('session') || message.contains('expired')) {
      return AuthFailure(
        message: 'Session expired. Please sign in again.',
        code: e.code,
        type: AuthFailureType.sessionExpired,
      );
    }

    if (message.contains('verification required')) {
      return AuthFailure(
        message: 'Please verify your email to continue.',
        code: e.code,
        type: AuthFailureType.emailVerificationRequired,
      );
    }

    return AuthFailure(
      message: e.message,
      code: e.code,
      type: AuthFailureType.unknown,
    );
  }
}
