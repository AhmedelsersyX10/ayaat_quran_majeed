import 'dart:io';

import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/ayah_timing_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/moshaf_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/reciter_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late HiveStorageService hiveStorage;
  late AudioCacheDataSource cacheDataSource;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('audio_cache_test_');
    hiveStorage = HiveStorageServiceImpl();
    await hiveStorage.init(storagePath: tempDir.path);
    cacheDataSource = AudioCacheDataSourceImpl(hiveStorage: hiveStorage);
  });

  tearDown(() async {
    await hiveStorage.closeAll();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AudioCacheDataSource Tests', () {
    test('returns null when reciters cache is empty', () async {
      final cached = await cacheDataSource.getCachedReciters();
      expect(cached, isNull);
    });

    test('caches and retrieves reciters list accurately', () async {
      const reciters = [
        ReciterModel(
          id: 1,
          name: 'المنشاوي',
          letter: 'م',
          moshafs: [
            MoshafModel(
              id: 112,
              name: 'مرتل',
              server: 'https://server.com/',
              surahTotal: 114,
              moshafType: 1,
              surahList: [1, 2, 3],
            ),
          ],
        ),
      ];

      await cacheDataSource.cacheReciters(reciters);
      final retrieved = await cacheDataSource.getCachedReciters();

      expect(retrieved, isNotNull);
      expect(retrieved!.length, equals(1));
      expect(retrieved.first.id, equals(1));
      expect(retrieved.first.name, equals('المنشاوي'));
      expect(retrieved.first.moshafs.first.id, equals(112));
      expect(retrieved.first.moshafs.first.surahList, equals([1, 2, 3]));
    });

    test('caches and retrieves timing read IDs list', () async {
      final ids = [1, 3, 4, 118, 123];

      await cacheDataSource.cacheTimingReadIds(ids);
      final retrieved = await cacheDataSource.getCachedTimingReadIds();

      expect(retrieved, equals(ids));
    });

    test('caches and retrieves timing surah IDs for a read', () async {
      final surahs = [1, 2, 3, 114];

      await cacheDataSource.cacheTimingSurahIds(1, surahs);
      final retrieved = await cacheDataSource.getCachedTimingSurahIds(1);

      expect(retrieved, equals(surahs));

      final miss = await cacheDataSource.getCachedTimingSurahIds(999);
      expect(miss, isNull);
    });

    test('caches and retrieves ayah timing entries', () async {
      const timings = [
        AyahTimingModel(ayah: 1, startTime: 0, endTime: 5000),
        AyahTimingModel(ayah: 2, startTime: 5000, endTime: 12000),
      ];

      await cacheDataSource.cacheAyahTiming(118, 1, timings);
      final retrieved = await cacheDataSource.getCachedAyahTiming(118, 1);

      expect(retrieved, isNotNull);
      expect(retrieved!.length, equals(2));
      expect(retrieved[0].ayah, equals(1));
      expect(retrieved[0].startTime, equals(0));
      expect(retrieved[1].ayah, equals(2));
      expect(retrieved[1].endTime, equals(12000));
    });

    test('clearCache empties all stored keys', () async {
      await cacheDataSource.cacheTimingReadIds([1, 2, 3]);
      await cacheDataSource.clearCache();

      final readIds = await cacheDataSource.getCachedTimingReadIds();
      expect(readIds, isNull);
    });
  });
}
