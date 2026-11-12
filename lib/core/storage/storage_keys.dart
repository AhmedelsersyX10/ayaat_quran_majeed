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
  static const String indexActiveTab = 'index_active_tab';
  static const String selectedReciterId = 'audio_selected_reciter_id';
  static const String selectedMoshafId = 'audio_selected_moshaf_id';

  // Tafsir & Library Settings (Screens 17, 34)
  static const String selectedTafsirBookId = 'tafsir_selected_book_id';
  static const String myLibraryBookIds = 'tafsir_my_library_book_ids';
  static const String tafsirSchemaVersion = 'tafsir_schema_version';

  // Khatma Settings & Keys (Screens 06-10, 24-26, 31)
  static const String activeKhatmaKey = 'active_khatma';

  // Starred Verses Key (Screens 12, 28)
  static const String starredVerses = 'starred_verses';

  // Notes Key (Screens 13, 29, 30)
  static const String notes = 'user_notes';

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

  /// Audio and reciters cache box.
  static const String audioCache = 'audio_cache_box';

  /// Tafsir and book cache box.
  static const String tafsirCache = 'tafsir_cache_box';

  /// Active khatma and reading progress box.
  static const String khatmaBox = 'khatma_box';
}

