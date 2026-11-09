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

  /// Active tab index in Quran Index (0: Surahs, 1: Quarters). Default is `0`.
  int get indexActiveTab =>
      _storage.getInt(AppStorageKeys.indexActiveTab) ?? 0;

  Future<bool> setIndexActiveTab(int value) =>
      _storage.setInt(AppStorageKeys.indexActiveTab, value);

  /// Selected Quran reciter identifier. Null if not explicitly set yet.
  int? get selectedReciterId =>
      _storage.getInt(AppStorageKeys.selectedReciterId);

  Future<bool> setSelectedReciterId(int id) =>
      _storage.setInt(AppStorageKeys.selectedReciterId, id);

  /// Selected Moshaf edition identifier. Null if not explicitly set yet.
  int? get selectedMoshafId =>
      _storage.getInt(AppStorageKeys.selectedMoshafId);

  Future<bool> setSelectedMoshafId(int id) =>
      _storage.setInt(AppStorageKeys.selectedMoshafId, id);

  /// Selected Tafsir book identifier. Default is 'ar_muyassar' (Al-Tafsir Al-Muyassar).
  String get selectedTafsirBookId =>
      _storage.getString(AppStorageKeys.selectedTafsirBookId) ?? 'ar_muyassar';

  Future<bool> setSelectedTafsirBookId(String id) =>
      _storage.setString(AppStorageKeys.selectedTafsirBookId, id);

  /// User's pinned books list ("مكتبتي" - Reference 34).
  /// Defaults to ['ar_muyassar', 'en_sahih'].
  List<String> get myLibraryBookIds =>
      _storage.getStringList(AppStorageKeys.myLibraryBookIds) ??
      const ['ar_muyassar', 'en_sahih'];

  Future<bool> setMyLibraryBookIds(List<String> ids) =>
      _storage.setStringList(AppStorageKeys.myLibraryBookIds, ids);

  /// Tafsir data schema version for migrations and cache invalidation.
  int get tafsirSchemaVersion =>
      _storage.getInt(AppStorageKeys.tafsirSchemaVersion) ?? 1;

  Future<bool> setTafsirSchemaVersion(int version) =>
      _storage.setInt(AppStorageKeys.tafsirSchemaVersion, version);
}

