import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePreferencesStorage implements PreferencesStorage {
  final Map<String, dynamic> _values = {};

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _values[key] as double?;

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  List<String>? getStringList(String key) =>
      (_values[key] as List<dynamic>?)?.cast<String>();

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Set<String> getKeys() => _values.keys.toSet();
}

void main() {
  late FakePreferencesStorage storage;
  late AppPreferences preferences;
  late SettingsLocalDataSource localDataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    storage = FakePreferencesStorage();
    preferences = AppPreferences(storage);
    localDataSource = SettingsLocalDataSourceImpl(preferences: preferences);
    repository = SettingsRepositoryImpl(localDataSource: localDataSource);
  });

  group('SettingsRepositoryImpl', () {
    test('getSettings returns default app settings when storage is empty', () {
      final settings = repository.getSettings();

      expect(settings.keepScreenAwake, isTrue);
      expect(settings.hijriOffset, 0);
      expect(settings.mushafFontSize, 23.0);
      expect(settings.isMushafTextSizingSupported, isFalse);
    });

    test(
      'setKeepScreenAwake updates and persists the wake lock preference',
      () async {
        await repository.setKeepScreenAwake(false);
        final settings = repository.getSettings();

        expect(settings.keepScreenAwake, isFalse);
      },
    );

    test('setHijriOffset updates and persists the offset', () async {
      await repository.setHijriOffset(1);
      final settings = repository.getSettings();

      expect(settings.hijriOffset, 1);

      await repository.setHijriOffset(-1);
      expect(repository.getSettings().hijriOffset, -1);
    });

    test('setMushafFontSize updates and persists the font size', () async {
      await repository.setMushafFontSize(26.0);
      final settings = repository.getSettings();

      expect(settings.mushafFontSize, 26.0);
    });

    test(
      'getSourcesAndAttributions returns 7 verified sources with attributions',
      () {
        final sources = repository.getSourcesAndAttributions();

        expect(sources.length, 7);

        // 1. Quran engine
        expect(sources[0].category, ContentSourceCategory.quranEngine);
        expect(sources[0].provider, contains('مجمع الملك فهد'));
        expect(sources[0].url, isNotNull);

        // 2. Al-Tafsir Al-Muyassar
        expect(sources[1].category, ContentSourceCategory.tafsir);
        expect(sources[1].title, 'التفسير الميسر');

        // 3. English translation (Saheeh International)
        expect(sources[2].category, ContentSourceCategory.tafsir);
        expect(sources[2].provider, contains('Saheeh International'));

        // 4. Open-source library tafsir data
        expect(sources[3].category, ContentSourceCategory.openSource);
        expect(sources[3].provider, contains('noureddin/Quran-App-Data'));

        // 5. Audio recitations
        expect(sources[4].category, ContentSourceCategory.audio);
        expect(sources[4].provider, contains('MP3Quran.net'));

        // 6. Hijri calendar
        expect(sources[5].category, ContentSourceCategory.calendar);
        expect(sources[5].provider, 'تقويم أم القرى');

        // 7. Open source licenses
        expect(sources[6].category, ContentSourceCategory.openSource);
        expect(sources[6].title, contains('تراخيص'));
      },
    );
  });
}
