import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/error/exceptions.dart';
import '../models/app_user_dto.dart';

/// Remote data source for authentication using Supabase
abstract class AuthRemoteDataSource {
  /// Get the current authenticated user
  AppUserDto? get currentUser;

  /// Stream of authentication state changes
  Stream<AppUserDto?> get authStateChanges;

  /// Sign up with email and password
  Future<AppUserDto> signUp({
    required String email,
    required String password,
    String? fullName,
  });

  /// Sign in with email and password
  Future<AppUserDto> signIn({required String email, required String password});

  /// Sign out the current user
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<AppUserDto> updateProfile({String? fullName, String? avatarUrl});

  /// Delete user account
  Future<void> deleteAccount();

  /// Check if user is signed in
  bool get isSignedIn;

  /// Verify email with OTP
  // Future<AppUserDto> verifyEmail({required String email, required String otp});

  /// Resend verification code
  // Future<void> resendVerification({required String email});

  /// Sign in with Google
  Future<AppUserDto> signInWithGoogle();

  /// Update subscription status
  Future<void> updateSubscriptionStatus({
    required String tier,
    DateTime? expiryDate,
  });
}

/// Implementation of AuthRemoteDataSource using Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  AppUserDto? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return AppUserDto(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  @override
  Stream<AppUserDto?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      // Try to get profile from database
      try {
        final profile = await _client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          return AppUserDto.fromSupabase(profile);
        }
      } catch (_) {
        // Profile table might not exist yet
      }

      return AppUserDto(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.parse(user.createdAt),
      );
    });
  }

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Future<AppUserDto> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      final user = response.user;
      final session = response.session;

      // If user exists but session is null, email confirmation is required
      if (user != null && session == null) {
        throw const ServerException(message: 'Auth: Verification Required');
      }

      if (user == null) {
        throw const ServerException(message: 'Sign up failed');
      }

      return AppUserDto(
        id: user.id,
        email: user.email ?? email,
        fullName: fullName,
        avatarUrl: null,
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppUserDto> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const ServerException(message: 'Sign in failed');
      }

      // Try to get profile from database
      try {
        final profile = await _client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          return AppUserDto.fromSupabase(profile);
        }
      } catch (_) {
        // Profile table might not exist yet
      }

      return AppUserDto(
        id: user.id,
        email: user.email ?? email,
        fullName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppUserDto> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      // Update auth metadata
      final metadata = <String, dynamic>{};
      if (fullName != null) metadata['full_name'] = fullName;
      if (avatarUrl != null) metadata['avatar_url'] = avatarUrl;

      if (metadata.isNotEmpty) {
        await _client.auth.updateUser(UserAttributes(data: metadata));
      }

      // Update profile table
      try {
        await _client.from('user_profiles').upsert({
          'id': user.id,
          'email': user.email,
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Profile table might not exist yet
      }

      return AppUserDto(
        id: user.id,
        email: user.email ?? '',
        fullName: fullName ?? user.userMetadata?['full_name'] as String?,
        avatarUrl: avatarUrl ?? user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      // Delete user data first
      try {
        await _client.from('resumes').delete().eq('user_id', user.id);
        await _client.from('user_profiles').delete().eq('id', user.id);
      } catch (_) {
        // Tables might not exist
      }

      // Note: Deleting auth user requires admin privileges
      // In production, use a server function
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppUserDto> signInWithGoogle() async {
    try {
      // Configure Google Sign In
      // TODO: Move these to a config file or environment variables
      // TODO: Replace with your Web Client ID (from Google Cloud Console)
      // NOTE: The 'AIza...' key is an API Key, NOT a Client ID. We need the one ending in .apps.googleusercontent.com
      const serverClientId =
          '267573453854-bk874vfd2oap3a133hvn3nall26sa16g.apps.googleusercontent.com';

      // On iOS, the Client ID is read from Info.plist (GIDClientID).
      // On Android without google-services.json, we rely on the plugin defaults or manual config.
      // But for Supabase, we specifically need the ID Token for the *Web* client.

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
      );

      // Force account picker -> allows user to select a different account
      await googleSignIn.signOut();

      // Attempt to sign in
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        throw const ServerException(message: 'Sign in canceled');
      }

      // 2. Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw const ServerException(message: 'No Access Token found.');
      }
      if (idToken == null) {
        throw const ServerException(message: 'No ID Token found.');
      }

      // 3. Create a new credential
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw const ServerException(message: 'Sign in failed');
      }

      // Try to get profile from database
      try {
        final profile = await _client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          return AppUserDto.fromSupabase(profile);
        }
      } catch (_) {}

      return AppUserDto(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      print('Google sign-in AuthException: ${e.message}');

      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e, t) {
      if (e is ServerException) rethrow;
      print('Google sign-in Exception2: ${e.toString()}');
      print('Google sign-in Exception2: ${t.toString()}');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateSubscriptionStatus({
    required String tier,
    DateTime? expiryDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      print(
        'DEBUG: AuthRemoteDataSource.updateSubscriptionStatus called. User: ${user?.id}',
      );
      if (user == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      print(
        'DEBUG: Upserting user_profile for ${user.id} with tier: $tier, expires: $expiryDate',
      );

      await _client.from('user_profiles').upsert({
        'id': user.id,
        'email': user.email,
        'subscription_tier': tier,
        'subscription_expires_at': expiryDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      print('DEBUG: Supabase Update Error: ${e.message} (Code: ${e.code})');
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      print('DEBUG: Supabase Update Unexpected Error: $e');
      throw ServerException(message: e.toString());
    }
  }
}
