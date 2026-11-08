import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/ayah_timing_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/moshaf_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/reciter_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/timing_read_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAudioRemoteDataSource implements AudioRemoteDataSource {
  List<ReciterModel> recitersResponse = [];
  List<TimingReadModel> timingReadsResponse = [];
  List<int> timingSoarResponse = [];
  List<AyahTimingModel> ayahTimingResponse = [];

  AppException? exceptionToThrow;
  bool downloadShouldFail = false;

  int getRecitersCallCount = 0;
  int getTimingReadsCallCount = 0;
  int getAyahTimingCallCount = 0;

  @override
  Future<List<ReciterModel>> getReciters({String language = 'ar'}) async {
    getRecitersCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return recitersResponse;
  }

  @override
  Future<List<TimingReadModel>> getTimingReads() async {
    getTimingReadsCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return timingReadsResponse;
  }

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return timingSoarResponse;
  }

  @override
  Future<List<AyahTimingModel>> getAyahTiming({
    required int surahNumber,
    required int readId,
  }) async {
    getAyahTimingCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return ayahTimingResponse;
  }

  @override
  Future<void> downloadSurahFile({
    required String url,
    required String savePath,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (downloadShouldFail) {
      throw const NetworkException('Connection reset');
    }
    // Simulate successful file write
    final file = File(savePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(List<int>.filled(2048, 65));
  }
}

class FakeAudioCacheDataSource implements AudioCacheDataSource {
  List<ReciterModel>? cachedReciters;
  List<int>? cachedTimingReadIds;
  final Map<int, List<int>> cachedTimingSurahs = {};
  final Map<String, List<AyahTimingModel>> cachedAyahTiming = {};

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
  Future<void> cacheTimingSurahIds(int readId, List<int> surahIds) async {
    cachedTimingSurahs[readId] = surahIds;
  }

  @override
  Future<List<int>?> getCachedTimingSurahIds(int readId) async =>
      cachedTimingSurahs[readId];

  @override
  Future<void> cacheAyahTiming(
    int readId,
    int surahNumber,
    List<AyahTimingModel> timings,
  ) async {
    cachedAyahTiming['${readId}_$surahNumber'] = timings;
  }

  @override
  Future<List<AyahTimingModel>?> getCachedAyahTiming(
    int readId,
    int surahNumber,
  ) async =>
      cachedAyahTiming['${readId}_$surahNumber'];

  @override
  Future<void> clearCache() async {
    cachedReciters = null;
    cachedTimingReadIds = null;
    cachedTimingSurahs.clear;
    cachedAyahTiming.clear();
  }
}

void main() {
  late Directory tempDir;
  late FakeAudioRemoteDataSource remote;
  late FakeAudioCacheDataSource cache;
  late QuranMetadataService metadataService;
  late AudioRepositoryImpl repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('audio_repo_test_');
    remote = FakeAudioRemoteDataSource();
    cache = FakeAudioCacheDataSource();
    metadataService = const QuranMetadataService();

    repository = AudioRepositoryImpl(
      remoteDataSource: remote,
      cacheDataSource: cache,
      metadataService: metadataService,
      documentsPathProvider: () async => tempDir.path,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AudioRepositoryImpl - Reciters & Timing Reads', () {
    const testReciter = ReciterModel(
      id: 1,
      name: 'محمود خليل الحصري',
      letter: 'م',
      moshafs: [
        MoshafModel(
          id: 118,
          name: 'حفص مرتل',
          server: 'https://server.com/118/',
          surahTotal: 114,
          moshafType: 1,
          surahList: [1, 2, 3],
        ),
        MoshafModel(
          id: 999,
          name: 'رواية نادرة',
          server: 'https://server.com/999/',
          surahTotal: 114,
          moshafType: 2,
          surahList: [1, 2],
        ),
      ],
    );

    const testTimingRead = TimingReadModel(
      id: 118,
      name: 'الحصري',
      rewaya: 'حفص',
      folderUrl: 'https://server.com/118/',
      soarCount: 114,
    );

    test('getReciters fetches remote, enriches with timing flags, and caches', () async {
      remote.recitersResponse = [testReciter];
      remote.timingReadsResponse = [testTimingRead];

      final reciters = await repository.getReciters();

      expect(remote.getRecitersCallCount, equals(1));
      expect(remote.getTimingReadsCallCount, equals(1));
      expect(reciters.length, equals(1));

      final reciter = reciters.first;
      expect(reciter.id, equals(1));
      expect(reciter.moshafs.length, equals(2));
      // Moshaf 118 is in timing reads -> hasTiming == true
      expect(reciter.moshafs[0].hasTiming, isTrue);
      // Moshaf 999 is NOT in timing reads -> hasTiming == false
      expect(reciter.moshafs[1].hasTiming, isFalse);

      // Verify cached
      expect(cache.cachedReciters, isNotNull);
      expect(cache.cachedTimingReadIds, equals([118]));
    });

    test('getReciters uses cache when available and forceRefresh is false', () async {
      cache.cachedReciters = [testReciter];
      cache.cachedTimingReadIds = [118];

      final reciters = await repository.getReciters(forceRefresh: false);

      expect(remote.getRecitersCallCount, equals(0));
      expect(reciters.length, equals(1));
      expect(reciters.first.moshafs[0].hasTiming, isTrue);
    });

    test('getReciters falls back to cache on remote failure', () async {
      cache.cachedReciters = [testReciter];
      cache.cachedTimingReadIds = [118];
      remote.exceptionToThrow = const NetworkException('Offline');

      final reciters = await repository.getReciters(forceRefresh: true);

      expect(reciters.length, equals(1));
      expect(reciters.first.id, equals(1));
    });

    test('getReciters throws ServerFailure when both remote and cache fail', () async {
      remote.exceptionToThrow = const ServerException('Server 500');

      expect(
        () => repository.getReciters(forceRefresh: true),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('getReciterById finds correct reciter or returns null', () async {
      remote.recitersResponse = [testReciter];
      remote.timingReadsResponse = [testTimingRead];

      final found = await repository.getReciterById(1);
      expect(found, isNotNull);
      expect(found!.id, equals(1));

      final notFound = await repository.getReciterById(999);
      expect(notFound, isNull);
    });
  });

  group('AudioRepositoryImpl - Ayah Timing', () {
    const timingItem = AyahTimingModel(ayah: 1, startTime: 0, endTime: 5000);

    test('getAyahTiming fetches from remote on cache miss and caches result', () async {
      remote.ayahTimingResponse = [timingItem];

      final timings = await repository.getAyahTiming(readId: 118, surahNumber: 1);

      expect(remote.getAyahTimingCallCount, equals(1));
      expect(timings.length, equals(1));
      expect(timings.first.ayah, equals(1));
      expect(timings.first.endTimeMs, equals(5000));
      expect(cache.cachedAyahTiming['118_1'], isNotNull);
    });

    test('getAyahTiming returns from cache when available', () async {
      cache.cachedAyahTiming['118_1'] = [timingItem];

      final timings = await repository.getAyahTiming(readId: 118, surahNumber: 1);

      expect(remote.getAyahTimingCallCount, equals(0));
      expect(timings.length, equals(1));
    });

    test('getAyahTiming returns empty list on network error (plays without highlight)', () async {
      remote.exceptionToThrow = const NetworkException('404 Not Found');

      final timings = await repository.getAyahTiming(readId: 118, surahNumber: 100);

      // Must degrade gracefully to empty list
      expect(timings, isEmpty);
    });
  });

  group('AudioRepositoryImpl - Downloads and File Handling', () {
    const testMoshaf = Moshaf(
      id: 118,
      name: 'حفص مرتل',
      server: 'https://server.com/118/',
      surahTotal: 114,
      moshafType: 1,
      surahList: [1, 2],
      hasTiming: true,
    );

    test('isSurahDownloaded returns false when file does not exist', () async {
      final downloaded = await repository.isSurahDownloaded(readId: 118, surahNumber: 1);
      expect(downloaded, isFalse);
    });

    test('downloadSurah downloads atomically and isSurahDownloaded becomes true', () async {
      await repository.downloadSurah(moshaf: testMoshaf, surahNumber: 1);

      final isDownloaded = await repository.isSurahDownloaded(readId: 118, surahNumber: 1);
      expect(isDownloaded, isTrue);

      final filePath = await repository.getPlayableAudioUri(moshaf: testMoshaf, surahNumber: 1);
      expect(filePath, endsWith('/quran_audio/118/001.mp3'));
      expect(File(filePath).existsSync(), isTrue);
    });

    test('downloadSurah cleans up temp file on failure', () async {
      remote.downloadShouldFail = true;

      expect(
        () => repository.downloadSurah(moshaf: testMoshaf, surahNumber: 2),
        throwsA(isA<ServerFailure>()),
      );

      final isDownloaded = await repository.isSurahDownloaded(readId: 118, surahNumber: 2);
      expect(isDownloaded, isFalse);
      expect(File('${tempDir.path}/quran_audio/118/002.mp3.tmp').existsSync(), isFalse);
    });

    test('deleteDownloadedSurah deletes existing file cleanly', () async {
      await repository.downloadSurah(moshaf: testMoshaf, surahNumber: 1);
      expect(await repository.isSurahDownloaded(readId: 118, surahNumber: 1), isTrue);

      await repository.deleteDownloadedSurah(readId: 118, surahNumber: 1);
      expect(await repository.isSurahDownloaded(readId: 118, surahNumber: 1), isFalse);
    });

    test('getPlayableAudioUri returns remote streaming URL when not downloaded', () async {
      final uri = await repository.getPlayableAudioUri(moshaf: testMoshaf, surahNumber: 1);
      expect(uri, equals('https://server.com/118/001.mp3'));
    });

    test('getSurahsForMoshaf builds list of ReciterSurah with correct metadata', () async {
      remote.timingSoarResponse = [1]; // Surah 1 has timing, Surah 2 does not

      final surahs = await repository.getSurahsForMoshaf(
        reciterId: 1,
        moshaf: testMoshaf,
      );

      expect(surahs.length, equals(2));

      // Surah 1 (Al-Fatihah)
      expect(surahs[0].surahNumber, equals(1));
      expect(surahs[0].surahName, equals(metadataService.getSurahNameArabic(1)));
      expect(surahs[0].juzNumber, equals(1));
      expect(surahs[0].verseCount, equals(7));
      expect(surahs[0].hasTiming, isTrue);
      expect(surahs[0].isDownloaded, isFalse);

      // Surah 2 (Al-Baqarah)
      expect(surahs[1].surahNumber, equals(2));
      expect(surahs[1].surahName, equals(metadataService.getSurahNameArabic(2)));
      expect(surahs[1].hasTiming, isFalse);
    });
  });
}
