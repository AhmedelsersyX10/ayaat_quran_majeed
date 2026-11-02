/// Abstract contract for primitive key-value storage (e.g. SharedPreferences).
/// Pure Dart — no Flutter framework dependencies.
abstract class PreferencesStorage {
  /// Reads a boolean value stored under [key].
  bool? getBool(String key);

  /// Stores a boolean [value] under [key].
  Future<bool> setBool(String key, bool value);

  /// Reads an integer value stored under [key].
  int? getInt(String key);

  /// Stores an integer [value] under [key].
  Future<bool> setInt(String key, int value);

  /// Reads a double value stored under [key].
  double? getDouble(String key);

  /// Stores a double [value] under [key].
  Future<bool> setDouble(String key, double value);

  /// Reads a string value stored under [key].
  String? getString(String key);

  /// Stores a string [value] under [key].
  Future<bool> setString(String key, String value);

  /// Reads a list of strings stored under [key].
  List<String>? getStringList(String key);

  /// Stores a list of strings [value] under [key].
  Future<bool> setStringList(String key, List<String> value);

  /// Returns true if [key] exists in storage.
  bool containsKey(String key);

  /// Removes the entry associated with [key].
  Future<bool> remove(String key);

  /// Clears all entries from storage.
  Future<bool> clear();

  /// Returns all available keys.
  Set<String> getKeys();
}

