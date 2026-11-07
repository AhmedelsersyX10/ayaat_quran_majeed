import '../entities/ayah_timing.dart';
import '../entities/moshaf.dart';
import '../entities/reciter.dart';
import '../entities/reciter_surah.dart';

/// Domain contract for managing Quran audio reciters, moshafs, ayah timing,
/// and surah download operations.
///
/// Pure Dart — no Flutter framework dependencies.
abstract class AudioRepository {
  /// Retrieves the list of all Quran reciters and their moshafs.
  ///
  /// Offline-First: Checks local cache if network is unavailable or if [forceRefresh] is false.
  /// Moshafs are enriched with [Moshaf.hasTiming] according to verified timing coverage.
  Future<List<Reciter>> getReciters({bool forceRefresh = false});

  /// Retrieves a specific reciter by [reciterId].
  Future<Reciter?> getReciterById(int reciterId);

  /// Retrieves the list of moshaf IDs that support verified ayah-level timing.
  Future<List<int>> getTimingSupportedMoshafIds({bool forceRefresh = false});

  /// Retrieves the list of surah numbers (1 to 114) that have timing data for [readId].
  Future<List<int>> getTimingSurahListForRead(int readId);

  /// Retrieves ayah-level timing intervals for [surahNumber] in moshaf [readId].
  ///
  /// Returns an empty list if timing is unavailable (audio will play without highlight).
  Future<List<AyahTiming>> getAyahTiming({
    required int readId,
    required int surahNumber,
  });

  /// Retrieves all surahs available for [moshaf] enriched with metadata,
  /// download status, and timing availability for the Reciter page (Reference 36).
  Future<List<ReciterSurah>> getSurahsForMoshaf({
    required int reciterId,
    required Moshaf moshaf,
  });

  /// Checks whether surah [surahNumber] in moshaf [readId] is downloaded locally.
  Future<bool> isSurahDownloaded({
    required int readId,
    required int surahNumber,
  });

  /// Resolves the playable URI: local file URI if downloaded, remote streaming URL otherwise.
  Future<String> getPlayableAudioUri({
    required Moshaf moshaf,
    required int surahNumber,
  });

  /// Downloads surah [surahNumber] for [moshaf] to local storage.
  ///
  /// Notifies [onProgress] with received bytes and total bytes.
  Future<void> downloadSurah({
    required Moshaf moshaf,
    required int surahNumber,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  });

  /// Deletes the downloaded surah file from local storage.
  Future<void> deleteDownloadedSurah({
    required int readId,
    required int surahNumber,
  });
}
