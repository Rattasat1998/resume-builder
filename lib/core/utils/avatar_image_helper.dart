import 'dart:io';

import 'package:flutter/material.dart';

/// Helper class for loading avatar images that can be either URLs or local file paths
class AvatarImageHelper {
  /// Get the appropriate ImageProvider based on the avatar path
  /// Returns null if the path is invalid or file doesn't exist
  static ImageProvider? getImageProvider(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return null;
    }

    // Check if it's a network URL
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return NetworkImage(avatarPath);
    }

    // It's a local file path
    final file = File(avatarPath);
    if (file.existsSync()) {
      return FileImage(file);
    }

    // File doesn't exist
    return null;
  }

  /// Get DecorationImage for use in Container decoration
  /// Returns null if the avatar path is invalid
  static DecorationImage? getDecorationImage(
    String? avatarPath, {
    BoxFit fit = BoxFit.cover,
  }) {
    final provider = getImageProvider(avatarPath);
    if (provider == null) return null;

    return DecorationImage(image: provider, fit: fit);
  }
}
