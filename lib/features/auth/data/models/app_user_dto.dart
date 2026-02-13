import '../../domain/entities/app_user.dart';

/// Data Transfer Object for AppUser
class AppUserDto {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  const AppUserDto({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Create from Supabase User and profile data
  factory AppUserDto.fromSupabase(Map<String, dynamic> data) {
    return AppUserDto(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to domain entity
  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }

  /// Convert from domain entity
  factory AppUserDto.fromEntity(AppUser user) {
    return AppUserDto(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    );
  }

  factory AppUserDto.fromJson(Map<String, dynamic> json) {
    return AppUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
