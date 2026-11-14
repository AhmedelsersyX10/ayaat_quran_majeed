import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/ayah_timing_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/reciter_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/timing_read_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemoteDataSource implements AudioRemoteDataSource {
  List<AyahTimingModel> timingModels = [];
  bool failDownload = false;
  bool cancelDownload = false;
  int simulateDownloadedBytes = 2048; // Valid size > 1024 bytes

  @override
  Future<List<ReciterModel>> getReciters({String language = 'ar'}) async => [];

  @override
  Future<List<TimingReadModel>> getTimingReads() async => [];

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async => [1];

  @override
  Future<List<AyahTimingModel>> getAyahTiming({
    required int surahNumber,
    required int readId,
  }) async {
    return timingModels;
  }

  @override
  Future<void> downloadSurahFile({
    required String url,
    required String savePath,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (cancelDownload) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.cancel,
        message: 'Download cancelled',
      );
    }
    if (failDownload) {
      throw const NetworkException('Network failure');
    }

    final file = File(savePath);
    await file.parent.create(recursive: true);
    // Write simulated bytes of specified size
    await file.writeAsBytes(List<int>.filled(simulateDownloadedBytes, 65));
    onProgress?.call(simulateDownloadedBytes, simulateDownloadedBytes);
  }
}

class _FakeCacheDataSource implements AudioCacheDataSource {
  final Map<String, List<AyahTimingModel>> cachedTiming = {};

  @override
  Future<void> cacheAyahTiming(
    int readId,
    int surahNumber,
    List<AyahTimingModel> timings,
  ) async {
    cachedTiming['${readId}_$surahNumber'] = timings;
  }

  @override
  Future<List<AyahTimingModel>?> getCachedAyahTiming(
    int readId,
    int surahNumber,
  ) async {
    return cachedTiming['${readId}_$surahNumber'];
  }

  @override
  Future<void> cacheReciters(List<ReciterModel> reciters) async {}

  @override
  Future<List<ReciterModel>?> getCachedReciters() async => null;

  @override
  Future<void> cacheTimingReadIds(List<int> readIds) async {}

  @override
  Future<List<int>?> getCachedTimingReadIds() async => null;

  @override
  Future<void> cacheTimingSurahIds(int readId, List<int> surahIds) async {}

  @override
  Future<List<int>?> getCachedTimingSurahIds(int readId) async => null;

  @override
  Future<void> clearCache() async {
    cachedTiming.clear();
  }
}

