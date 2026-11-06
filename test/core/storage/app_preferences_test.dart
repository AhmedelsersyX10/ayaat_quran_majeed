import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsStorage storage;
  late AppPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = SharedPrefsStorage(prefs);
    preferences = AppPreferences(storage);
  });

  group('AppPreferences Contract & Default Values Tests', () {
    test('provides approved default values when storage is empty', () {
      expect(preferences.isDarkMode, isFalse);
      expect(preferences.keepScreenAwake, isTrue);
      expect(preferences.hijriOffset, equals(0));
      expect(preferences.mushafFontSize, equals(23.0));
      expect(preferences.indexActiveTab, equals(0));
    });

    test('persists and updates dark mode preference', () async {
      await preferences.setDarkMode(true);
      expect(preferences.isDarkMode, isTrue);

      await preferences.setDarkMode(false);
      expect(preferences.isDarkMode, isFalse);
    });

    test('persists and updates keep screen awake preference', () async {
      await preferences.setKeepScreenAwake(false);
      expect(preferences.keepScreenAwake, isFalse);

      await preferences.setKeepScreenAwake(true);
      expect(preferences.keepScreenAwake, isTrue);
    });

    test('persists and updates hijri date offset preference', () async {
      await preferences.setHijriOffset(1);
      expect(preferences.hijriOffset, equals(1));

      await preferences.setHijriOffset(-1);
      expect(preferences.hijriOffset, equals(-1));
    });

    test('persists and updates mushaf font size preference', () async {
      await preferences.setMushafFontSize(28.0);
      expect(preferences.mushafFontSize, equals(28.0));
    });

    test('persists and updates index active tab preference', () async {
      await preferences.setIndexActiveTab(1);
      expect(preferences.indexActiveTab, equals(1));

      await preferences.setIndexActiveTab(0);
      expect(preferences.indexActiveTab, equals(0));
    });
  });
}

