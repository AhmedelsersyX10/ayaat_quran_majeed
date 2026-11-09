import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage_impl.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_migration_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Central coordinator for initializing local storage and running migrations.
abstract class StorageInitializer {
  /// Initializes the entire local storage layer:
  /// 1. Initializes SharedPreferences and registers [PreferencesStorage].
  /// 2. Initializes Hive document store and registers [HiveStorageService].
  /// 3. Opens baseline legacy box with automatic corruption recovery.
  /// 4. Executes storage migrations up to current schema version.
  /// 5. Registers typed [AppPreferences] consumer in service locator [sl].
  static Future<void> init({String? hiveDirectoryPath}) async {
    // 1. Initialize SharedPreferences
    final preferencesStorage = await SharedPrefsStorage.create();
    if (!sl.isRegistered<PreferencesStorage>()) {
      sl.registerSingleton<PreferencesStorage>(preferencesStorage);
    }

    // 2. Initialize Hive
    final hiveStorage = HiveStorageServiceImpl();
    final path = hiveDirectoryPath ?? (await getApplicationDocumentsDirectory()).path;
    await hiveStorage.init(storagePath: path);
    if (!sl.isRegistered<HiveStorageService>()) {
      sl.registerSingleton<HiveStorageService>(hiveStorage);
    }

    // 3. Open baseline box, audio cache, and khatma box with corruption recovery
    await hiveStorage.openBox(AppBoxNames.legacyBox);
    await hiveStorage.openBox(AppBoxNames.audioCache);
    await hiveStorage.openBox(AppBoxNames.khatmaBox);

    // 4. Execute migrations
    final migrationManager = StorageMigrationManager(
      preferencesStorage: preferencesStorage,
      hiveStorageService: hiveStorage,
    );
    await migrationManager.migrate();

    // 5. Register AppPreferences
    if (!sl.isRegistered<AppPreferences>()) {
      sl.registerSingleton<AppPreferences>(AppPreferences(preferencesStorage));
    }
  }
}

