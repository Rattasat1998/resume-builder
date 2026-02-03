import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Check if user has completed their profile
  bool get hasCompletedProfile => fullName != null && fullName!.isNotEmpty;

  /// Get display name (full name or email prefix)
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return email.split('@').first;
  }

  /// Get initials for avatar
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl, createdAt];
}

