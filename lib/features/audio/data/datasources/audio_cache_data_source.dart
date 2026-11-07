import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';

import '../models/ayah_timing_model.dart';
import '../models/reciter_model.dart';

/// Contract for local caching of reciters, timing metadata, and ayah timings.
abstract class AudioCacheDataSource {
  /// Caches the full reciters list.
  Future<void> cacheReciters(List<ReciterModel> reciters);

  /// Retrieves cached reciters, or `null` if not cached.
  Future<List<ReciterModel>?> getCachedReciters();

  /// Caches list of moshaf IDs that support timing.
  Future<void> cacheTimingReadIds(List<int> readIds);

  /// Retrieves cached timing read IDs, or `null` if not cached.
  Future<List<int>?> getCachedTimingReadIds();

  /// Caches list of surah numbers with timing for [readId].
  Future<void> cacheTimingSurahIds(int readId, List<int> surahIds);

  /// Retrieves cached surah numbers with timing for [readId], or `null` if not cached.
  Future<List<int>?> getCachedTimingSurahIds(int readId);

  /// Caches ayah timing entries for [surahNumber] in [readId].
  Future<void> cacheAyahTiming(
    int readId,
    int surahNumber,
    List<AyahTimingModel> timings,
  );

  /// Retrieves cached ayah timing for [surahNumber] in [readId], or `null` if not cached.
  Future<List<AyahTimingModel>?> getCachedAyahTiming(
    int readId,
    int surahNumber,
  );

  /// Clears all cached audio data from disk.
  Future<void> clearCache();
}

/// Implementation of [AudioCacheDataSource] backed by Hive document storage.
class AudioCacheDataSourceImpl implements AudioCacheDataSource {
  final HiveStorageService _hiveStorage;

  const AudioCacheDataSourceImpl({required HiveStorageService hiveStorage})
      : _hiveStorage = hiveStorage;

  static const String _keyReciters = 'cache_reciters_list';
  static const String _keyTimingReadIds = 'cache_timing_read_ids';
  static String _keyTimingSurahs(int readId) => 'cache_timing_surahs_$readId';
  static String _keyAyahTiming(int readId, int surah) =>
      'cache_ayah_timing_${readId}_$surah';

  Future<dynamic> _getBox() async {
    return _hiveStorage.openBox<dynamic>(AppBoxNames.audioCache);
  }

  @override
  Future<void> cacheReciters(List<ReciterModel> reciters) async {
    try {
      final box = await _getBox();
      final list = reciters.map((r) => r.toJson()).toList();
      await box.put(_keyReciters, list);
    } catch (e) {
      throw CacheException('Failed to cache reciters: $e');
    }
  }

  @override
  Future<List<ReciterModel>?> getCachedReciters() async {
    try {
      final box = await _getBox();
      final data = box.get(_keyReciters);
      if (data is List) {
        return data
            .map((item) => ReciterModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read cached reciters: $e');
    }
  }

  @override
  Future<void> cacheTimingReadIds(List<int> readIds) async {
    try {
      final box = await _getBox();
      await box.put(_keyTimingReadIds, readIds);
    } catch (e) {
      throw CacheException('Failed to cache timing read IDs: $e');
    }
  }

  @override
  Future<List<int>?> getCachedTimingReadIds() async {
    try {
      final box = await _getBox();
      final data = box.get(_keyTimingReadIds);
      if (data is List) {
        return data.map((e) => e as int).toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read cached timing read IDs: $e');
    }
  }

  @override
  Future<void> cacheTimingSurahIds(int readId, List<int> surahIds) async {
    try {
      final box = await _getBox();
      await box.put(_keyTimingSurahs(readId), surahIds);
    } catch (e) {
      throw CacheException('Failed to cache timing surah IDs for read $readId: $e');
    }
  }

  @override
  Future<List<int>?> getCachedTimingSurahIds(int readId) async {
    try {
      final box = await _getBox();
      final data = box.get(_keyTimingSurahs(readId));
      if (data is List) {
        return data.map((e) => e as int).toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read cached timing surah IDs for read $readId: $e');
    }
  }

  @override
  Future<void> cacheAyahTiming(
    int readId,
    int surahNumber,
    List<AyahTimingModel> timings,
  ) async {
    try {
      final box = await _getBox();
      final list = timings.map((t) => t.toJson()).toList();
      await box.put(_keyAyahTiming(readId, surahNumber), list);
    } catch (e) {
      throw CacheException(
        'Failed to cache ayah timing for read $readId surah $surahNumber: $e',
      );
    }
  }

  @override
  Future<List<AyahTimingModel>?> getCachedAyahTiming(
    int readId,
    int surahNumber,
  ) async {
    try {
      final box = await _getBox();
      final data = box.get(_keyAyahTiming(readId, surahNumber));
      if (data is List) {
        return data
            .map((item) => AyahTimingModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException(
        'Failed to read cached ayah timing for read $readId surah $surahNumber: $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear audio cache: $e');
    }
  }
}
