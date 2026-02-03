import 'package:uuid/uuid.dart';

/// Utility class for generating unique identifiers
class Uid {
  static const _uuid = Uuid();

  /// Generates a new UUID v4
  static String generate() => _uuid.v4();

  /// Generates a short unique ID (first 8 characters of UUID)
  static String generateShort() => _uuid.v4().substring(0, 8);

  /// Validates if a string is a valid UUID
  static bool isValid(String id) {
    try {
      Uuid.parse(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}

