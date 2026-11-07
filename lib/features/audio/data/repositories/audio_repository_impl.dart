import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:path_provider/path_provider.dart';

/// Implementation of [AudioRepository] managing remote API calls, Hive caching,
/// filesystem audio downloads, and metadata integration.
class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource _remoteDataSource;
  final AudioCacheDataSource _cacheDataSource;
  final QuranMetadataService _metadataService;
  final Future<String> Function() _documentsPathProvider;

  AudioRepositoryImpl({
    required AudioRemoteDataSource remoteDataSource,
    required AudioCacheDataSource cacheDataSource,
    required QuranMetadataService metadataService,
    Future<String> Function()? documentsPathProvider,
  })  : _remoteDataSource = remoteDataSource,
        _cacheDataSource = cacheDataSource,
        _metadataService = metadataService,
        _documentsPathProvider = documentsPathProvider ??
            (() async => (await getApplicationDocumentsDirectory()).path);

  @override
  Future<List<int>> getTimingSupportedMoshafIds({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cached = await _cacheDataSource.getCachedTimingReadIds();
        if (cached != null && cached.isNotEmpty) {
          return cached;
        }
      } catch (_) {
        // Fallback to remote if cache read fails
      }
    }

    try {
      final reads = await _remoteDataSource.getTimingReads();
      final ids = reads.map((r) => r.id).toList();
      await _cacheDataSource.cacheTimingReadIds(ids);
      return ids;
    } on AppException catch (e) {
      // If network fails, attempt cache fallback even on forceRefresh
      final cached = await _cacheDataSource.getCachedTimingReadIds();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      throw ServerFailure(e.message, e.code);
    } catch (e) {
      final cached = await _cacheDataSource.getCachedTimingReadIds();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      throw GeneralFailure('Failed to fetch timing supported moshafs: $e');
    }
  }

  @override
  Future<List<Reciter>> getReciters({bool forceRefresh = false}) async {
    // 1. Try local cache first if forceRefresh is false
    if (!forceRefresh) {
      try {
        final cachedModels = await _cacheDataSource.getCachedReciters();
        if (cachedModels != null && cachedModels.isNotEmpty) {
          final timingIds = await _getSafeTimingIds();
          return cachedModels
              .map((m) => m.toEntity(timingSupportedMoshafIds: timingIds))
              .toList();
        }
      } catch (_) {
        // Fallback to remote if cache read fails
      }
    }

    // 2. Fetch from remote
    try {
      final timingIds = await _getSafeTimingIds();
      final models = await _remoteDataSource.getReciters();
      await _cacheDataSource.cacheReciters(models);

      return models
          .map((m) => m.toEntity(timingSupportedMoshafIds: timingIds))
          .toList();
    } on AppException catch (e) {
      // 3. Fallback to cache if network call fails
      final cachedModels = await _cacheDataSource.getCachedReciters();
      if (cachedModels != null && cachedModels.isNotEmpty) {
        final timingIds = await _getSafeTimingIds();
        return cachedModels
            .map((m) => m.toEntity(timingSupportedMoshafIds: timingIds))
            .toList();
      }
      throw ServerFailure(e.message, e.code);
    } catch (e) {
      final cachedModels = await _cacheDataSource.getCachedReciters();
      if (cachedModels != null && cachedModels.isNotEmpty) {
        final timingIds = await _getSafeTimingIds();
        return cachedModels
            .map((m) => m.toEntity(timingSupportedMoshafIds: timingIds))
            .toList();
      }
      throw GeneralFailure('Failed to fetch reciters: $e');
    }
  }

  @override
  Future<Reciter?> getReciterById(int reciterId) async {
    final reciters = await getReciters();
    for (final r in reciters) {
      if (r.id == reciterId) return r;
    }
    return null;
  }

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async {
    try {
      final cached = await _cacheDataSource.getCachedTimingSurahIds(readId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    } catch (_) {}

    try {
      final surahIds = await _remoteDataSource.getTimingSurahListForRead(readId);
      await _cacheDataSource.cacheTimingSurahIds(readId, surahIds);
      return surahIds;
    } catch (_) {
      final cached = await _cacheDataSource.getCachedTimingSurahIds(readId);
      if (cached != null) return cached;
      return const [];
    }
  }

  @override
  Future<List<AyahTiming>> getAyahTiming({
    required int readId,
    required int surahNumber,
  }) async {
    // 1. Check local cache
    try {
      final cached = await _cacheDataSource.getCachedAyahTiming(readId, surahNumber);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((m) => m.toEntity()).toList();
      }
    } catch (_) {}

    // 2. Fetch from remote API
    try {
      final models = await _remoteDataSource.getAyahTiming(
        surahNumber: surahNumber,
        readId: readId,
      );

      if (models.isNotEmpty) {
        await _cacheDataSource.cacheAyahTiming(readId, surahNumber, models);
      }

      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      // If timing is unavailable or network error occurs, return empty list
      // so audio can play without misleading highlight.
      final cached = await _cacheDataSource.getCachedAyahTiming(readId, surahNumber);
      if (cached != null) {
        return cached.map((m) => m.toEntity()).toList();
      }
      return const [];
    }
  }

  @override
  Future<List<ReciterSurah>> getSurahsForMoshaf({
    required int reciterId,
    required Moshaf moshaf,
  }) async {
    List<int> timingSurahs = const [];
    if (moshaf.hasTiming) {
      timingSurahs = await getTimingSurahListForRead(moshaf.id);
    }

    final List<ReciterSurah> surahs = [];
    for (final surahNum in moshaf.surahList) {
      final surahName = _metadataService.getSurahNameArabic(surahNum);
      final juzNumber = _metadataService.getJuzNumber(surahNum, 1);
      final verseCount = _metadataService.getVerseCount(surahNum);
      final audioUrl = moshaf.getSurahAudioUrl(surahNum);
      final isDownloaded = await isSurahDownloaded(
        readId: moshaf.id,
        surahNumber: surahNum,
      );
      final localPath = isDownloaded
          ? await _getSurahFilePath(moshaf.id, surahNum)
          : null;
      final hasTiming = timingSurahs.contains(surahNum);

      surahs.add(
        ReciterSurah(
          surahNumber: surahNum,
          surahName: surahName,
          juzNumber: juzNumber,
          verseCount: verseCount,
          audioUrl: audioUrl,
          isDownloaded: isDownloaded,
          localFilePath: localPath,
          hasTiming: hasTiming,
        ),
      );
    }

    return surahs;
  }

  @override
  Future<bool> isSurahDownloaded({
    required int readId,
    required int surahNumber,
  }) async {
    try {
      final filePath = await _getSurahFilePath(readId, surahNumber);
      return File(filePath).existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> getPlayableAudioUri({
    required Moshaf moshaf,
    required int surahNumber,
  }) async {
    final isDownloaded = await isSurahDownloaded(
      readId: moshaf.id,
      surahNumber: surahNumber,
    );

    if (isDownloaded) {
      return _getSurahFilePath(moshaf.id, surahNumber);
    }

    return moshaf.getSurahAudioUrl(surahNumber);
  }

  @override
  Future<void> downloadSurah({
    required Moshaf moshaf,
    required int surahNumber,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    final finalPath = await _getSurahFilePath(moshaf.id, surahNumber);
    final tempPath = '$finalPath.tmp';
    final url = moshaf.getSurahAudioUrl(surahNumber);

    try {
      // Ensure target directory exists
      final dir = File(finalPath).parent;
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      // Download into temporary file first to guarantee atomic write
      await _remoteDataSource.downloadSurahFile(
        url: url,
        savePath: tempPath,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

      final tempFile = File(tempPath);
      if (tempFile.existsSync()) {
        await tempFile.rename(finalPath);
      }
    } on AppException catch (e) {
      _cleanUpTempFile(tempPath);
      throw ServerFailure(e.message, e.code);
    } catch (e) {
      _cleanUpTempFile(tempPath);
      throw GeneralFailure('Failed to download surah $surahNumber: $e');
    }
  }

  @override
  Future<void> deleteDownloadedSurah({
    required int readId,
    required int surahNumber,
  }) async {
    try {
      final filePath = await _getSurahFilePath(readId, surahNumber);
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      throw CacheFailure('Failed to delete downloaded surah: $e');
    }
  }

  Future<String> _getSurahFilePath(int readId, int surahNumber) async {
    final baseDir = await _documentsPathProvider();
    final paddedSurah = surahNumber.toString().padLeft(3, '0');
    return '$baseDir/quran_audio/$readId/$paddedSurah.mp3';
  }

  Future<Set<int>> _getSafeTimingIds() async {
    try {
      final ids = await getTimingSupportedMoshafIds();
      return ids.toSet();
    } catch (_) {
      return const <int>{};
    }
  }

  void _cleanUpTempFile(String tempPath) {
    try {
      final tempFile = File(tempPath);
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    } catch (_) {}
  }
}
