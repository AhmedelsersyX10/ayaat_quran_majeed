import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';

/// Manages database and storage schema migrations across app versions.
/// Pure Dart — no Flutter framework dependencies.
class StorageMigrationManager {
  static const int currentSchemaVersion = 1;

  final PreferencesStorage _preferencesStorage;
  final HiveStorageService _hiveStorageService;

  const StorageMigrationManager({
    required PreferencesStorage preferencesStorage,
    required HiveStorageService hiveStorageService,
  })  : _preferencesStorage = preferencesStorage,
        _hiveStorageService = hiveStorageService;

  /// Executes required migrations sequentially up to [currentSchemaVersion].
  Future<void> migrate() async {
    try {
      final savedVersion =
          _preferencesStorage.getInt(AppStorageKeys.schemaVersion) ?? 0;

      if (savedVersion < 1) {
        await _migrateToV1();
      }

      // Record target schema version once all steps complete
      await _preferencesStorage.setInt(
        AppStorageKeys.schemaVersion,
        currentSchemaVersion,
      );
    } catch (e) {
      throw CacheException('Storage migration failed: $e');
    }
  }

  /// Version 1 Migration:
  /// Extracts simple user settings from legacy single Hive box ('name')
  /// and moves them to typed [PreferencesStorage].
  /// Preserves structured data (bookmarks, reading position) intact.
  Future<void> _migrateToV1() async {
    if (!_hiveStorageService.isBoxOpen(AppBoxNames.legacyBox)) {
      // If legacy box is not already open, attempt to open it
      await _hiveStorageService.openBox(AppBoxNames.legacyBox);
    }

    final legacyBox = _hiveStorageService.getBox(AppBoxNames.legacyBox);

    // 1. Dark Mode migration
    final legacyDark = legacyBox.get(AppStorageKeys.legacyDarkMode);
    if (legacyDark is bool) {
      // Migrate existing choice to SharedPreferences
      await _preferencesStorage.setBool(AppStorageKeys.darkMode, legacyDark);
    }

    // 2. Mushaf font size migration
    final legacyFontSize = legacyBox.get('pageViewFontSize');
    if (legacyFontSize is num) {
      await _preferencesStorage.setDouble(
        AppStorageKeys.mushafFontSize,
        legacyFontSize.toDouble(),
      );
    }
  }
}

