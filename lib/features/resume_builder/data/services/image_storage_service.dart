import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart';

/// Service for uploading and managing images in Supabase Storage
class ImageStorageService {
  final SupabaseClient _client;

  /// Bucket name for storing resume images
  static const String _bucketName = 'resume-images';

  ImageStorageService(this._client);

  /// Check if storage is available
  bool get isAvailable => SupabaseConfig.isConfigured;

  /// Get the current user ID for organizing files
  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUserId != null;

  /// Get storage path with user folder for authenticated users
  /// Falls back to resumeId only for guest users
  String _getStoragePath(String resumeId, String filename) {
    final userId = _currentUserId;
    if (userId != null) {
      // Authenticated user: store in user folder
      return '$userId/$resumeId/$filename';
    } else {
      // Guest user: store in resume folder only (requires anonymous policies)
      return '$resumeId/$filename';
    }
  }

  /// Upload an image file and return the public URL
  ///
  /// [filePath] - Local file path of the image
  /// [resumeId] - Resume ID to organize images
  /// Returns the public URL of the uploaded image
  Future<String?> uploadImage(String filePath, String resumeId) async {
    if (!isAvailable) {
      print(
        'ImageStorageService: Storage not available (Supabase not configured)',
      );
      return null;
    }

    // Check authentication status
    final userId = _currentUserId;
    print(
      'ImageStorageService: Upload attempt - userId: $userId, resumeId: $resumeId',
    );

    if (userId == null) {
      print(
        'ImageStorageService: User not authenticated - attempting anonymous upload',
      );
      // Proceed with upload using guest path structure defined in _getStoragePath
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('ImageStorageService: File not found at $filePath');
        throw ServerException(message: 'Image file not found: $filePath');
      }

      // Generate unique filename
      final extension = path.extension(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'avatar_$timestamp$extension';
      final storagePath = _getStoragePath(resumeId, filename);

      print('ImageStorageService: Uploading to path: $storagePath');

      // Read file bytes
      final bytes = await file.readAsBytes();
      print('ImageStorageService: File size: ${bytes.length} bytes');

      // Upload to Supabase Storage
      await _client.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      print('ImageStorageService: Upload successful - URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('ImageStorageService: Failed to upload image: $e');
      return null;
    }
  }

  /// Upload image from bytes (for web or memory)
  Future<String?> uploadImageBytes(
    Uint8List bytes,
    String resumeId,
    String extension,
  ) async {
    if (!isAvailable) return null;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'avatar_$timestamp$extension';
      final storagePath = _getStoragePath(resumeId, filename);

      await _client.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: true,
            ),
          );

      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      print('Failed to upload image bytes: $e');
      return null;
    }
  }

  /// Delete an image from storage
  Future<bool> deleteImage(String imageUrl) async {
    if (!isAvailable || imageUrl.isEmpty) return false;

    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the path after 'resume-images/'
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        return false;
      }

      final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _client.storage.from(_bucketName).remove([storagePath]);

      return true;
    } catch (e) {
      print('Failed to delete image: $e');
      return false;
    }
  }

  /// Delete all images for a resume
  Future<bool> deleteResumeImages(String resumeId) async {
    if (!isAvailable) return false;

    try {
      final userId = _currentUserId;
      final folderPath = userId != null ? '$userId/$resumeId' : resumeId;

      // List all files in the resume folder
      final files = await _client.storage
          .from(_bucketName)
          .list(path: folderPath);

      if (files.isEmpty) return true;

      // Delete all files
      final paths = files.map((f) => '$folderPath/${f.name}').toList();
      await _client.storage.from(_bucketName).remove(paths);

      return true;
    } catch (e) {
      print('Failed to delete resume images: $e');
      return false;
    }
  }

  /// Delete all images for the current user
  Future<bool> deleteUserImages() async {
    if (!isAvailable || !isAuthenticated) return false;

    try {
      final userId = _currentUserId!;

      // List all files in user folder
      final files = await _client.storage.from(_bucketName).list(path: userId);

      if (files.isEmpty) return true;

      // Delete all files recursively
      for (final item in files) {
        if (item.id == null) {
          // It's a folder, delete contents
          final subFiles = await _client.storage
              .from(_bucketName)
              .list(path: '$userId/${item.name}');

          final subPaths = subFiles
              .where((f) => f.id != null)
              .map((f) => '$userId/${item.name}/${f.name}')
              .toList();

          if (subPaths.isNotEmpty) {
            await _client.storage.from(_bucketName).remove(subPaths);
          }
        } else {
          await _client.storage.from(_bucketName).remove([
            '$userId/${item.name}',
          ]);
        }
      }

      return true;
    } catch (e) {
      print('Failed to delete user images: $e');
      return false;
    }
  }

  /// Check if a URL is a Supabase storage URL
  static bool isSupabaseUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.contains('supabase') && url.contains('storage');
  }

  /// Check if a path is a local file path
  static bool isLocalPath(String? path) {
    if (path == null || path.isEmpty) return false;
    return !path.startsWith('http');
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
