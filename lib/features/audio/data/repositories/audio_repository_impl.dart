import 'dart:convert';
import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/network/cancellation_token.dart';
import 'package:ayaat_quran_majeed/core/network/cancellation_token_dio_adapter.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/ayah_timing_model.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Implementation of [AudioRepository] managing remote API calls, Hive caching,
/// filesystem audio downloads, and metadata integration.
class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource _remoteDataSource;
  final AudioCacheDataSource _cacheDataSource;
  final QuranMetadataService _metadataService;
  final AppPreferences? _preferences;
  final Future<String> Function() _documentsPathProvider;

  AudioRepositoryImpl({
    required AudioRemoteDataSource remoteDataSource,
    required AudioCacheDataSource cacheDataSource,
    required QuranMetadataService metadataService,
    AppPreferences? preferences,
    Future<String> Function()? documentsPathProvider,
  }) : _remoteDataSource = remoteDataSource,
       _cacheDataSource = cacheDataSource,
       _metadataService = metadataService,
       _preferences = preferences,
       _documentsPathProvider =
           documentsPathProvider ??
           (() async => (await getApplicationDocumentsDirectory()).path);

  @override
  Future<List<int>> getTimingSupportedMoshafIds({
    bool forceRefresh = false,
  }) async {
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
      final surahIds = await _remoteDataSource.getTimingSurahListForRead(
        readId,
      );
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
    // 1. Check local Hive cache
    try {
      final cached = await _cacheDataSource.getCachedAyahTiming(
        readId,
        surahNumber,
      );
      if (cached != null && cached.isNotEmpty) {
        return cached.map((m) => m.toEntity()).toList();
      }
    } catch (_) {}

    // 2. Check local timing JSON file on disk (offline storage)
    try {
      final audioPath = await _getSurahFilePath(readId, surahNumber);
      final timingFile = File('$audioPath.timing.json');
      if (timingFile.existsSync()) {
        final content = await timingFile.readAsString();
        final List<dynamic> list = jsonDecode(content) as List<dynamic>;
        final models = list
            .map(
              (item) => AyahTimingModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        if (models.isNotEmpty) {
          // Re-populate cache for faster subsequent lookups
          await _cacheDataSource.cacheAyahTiming(readId, surahNumber, models);
          return models.map((m) => m.toEntity()).toList();
        }
      }
    } catch (_) {}

    // 3. Fetch from remote API
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
      final cached = await _cacheDataSource.getCachedAyahTiming(
        readId,
        surahNumber,
      );
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
      final file = File(filePath);
      return file.existsSync() && file.lengthSync() > 1024;
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
    AppCancellationToken? cancelToken,
  }) async {
    final finalPath = await _getSurahFilePath(moshaf.id, surahNumber);
    final tempAudioPath = '$finalPath.part';
    final finalTimingPath = '$finalPath.timing.json';
    final tempTimingPath = '$finalTimingPath.tmp';
    final url = moshaf.getSurahAudioUrl(surahNumber);

    try {
      // 1. Ensure target directory exists (app-safe storage)
      final dir = File(finalPath).parent;
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      // 2. Download audio into temporary partial file first
      int reportedTotal = 0;
      await _remoteDataSource.downloadSurahFile(
        url: url,
        savePath: tempAudioPath,
        onProgress: (received, total) {
          reportedTotal = total;
          onProgress?.call(received, total);
        },
        cancelToken: cancelToken?.toDioCancelToken(),
      );

      // 3. Integrity and size validation
      final tempAudioFile = File(tempAudioPath);
      if (!tempAudioFile.existsSync()) {
        throw const ServerException(
          'Downloaded file is missing',
          'DOWNLOAD_MISSING',
        );
      }

      final fileSize = tempAudioFile.lengthSync();
      // Sanity threshold: genuine MP3 should be > 1KB (not empty or short HTML error)
      if (fileSize < 1024) {
        _cleanUpTempFile(tempAudioPath);
        throw const ServerException(
          'Downloaded file is corrupted or too small',
          'CORRUPTED_FILE',
        );
      }

      if (reportedTotal > 0 && fileSize < reportedTotal) {
        _cleanUpTempFile(tempAudioPath);
        throw const ServerException(
          'Incomplete download',
          'INCOMPLETE_DOWNLOAD',
        );
      }

      // 4. Download and cache timing JSON alongside matching audio
      if (moshaf.hasTiming) {
        try {
          final timings = await _remoteDataSource.getAyahTiming(
            surahNumber: surahNumber,
            readId: moshaf.id,
          );
          if (timings.isNotEmpty) {
            // Write to disk alongside audio
            final jsonStr = jsonEncode(timings.map((t) => t.toJson()).toList());
            final timingTempFile = File(tempTimingPath);
            await timingTempFile.writeAsString(jsonStr, flush: true);
            if (timingTempFile.existsSync()) {
              await timingTempFile.rename(finalTimingPath);
            }
            // Also cache in memory / Hive
            await _cacheDataSource.cacheAyahTiming(
              moshaf.id,
              surahNumber,
              timings,
            );
          }
        } catch (_) {
          // If timing fetch fails remotely, proceed with audio
        }
      }

      // 5. Atomic completion: rename temp file to final audio path
      await tempAudioFile.rename(finalPath);
    } on DioException catch (e) {
      _cleanUpTempFile(tempAudioPath);
      _cleanUpTempFile(tempTimingPath);
      if (e.type == DioExceptionType.cancel) {
        throw const GeneralFailure('Download cancelled');
      }
      throw ServerFailure(e.message ?? 'Download failed', e.type.name);
    } on FileSystemException catch (e) {
      _cleanUpTempFile(tempAudioPath);
      _cleanUpTempFile(tempTimingPath);
      throw CacheFailure('Storage error: ${e.message}');
    } on AppException catch (e) {
      _cleanUpTempFile(tempAudioPath);
      _cleanUpTempFile(tempTimingPath);
      throw ServerFailure(e.message, e.code);
    } catch (e) {
      _cleanUpTempFile(tempAudioPath);
      _cleanUpTempFile(tempTimingPath);
      if (e is Failure) rethrow;
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
      final audioFile = File(filePath);
      if (audioFile.existsSync()) {
        await audioFile.delete();
      }
      final timingFile = File('$filePath.timing.json');
      if (timingFile.existsSync()) {
        await timingFile.delete();
      }
    } catch (e) {
      throw CacheFailure('Failed to delete downloaded surah: $e');
    }
  }

  @override
  Future<int> cleanOrphanedTempFiles() async {
    try {
      final baseDir = await _documentsPathProvider();
      final audioBase = Directory('$baseDir/quran_audio');
      if (!audioBase.existsSync()) return 0;

      int cleanedCount = 0;
      final entities = audioBase.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          final path = entity.path;
          if (path.endsWith('.part') || path.endsWith('.tmp')) {
            try {
              entity.deleteSync();
              cleanedCount++;
            } catch (_) {}
          }
        }
      }
      return cleanedCount;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getAudioStorageUsageBytes() async {
    try {
      final baseDir = await _documentsPathProvider();
      final audioBase = Directory('$baseDir/quran_audio');
      if (!audioBase.existsSync()) return 0;

      int totalBytes = 0;
      final entities = audioBase.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          try {
            totalBytes += entity.lengthSync();
          } catch (_) {}
        }
      }
      return totalBytes;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Reciter?> getSelectedReciter() async {
    final reciters = await getReciters();
    if (reciters.isEmpty) return null;

    final savedId = _preferences?.selectedReciterId;
    if (savedId != null) {
      for (final r in reciters) {
        if (r.id == savedId) return r;
      }
    }

    // Default: prioritize Mahmoud Khalil Al-Hosary with timing (matching ref 05)
    for (final r in reciters) {
      if (r.hasAnyTimingSupport &&
          (r.name.contains('الحصري') || r.name.contains('حصري'))) {
        return r;
      }
    }

    // Fallback: first reciter with timing support
    for (final r in reciters) {
      if (r.hasAnyTimingSupport) return r;
    }

    // Ultimate fallback: first reciter in list
    return reciters.first;
  }

  @override
  Future<Moshaf?> getSelectedMoshaf() async {
    final reciter = await getSelectedReciter();
    if (reciter == null || reciter.moshafs.isEmpty) return null;

    final savedMoshafId = _preferences?.selectedMoshafId;
    if (savedMoshafId != null) {
      for (final m in reciter.moshafs) {
        if (m.id == savedMoshafId) return m;
      }
    }

    // Fallback: reciter's default moshaf (prioritizes timing)
    return reciter.defaultMoshaf;
  }

  @override
  Future<void> setSelectedReciterAndMoshaf({
    required int reciterId,
    required int moshafId,
  }) async {
    try {
      if (_preferences != null) {
        await _preferences.setSelectedReciterId(reciterId);
        await _preferences.setSelectedMoshafId(moshafId);
      }
    } catch (e) {
      throw CacheFailure('Failed to save selected reciter and moshaf: $e');
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
