/// Central storage keys and box identifiers used across the application.
/// Pure Dart — no Flutter framework dependencies.
abstract class AppStorageKeys {
  // Schema versioning
  static const String schemaVersion = 'app_storage_schema_version';

  // General App Settings (SharedPreferences)
  static const String darkMode = 'setting_dark_mode';
  static const String keepScreenAwake = 'setting_keep_screen_awake';
  static const String hijriOffset = 'setting_hijri_offset';
  static const String mushafFontSize = 'setting_mushaf_font_size';

  // Legacy Storage Keys (migrated from legacy Hive box)
  static const String legacyDarkMode = 'darkMode';
  static const String legacyLastRead = 'lastRead';
  static const String legacyBookmarks = 'bookmarks';
  static const String legacyLastReadingPosition = 'lastReadingPosition';
}

/// Hive box identifiers.
abstract class AppBoxNames {
  /// Legacy single box used for backward compatibility.
  static const String legacyBox = 'name';
}

