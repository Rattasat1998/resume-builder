import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Get the current authenticated user
  AppUser? get currentUser;

  /// Stream of authentication state changes
  Stream<AppUser?> get authStateChanges;

  /// Sign up with email and password
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    String? fullName,
  });

  /// Sign in with email and password
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<Result<void>> signOut();

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<Result<AppUser>> updateProfile({String? fullName, String? avatarUrl});

  /// Delete user account
  Future<Result<void>> deleteAccount();

  /// Check if user is signed in
  bool get isSignedIn;

  /// Sign in with Google
  Future<Result<AppUser>> signInWithGoogle();

  /// Update subscription status
  Future<Result<void>> updateSubscriptionStatus({
    required String tier,
    DateTime? expiryDate,
  });
}
