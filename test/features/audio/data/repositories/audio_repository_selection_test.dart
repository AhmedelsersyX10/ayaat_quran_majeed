import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/ayah_timing_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/moshaf_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/reciter_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/timing_read_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/repositories/audio_repository_impl.dart';
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

  @override
  Set<String> getKeys() => data.keys.toSet();
}

class FakeAudioRemoteDataSource implements AudioRemoteDataSource {
  List<ReciterModel> recitersResponse = [];
  List<TimingReadModel> timingReadsResponse = [];

  @override
  Future<List<ReciterModel>> getReciters({String language = 'ar'}) async =>
      recitersResponse;

  @override
  Future<List<TimingReadModel>> getTimingReads() async => timingReadsResponse;

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async => [];

  @override
  Future<List<AyahTimingModel>> getAyahTiming({
    required int readId,
    required int surahNumber,
  }) async =>
      [];

  @override
  Future<void> downloadSurahFile({
    required String url,
    required String savePath,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {}
}

class FakeAudioCacheDataSource implements AudioCacheDataSource {
  List<ReciterModel>? cachedReciters;
  List<int>? cachedTimingReadIds;

  @override
  Future<void> cacheReciters(List<ReciterModel> reciters) async {
    cachedReciters = reciters;
  }

  @override
  Future<List<ReciterModel>?> getCachedReciters() async => cachedReciters;

  @override
  Future<void> cacheTimingReadIds(List<int> readIds) async {
    cachedTimingReadIds = readIds;
  }

  @override
  Future<List<int>?> getCachedTimingReadIds() async => cachedTimingReadIds;

  @override
  Future<void> cacheTimingSurahIds(int readId, List<int> surahIds) async {}

  @override
  Future<List<int>?> getCachedTimingSurahIds(int readId) async => null;

  @override
  Future<void> cacheAyahTiming(
    int readId,
    int surahNumber,
    List<AyahTimingModel> timings,
  ) async {}

  @override
  Future<List<AyahTimingModel>?> getCachedAyahTiming(
    int readId,
    int surahNumber,
  ) async =>
      null;

  @override
  Future<void> clearCache() async {
    cachedReciters = null;
    cachedTimingReadIds = null;
  }
}

void main() {
  late FakeAudioRemoteDataSource remote;
  late FakeAudioCacheDataSource cache;
  late FakePreferencesStorage fakeStorage;
  late AppPreferences preferences;
  late AudioRepositoryImpl repository;

  const testMoshafHosaryMurattal = MoshafModel(
    id: 118,
    name: 'حفص عن عاصم - مرتل',
    server: 'https://server.com/hosary/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2, 3],
  );

  const testMoshafHosaryMujawwad = MoshafModel(
    id: 119,
    name: 'حفص عن عاصم - مجود',
    server: 'https://server.com/hosary_m/',
    surahTotal: 114,
    moshafType: 2,
    surahList: [1, 2, 3],
  );

  const testReciterHosary = ReciterModel(
    id: 1,
    name: 'محمود خليل الحصري',
    letter: 'م',
    moshafs: [testMoshafHosaryMurattal, testMoshafHosaryMujawwad],
  );

  const testMoshafGhamadi = MoshafModel(
    id: 30,
    name: 'حفص عن عاصم',
    server: 'https://server.com/ghamadi/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2, 3],
  );

  const testReciterGhamadi = ReciterModel(
    id: 2,
    name: 'سعد الغامدي',
    letter: 'س',
    moshafs: [testMoshafGhamadi],
  );

  setUp(() {
    remote = FakeAudioRemoteDataSource();
    cache = FakeAudioCacheDataSource();
    fakeStorage = FakePreferencesStorage();
    preferences = AppPreferences(fakeStorage);

    remote.recitersResponse = [testReciterHosary, testReciterGhamadi];
    remote.timingReadsResponse = [
      const TimingReadModel(
        id: 118,
        name: 'حفص مرتل',
        rewaya: 'حفص',
        folderUrl: 'https://server.com/hosary/',
        soarCount: 114,
      ),
      const TimingReadModel(
        id: 30,
        name: 'حفص',
        rewaya: 'حفص',
        folderUrl: 'https://server.com/ghamadi/',
        soarCount: 114,
      ),
    ];

    repository = AudioRepositoryImpl(
      remoteDataSource: remote,
      cacheDataSource: cache,
      metadataService: const QuranMetadataService(),
      preferences: preferences,
      documentsPathProvider: () async => '/test_storage',
    );
  });

  group('AudioRepository Selection Persistence & Defaults', () {
    test('getSelectedReciter defaults to Al-Hosary when nothing saved', () async {
      final reciter = await repository.getSelectedReciter();
      expect(reciter, isNotNull);
      expect(reciter!.id, equals(1));
      expect(reciter.name, contains('الحصري'));
    });

    test('getSelectedMoshaf defaults to Al-Hosary timing-supported edition (118)', () async {
      final moshaf = await repository.getSelectedMoshaf();
      expect(moshaf, isNotNull);
      expect(moshaf!.id, equals(118));
      expect(moshaf.hasTiming, isTrue);
    });

    test('setSelectedReciterAndMoshaf stores IDs in preferences', () async {
      await repository.setSelectedReciterAndMoshaf(reciterId: 2, moshafId: 30);

      expect(preferences.selectedReciterId, equals(2));
      expect(preferences.selectedMoshafId, equals(30));
    });

    test('getSelectedReciter returns saved reciter when available', () async {
      await repository.setSelectedReciterAndMoshaf(reciterId: 2, moshafId: 30);

      final reciter = await repository.getSelectedReciter();
      expect(reciter, isNotNull);
      expect(reciter!.id, equals(2));
      expect(reciter.name, equals('سعد الغامدي'));
    });

    test('getSelectedMoshaf returns saved moshaf when available', () async {
      await repository.setSelectedReciterAndMoshaf(reciterId: 2, moshafId: 30);

      final moshaf = await repository.getSelectedMoshaf();
      expect(moshaf, isNotNull);
      expect(moshaf!.id, equals(30));
      expect(moshaf.name, equals('حفص عن عاصم'));
    });

    test('getSelectedReciter returns null when reciters list is empty', () async {
      remote.recitersResponse = [];
      final reciter = await repository.getSelectedReciter();
      expect(reciter, isNull);
    });
  });
}
