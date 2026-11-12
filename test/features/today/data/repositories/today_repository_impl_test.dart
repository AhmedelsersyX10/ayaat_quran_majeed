import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/features/today/data/repositories/today_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/today/data/services/umm_al_qura_date_service.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePreferencesStorage implements PreferencesStorage {
  final Map<String, dynamic> data;
  FakePreferencesStorage([Map<String, dynamic>? initial])
    : data = initial ?? {};

  @override
  bool? getBool(String key) => data[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    data[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => data[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    data[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => data[key] as double?;
  @override
  Future<bool> setDouble(String key, double value) async {
    data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => data[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    data[key] = value;
    return true;
  }

  @override
  List<String>? getStringList(String key) => data[key] as List<String>?;
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    data[key] = value;
    return true;
  }

  @override
  Set<String> getKeys() => data.keys.toSet();

  @override
  bool containsKey(String key) => data.containsKey(key);
  @override
  Future<bool> remove(String key) async {
    data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    data.clear();
    return true;
  }
}

class EmptyQuranMetadataService extends QuranMetadataService {
  const EmptyQuranMetadataService();

  @override
  List<Map<String, dynamic>> get allVersesRawData => const [];
}

void main() {
  const metadataService = QuranMetadataService();
  const dateService = UmmAlQuraDateService();

  late FakePreferencesStorage fakeStorage;
  late AppPreferences preferences;
  late TodayRepositoryImpl repository;

  setUp(() {
    fakeStorage = FakePreferencesStorage();
    preferences = AppPreferences(fakeStorage);
    repository = TodayRepositoryImpl(
      metadataService: metadataService,
      dateService: dateService,
      preferences: preferences,
    );
  });

  group('TodayRepositoryImpl Unit Tests', () {
    test('returns identical Ayah for identical local date', () async {
      final date = DateTime(2026, 11, 4);

      final ayah1 = await repository.getTodayAyah(forDate: date);
      final ayah2 = await repository.getTodayAyah(forDate: date);

      expect(ayah1.surahNumber, equals(ayah2.surahNumber));
      expect(ayah1.ayahNumber, equals(ayah2.ayahNumber));
      expect(ayah1.ayahText, equals(ayah2.ayahText));
      expect(ayah1.pageNumber, equals(ayah2.pageNumber));
      expect(ayah1.hijriDay, equals(ayah2.hijriDay));
      expect(ayah1.gregorianDay, equals(ayah2.gregorianDay));
    });

    test('returns different consecutive Ayah for the following day', () async {
      final today = DateTime(2026, 11, 4);
      final tomorrow = DateTime(2026, 11, 5);

      final ayahToday = await repository.getTodayAyah(forDate: today);
      final ayahTomorrow = await repository.getTodayAyah(forDate: tomorrow);

      expect(
        ayahToday.surahNumber != ayahTomorrow.surahNumber ||
            ayahToday.ayahNumber != ayahTomorrow.ayahNumber,
        isTrue,
      );
    });

    test(
      'wraps safely around 6236 total verses count without crashing',
      () async {
        // 6236 days later should wrap to the exact same relative verse modulo
        final baseDate = DateTime(2024, 1, 1);
        final wrappedDate = baseDate.add(const Duration(days: 6236));

        final baseAyah = await repository.getTodayAyah(forDate: baseDate);
        final wrappedAyah = await repository.getTodayAyah(forDate: wrappedDate);

        expect(baseAyah.surahNumber, equals(wrappedAyah.surahNumber));
        expect(baseAyah.ayahNumber, equals(wrappedAyah.ayahNumber));
        expect(baseAyah.ayahText, equals(wrappedAyah.ayahText));
      },
    );

    test('maps real Quran metadata accurately', () async {
      final result = await repository.getTodayAyah(
        forDate: DateTime(2023, 10, 30),
      );

      expect(result.surahNumber, inInclusiveRange(1, 114));
      expect(result.ayahNumber, greaterThanOrEqualTo(1));
      expect(result.pageNumber, inInclusiveRange(1, 604));
      expect(result.ayahText, isNotEmpty);
      expect(result.surahNameArabic, isNotEmpty);
      expect(result.ayahEndSymbol, isNotEmpty);
    });

    test('maps empty Quran metadata to a safe domain failure', () async {
      final emptyRepository = TodayRepositoryImpl(
        metadataService: const EmptyQuranMetadataService(),
        dateService: dateService,
        preferences: preferences,
      );

      expect(
        () => emptyRepository.getTodayAyah(forDate: DateTime(2026, 11, 4)),
        throwsA(const GeneralFailure(AppStrings.todayLoadFailed)),
      );
    });

    test('applies hijriOffset (-1, 0, +1) from AppPreferences', () async {
      final fixedDate = DateTime(2023, 10, 30);

      // Offset 0 (15 Rabi' al-Thani)
      fakeStorage.data[AppStorageKeys.hijriOffset] = 0;
      final result0 = await repository.getTodayAyah(forDate: fixedDate);
      expect(result0.hijriDay, '١٥');
      expect(result0.hijriOffset, 0);

      // Offset +1 (16 Rabi' al-Thani)
      fakeStorage.data[AppStorageKeys.hijriOffset] = 1;
      final resultPlus1 = await repository.getTodayAyah(forDate: fixedDate);
      expect(resultPlus1.hijriDay, '١٦');
      expect(resultPlus1.hijriOffset, 1);

      // Offset -1 (14 Rabi' al-Thani)
      fakeStorage.data[AppStorageKeys.hijriOffset] = -1;
      final resultMinus1 = await repository.getTodayAyah(forDate: fixedDate);
      expect(resultMinus1.hijriDay, '١٤');
      expect(resultMinus1.hijriOffset, -1);
    });

    test(
      'getHijriOffset and setHijriOffset manage clamped offset correctly',
      () async {
        expect(repository.getHijriOffset(), 0);

        await repository.setHijriOffset(1);
        expect(repository.getHijriOffset(), 1);
        expect(fakeStorage.getInt(AppStorageKeys.hijriOffset), 1);

        await repository.setHijriOffset(-1);
        expect(repository.getHijriOffset(), -1);
        expect(fakeStorage.getInt(AppStorageKeys.hijriOffset), -1);

        // Clamping out-of-range offsets
        await repository.setHijriOffset(5);
        expect(repository.getHijriOffset(), 1);
        expect(fakeStorage.getInt(AppStorageKeys.hijriOffset), 1);

        await repository.setHijriOffset(-10);
        expect(repository.getHijriOffset(), -1);
        expect(fakeStorage.getInt(AppStorageKeys.hijriOffset), -1);
      },
    );
  });
}
