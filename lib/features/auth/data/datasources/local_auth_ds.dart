import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../../../core/utils/uid.dart';
import '../models/app_user_dto.dart';
import 'auth_remote_ds.dart';

/// Implementation of AuthRemoteDataSource for Offline/Local mode
class LocalAuthDataSourceImpl implements AuthRemoteDataSource {
  final KeyValueStore _keyValueStore;

  static const String _userKey = 'local_user_profile';

  // Stream controller to broadcast auth changes
  final _authController = StreamController<AppUserDto?>.broadcast();

  LocalAuthDataSourceImpl(this._keyValueStore);

  @override
  AppUserDto? get currentUser {
    // We check if we have a stored user profile
    // Note: Since this is synchronous in interface but KeyValueStore is async,
    // this might be tricky if we strictly follow the interface.
    // However, for the simple "am I logged in" check, we can rely on
    // the fact that we will load it async or just return null if not loaded yet.
    // BUT, the interface says `AppUserDto? get currentUser`.
    // We can't make it async here without changing interface.
    //
    // Workaround: We might need to cache it in memory after initialization.
    // For now, let's assume if there is a way to get it sync, or we accept null initially.
    //
    // Actually, `Supabase.auth.currentUser` is sync. SharedPreferences is sync for reading
    // (after initial load). But our KeyValueStore wrapper is async.
    //
    // Let's modify the interface if needed, or cheat by storing in a static/instance variable
    // after sign in.
    return _cachedUser;
  }

  AppUserDto? _cachedUser;

  /// Call this during app initialization to load the user
  Future<void> init() async {
    final json = await _keyValueStore.getJson(_userKey);
    if (json != null) {
      _cachedUser = AppUserDto.fromJson(json);
      _authController.add(_cachedUser);
    }
  }

  @override
  Stream<AppUserDto?> get authStateChanges => _authController.stream;

  @override
  bool get isSignedIn => _cachedUser != null;

  @override
  Future<AppUserDto> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    // Mock sign up - just create a local user
    final user = AppUserDto(
      id: Uid.generate(),
      email: email,
      fullName: fullName ?? email.split('@').first,
      avatarUrl: null,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  @override
  Future<AppUserDto> signIn({
    required String email,
    required String password,
  }) async {
    // Mock sign in - allow any credentials for now, or check against stored?
    // For offline mode, maybe we just create a session if one doesn't exist?
    // Or if we want to simulate a "cloud" account locally:

    // Simplification: If a user exists, return it. If not, create new one.
    // In a real offline transition, we might just migrate the existing user.

    var user = _cachedUser;
    if (user == null) {
      // Check storage again
      final json = await _keyValueStore.getJson(_userKey);
      if (json != null) {
        user = AppUserDto.fromJson(json);
      }
    }

    if (user != null) {
      // Update email if different? No, let's just use the stored one.
      _cachedUser = user;
      _authController.add(user);
      return user;
    }

    // Treat as new user if none found
    return signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _keyValueStore.remove(_userKey);
    _cachedUser = null;
    _authController.add(null);
  }

  @override
  Future<AppUserDto> signInWithGoogle() async {
    // Mock Google Sign In
    final user = AppUserDto(
      id: Uid.generate(),
      email: 'user@example.com',
      fullName: 'Offline User',
      avatarUrl: null,
      createdAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // No-op
    return;
  }

  @override
  Future<AppUserDto> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final currentUser = _cachedUser;
    if (currentUser == null)
      throw const ServerException(message: 'Not signed in');

    final updatedUser = AppUserDto(
      id: currentUser.id,
      email: currentUser.email,
      fullName: fullName ?? currentUser.fullName,
      avatarUrl: avatarUrl ?? currentUser.avatarUrl,
      createdAt: currentUser.createdAt,
    );

    await _saveUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<void> updateSubscriptionStatus({
    required String tier,
    DateTime? expiryDate,
  }) async {
    // No-op for local auth, we handle subscription in LocalSubscriptionRepository
    // But we can store it in user profile if we want compatibility
    return;
  }

  @override
  Future<void> deleteAccount() async {
    await signOut();
  }

  Future<void> _saveUser(AppUserDto user) async {
    _cachedUser = user;
    await _keyValueStore.setJson(_userKey, user.toJson());
    _authController.add(user);
  }
}