void main() {
  late Directory tempDir;
  late _FakeRemoteDataSource remote;
  late _FakeCacheDataSource cache;
  late AudioRepositoryImpl repository;

  const testMoshaf = Moshaf(
    id: 1,
    name: 'حفص عن عاصم',
    server: 'https://server.mp3quran.net/test/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2],
    hasTiming: true,
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('quran_audio_test_');
    remote = _FakeRemoteDataSource();
    cache = _FakeCacheDataSource();
    repository = AudioRepositoryImpl(
      remoteDataSource: remote,
      cacheDataSource: cache,
      metadataService: const QuranMetadataService(),
      documentsPathProvider: () async => tempDir.path,
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AudioRepositoryImpl — Atomic Download & Integrity', () {
    test(
      'downloads surah atomically, verifies size > 1KB, caches timing JSON',
      () async {
        remote.timingModels = const [
          AyahTimingModel(ayah: 1, startTime: 0, endTime: 3000),
          AyahTimingModel(ayah: 2, startTime: 3000, endTime: 6000),
        ];

        int progressReceived = 0;
        int progressTotal = 0;

        await repository.downloadSurah(
          moshaf: testMoshaf,
          surahNumber: 1,
          onProgress: (received, total) {
            progressReceived = received;
            progressTotal = total;
          },
        );

        expect(progressReceived, 2048);
        expect(progressTotal, 2048);

        final isDownloaded = await repository.isSurahDownloaded(
          readId: testMoshaf.id,
          surahNumber: 1,
        );
        expect(isDownloaded, isTrue);

        // Verify final file exists
        final audioFile = File('${tempDir.path}/quran_audio/1/001.mp3');
        expect(audioFile.existsSync(), isTrue);
        expect(audioFile.lengthSync(), 2048);

        // Verify temp part file was cleaned up / renamed
        final partFile = File('${tempDir.path}/quran_audio/1/001.mp3.part');
        expect(partFile.existsSync(), isFalse);

        // Verify timing JSON file exists on disk alongside audio
        final timingFile = File(
          '${tempDir.path}/quran_audio/1/001.mp3.timing.json',
        );
        expect(timingFile.existsSync(), isTrue);

        // Verify timing was also cached in Hive
        expect(cache.cachedTiming['1_1'], isNotNull);
        expect(cache.cachedTiming['1_1']!.length, 2);
      },
    );

    test(
      'rejects corrupted file smaller than 1024 bytes and cleans up .part file',
      () async {
        remote.simulateDownloadedBytes = 500; // Too small, invalid!

        expect(
          () => repository.downloadSurah(moshaf: testMoshaf, surahNumber: 1),
          throwsA(isA<ServerFailure>()),
        );

        final audioFile = File('${tempDir.path}/quran_audio/1/001.mp3');
        expect(audioFile.existsSync(), isFalse);

        final partFile = File('${tempDir.path}/quran_audio/1/001.mp3.part');
        expect(partFile.existsSync(), isFalse);

        final isDownloaded = await repository.isSurahDownloaded(
          readId: testMoshaf.id,
          surahNumber: 1,
        );
        expect(isDownloaded, isFalse);
      },
    );

    test(
      'handles download cancellation: cleans up temp files and throws GeneralFailure',
      () async {
        remote.cancelDownload = true;

        expect(
          () => repository.downloadSurah(moshaf: testMoshaf, surahNumber: 1),
          throwsA(
            isA<GeneralFailure>().having(
              (f) => f.message,
              'message',
              contains('cancelled'),
            ),
          ),
        );

        final partFile = File('${tempDir.path}/quran_audio/1/001.mp3.part');
        expect(partFile.existsSync(), isFalse);

        final isDownloaded = await repository.isSurahDownloaded(
          readId: testMoshaf.id,
          surahNumber: 1,
        );
        expect(isDownloaded, isFalse);
      },
    );

    test(
      'resolves timing from local JSON file when Hive cache is empty (offline support)',
      () async {
        // 1. Download surah with timing
        remote.timingModels = const [
          AyahTimingModel(ayah: 1, startTime: 0, endTime: 4000),
        ];
        await repository.downloadSurah(moshaf: testMoshaf, surahNumber: 1);

        // 2. Clear Hive cache to simulate fresh offline startup
        await cache.clearCache();
        expect(await cache.getCachedAyahTiming(1, 1), isNull);

        // 3. getAyahTiming should read from disk .timing.json and re-populate cache
        final timings = await repository.getAyahTiming(
          readId: 1,
          surahNumber: 1,
        );
        expect(timings.length, 1);
        expect(timings.first.ayah, 1);
        expect(timings.first.endTimeMs, 4000);
        expect(await cache.getCachedAyahTiming(1, 1), isNotNull);
      },
    );

    test(
      'deleting surah deletes both audio file and timing json file',
      () async {
        remote.timingModels = const [
          AyahTimingModel(ayah: 1, startTime: 0, endTime: 4000),
        ];
        await repository.downloadSurah(moshaf: testMoshaf, surahNumber: 1);

        final audioFile = File('${tempDir.path}/quran_audio/1/001.mp3');
        final timingFile = File(
          '${tempDir.path}/quran_audio/1/001.mp3.timing.json',
        );
        expect(audioFile.existsSync(), isTrue);
        expect(timingFile.existsSync(), isTrue);

        await repository.deleteDownloadedSurah(readId: 1, surahNumber: 1);

        expect(audioFile.existsSync(), isFalse);
        expect(timingFile.existsSync(), isFalse);

        final isDownloaded = await repository.isSurahDownloaded(
          readId: 1,
          surahNumber: 1,
        );
        expect(isDownloaded, isFalse);
      },
    );

    test(
      'cleanOrphanedTempFiles deletes .part and .tmp files and preserves valid files',
      () async {
        final audioDir = Directory('${tempDir.path}/quran_audio/1');
        await audioDir.create(recursive: true);

        final validMp3 = File('${audioDir.path}/001.mp3');
        final validTiming = File('${audioDir.path}/001.mp3.timing.json');
        final orphanPart = File('${audioDir.path}/002.mp3.part');
        final orphanTmp = File('${audioDir.path}/002.mp3.timing.json.tmp');

        await validMp3.writeAsString('audio-bytes');
        await validTiming.writeAsString('timing-json');
        await orphanPart.writeAsString('incomplete-audio');
        await orphanTmp.writeAsString('incomplete-timing');

        final cleanedCount = await repository.cleanOrphanedTempFiles();

        expect(cleanedCount, 2);
        expect(validMp3.existsSync(), isTrue);
        expect(validTiming.existsSync(), isTrue);
        expect(orphanPart.existsSync(), isFalse);
        expect(orphanTmp.existsSync(), isFalse);
      },
    );

    test(
      'cleanOrphanedTempFiles returns 0 when no directory or orphan files exist',
      () async {
        expect(await repository.cleanOrphanedTempFiles(), 0);
      },
    );

    test(
      'getAudioStorageUsageBytes calculates accurate storage bytes',
      () async {
        expect(await repository.getAudioStorageUsageBytes(), 0);

        final audioDir = Directory('${tempDir.path}/quran_audio/1');
        await audioDir.create(recursive: true);

        final file1 = File('${audioDir.path}/001.mp3');
        await file1.writeAsBytes(List<int>.filled(500, 1));
        final file2 = File('${audioDir.path}/002.mp3');
        await file2.writeAsBytes(List<int>.filled(1200, 2));

        final totalBytes = await repository.getAudioStorageUsageBytes();
        expect(totalBytes, 1700);
      },
    );
  });
}
