import 'dart:convert';

/// Abstract interface for key-value storage
/// Can be implemented with shared_preferences, hive, etc.
abstract class KeyValueStore {
  /// Gets a string value
  Future<String?> getString(String key);

  /// Sets a string value
  Future<bool> setString(String key, String value);

  /// Gets an int value
  Future<int?> getInt(String key);

  /// Sets an int value
  Future<bool> setInt(String key, int value);

  /// Gets a double value
  Future<double?> getDouble(String key);

  /// Sets a double value
  Future<bool> setDouble(String key, double value);

  /// Gets a bool value
  Future<bool?> getBool(String key);

  /// Sets a bool value
  Future<bool> setBool(String key, bool value);

  /// Gets a list of strings
  Future<List<String>?> getStringList(String key);

  /// Sets a list of strings
  Future<bool> setStringList(String key, List<String> value);

  /// Gets a JSON object as Map
  Future<Map<String, dynamic>?> getJson(String key);

  /// Sets a JSON object from Map
  Future<bool> setJson(String key, Map<String, dynamic> value);

  /// Removes a value
  Future<bool> remove(String key);

  /// Clears all values
  Future<bool> clear();

  /// Checks if a key exists
  Future<bool> containsKey(String key);

  /// Gets all keys
  Future<Set<String>> getKeys();
}

/// Implementation using shared_preferences
/// Note: Add shared_preferences to pubspec.yaml
class SharedPreferencesStore implements KeyValueStore {
  final dynamic _prefs; // SharedPreferences instance

  SharedPreferencesStore(this._prefs);

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs.getKeys();
  }
}

