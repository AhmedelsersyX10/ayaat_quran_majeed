import 'dart:io';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_initializer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    await resetInjection();
    SharedPreferences.setMockInitialValues({});
    tempDir = Directory.systemTemp.createTempSync('storage_initializer_test_');
  });

  tearDown(() async {
    await resetInjection();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('StorageInitializer End-to-End Tests', () {
    test('initializes and registers all storage components and executes migration', () async {
      expect(sl.isRegistered<PreferencesStorage>(), isFalse);
      expect(sl.isRegistered<HiveStorageService>(), isFalse);
      expect(sl.isRegistered<AppPreferences>(), isFalse);

      await StorageInitializer.init(hiveDirectoryPath: tempDir.path);

      // Verify all singletons registered in DI
      expect(sl.isRegistered<PreferencesStorage>(), isTrue);
      expect(sl.isRegistered<HiveStorageService>(), isTrue);
      expect(sl.isRegistered<AppPreferences>(), isTrue);

      // Verify baseline legacy box is open
      final hiveService = sl<HiveStorageService>();
      expect(hiveService.isBoxOpen(AppBoxNames.legacyBox), isTrue);

      // Verify schema version is migrated to V1
      final prefs = sl<PreferencesStorage>();
      expect(prefs.getInt(AppStorageKeys.schemaVersion), equals(1));

      // Verify AppPreferences is functional
      final appPrefs = sl<AppPreferences>();
      expect(appPrefs.isDarkMode, isFalse);
      expect(appPrefs.keepScreenAwake, isTrue);
    });
  });
}

