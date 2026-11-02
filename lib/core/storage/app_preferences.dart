import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';

/// Concrete typed accessor for application preferences and settings.
/// Pure Dart — no Flutter framework dependencies.
class AppPreferences {
  final PreferencesStorage _storage;

  const AppPreferences(this._storage);

  /// Theme mode: whether dark mode is active. Default is `false` (light theme).
  bool get isDarkMode =>
      _storage.getBool(AppStorageKeys.darkMode) ?? false;

  Future<bool> setDarkMode(bool value) =>
      _storage.setBool(AppStorageKeys.darkMode, value);

  /// Keep screen awake during reading. Default is `true`.
  bool get keepScreenAwake =>
      _storage.getBool(AppStorageKeys.keepScreenAwake) ?? true;

  Future<bool> setKeepScreenAwake(bool value) =>
      _storage.setBool(AppStorageKeys.keepScreenAwake, value);

  /// Manual Hijri calendar adjustment (-1, 0, +1 day). Default is `0`.
  int get hijriOffset =>
      _storage.getInt(AppStorageKeys.hijriOffset) ?? 0;

  Future<bool> setHijriOffset(int value) =>
      _storage.setInt(AppStorageKeys.hijriOffset, value);

  /// Mushaf page view font size. Default is `23.0`.
  double get mushafFontSize =>
      _storage.getDouble(AppStorageKeys.mushafFontSize) ?? 23.0;

  Future<bool> setMushafFontSize(double value) =>
      _storage.setDouble(AppStorageKeys.mushafFontSize, value);
}

