import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of [PreferencesStorage] backed by [SharedPreferences].
class SharedPrefsStorage implements PreferencesStorage {
  final SharedPreferences _prefs;

  const SharedPrefsStorage(this._prefs);

  /// Factory to initialize [SharedPrefsStorage] asynchronously from platform.
  static Future<SharedPrefsStorage> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return SharedPrefsStorage(prefs);
    } catch (e) {
      throw CacheException('Failed to initialize SharedPreferences: $e');
    }
  }

  @override
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException('Failed to read bool for key "$key": $e');
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException('Failed to write bool for key "$key": $e');
    }
  }

  @override
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException('Failed to read int for key "$key": $e');
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException('Failed to write int for key "$key": $e');
    }
  }

  @override
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      throw CacheException('Failed to read double for key "$key": $e');
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      throw CacheException('Failed to write double for key "$key": $e');
    }
  }

  @override
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException('Failed to read string for key "$key": $e');
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException('Failed to write string for key "$key": $e');
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      throw CacheException('Failed to read stringList for key "$key": $e');
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      throw CacheException('Failed to write stringList for key "$key": $e');
    }
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      throw CacheException('Failed to remove key "$key": $e');
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      throw CacheException('Failed to clear SharedPreferences: $e');
    }
  }

  @override
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}

