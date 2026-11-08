import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';

/// Status of offline download for a single surah.
enum SurahDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  failed,
}

/// Helper model grouping surahs under a starting Juz for Reference 36.
class ReciterJuzGroup {
  final int juzNumber;
  final List<ReciterSurah> surahs;

  const ReciterJuzGroup({
    required this.juzNumber,
    required this.surahs,
  });
}

/// Base state for the reciter surahs and download screen (Reference 36).
abstract class ReciterSurahsState {
  const ReciterSurahsState();
}

/// Initial uninitialized state.
class ReciterSurahsInitial extends ReciterSurahsState {
  const ReciterSurahsInitial();
}

/// Loading reciter metadata, surah list, and local download statuses.
class ReciterSurahsLoading extends ReciterSurahsState {
  const ReciterSurahsLoading();
}

/// Successfully loaded reciter and surahs grouped by Juz.
class ReciterSurahsLoaded extends ReciterSurahsState {
  final Reciter reciter;
  final Moshaf moshaf;
  final List<ReciterSurah> surahs;
  final List<ReciterJuzGroup> juzGroups;
  final Map<int, SurahDownloadStatus> downloadStatuses;
  final Map<int, double> downloadProgresses;
  final Map<int, String> errorMessages;

  const ReciterSurahsLoaded({
    required this.reciter,
    required this.moshaf,
    required this.surahs,
    required this.juzGroups,
    required this.downloadStatuses,
    this.downloadProgresses = const {},
    this.errorMessages = const {},
  });

  ReciterSurahsLoaded copyWith({
    Reciter? reciter,
    Moshaf? moshaf,
    List<ReciterSurah>? surahs,
    List<ReciterJuzGroup>? juzGroups,
    Map<int, SurahDownloadStatus>? downloadStatuses,
    Map<int, double>? downloadProgresses,
    Map<int, String>? errorMessages,
  }) {
    return ReciterSurahsLoaded(
      reciter: reciter ?? this.reciter,
      moshaf: moshaf ?? this.moshaf,
      surahs: surahs ?? this.surahs,
      juzGroups: juzGroups ?? this.juzGroups,
      downloadStatuses: downloadStatuses ?? this.downloadStatuses,
      downloadProgresses: downloadProgresses ?? this.downloadProgresses,
      errorMessages: errorMessages ?? this.errorMessages,
    );
  }
}

/// Failure state when reciter or surahs cannot be loaded.
class ReciterSurahsFailure extends ReciterSurahsState {
  final String message;

  const ReciterSurahsFailure(this.message);
}

