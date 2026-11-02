import 'dart:io';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage_impl.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_migration_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveStorageServiceImpl hiveService;
  late SharedPrefsStorage prefsStorage;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('migration_test_');
    hiveService = HiveStorageServiceImpl();
    await hiveService.init(storagePath: tempDir.path);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    prefsStorage = SharedPrefsStorage(prefs);
  });

  tearDown(() async {
    await hiveService.closeAll();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('StorageMigrationManager Tests', () {
    test('fresh install migrates from v0 to v1 and sets schemaVersion', () async {
      expect(prefsStorage.getInt(AppStorageKeys.schemaVersion), isNull);

      final manager = StorageMigrationManager(
        preferencesStorage: prefsStorage,
        hiveStorageService: hiveService,
      );

      await manager.migrate();

      expect(
        prefsStorage.getInt(AppStorageKeys.schemaVersion),
        equals(StorageMigrationManager.currentSchemaVersion),
      );
    });

    test('migrates legacy darkMode and fontSize from Hive box to SharedPreferences', () async {
      // Setup legacy box with old data
      final legacyBox = await hiveService.openBox<dynamic>(AppBoxNames.legacyBox);
      await legacyBox.put(AppStorageKeys.legacyDarkMode, true);
      await legacyBox.put('pageViewFontSize', 27.5);
      await legacyBox.put(AppStorageKeys.legacyLastRead, 150);
      await legacyBox.put(AppStorageKeys.legacyBookmarks, '[{"name":"البقرة"}]');

      final manager = StorageMigrationManager(
        preferencesStorage: prefsStorage,
        hiveStorageService: hiveService,
      );

      await manager.migrate();

      // Verify simple settings migrated to SharedPreferences
      expect(prefsStorage.getBool(AppStorageKeys.darkMode), isTrue);
      expect(prefsStorage.getDouble(AppStorageKeys.mushafFontSize), equals(27.5));
      expect(
        prefsStorage.getInt(AppStorageKeys.schemaVersion),
        equals(StorageMigrationManager.currentSchemaVersion),
      );

      // Verify structured and reading data remained completely intact in legacy box
      expect(legacyBox.get(AppStorageKeys.legacyLastRead), equals(150));
      expect(legacyBox.get(AppStorageKeys.legacyBookmarks), equals('[{"name":"البقرة"}]'));
    });

    test('migration is idempotent and does not overwrite updated preferences', () async {
      // 1. Initial migration
      final legacyBox = await hiveService.openBox<dynamic>(AppBoxNames.legacyBox);
      await legacyBox.put(AppStorageKeys.legacyDarkMode, true);

      final manager = StorageMigrationManager(
        preferencesStorage: prefsStorage,
        hiveStorageService: hiveService,
      );
      await manager.migrate();
      expect(prefsStorage.getBool(AppStorageKeys.darkMode), isTrue);

      // 2. User later changes preference to false
      await prefsStorage.setBool(AppStorageKeys.darkMode, false);

      // 3. Second migration run on app reboot
      await manager.migrate();

      // Must remain false and not be overwritten by legacy box value
      expect(prefsStorage.getBool(AppStorageKeys.darkMode), isFalse);
    });
  });
}

