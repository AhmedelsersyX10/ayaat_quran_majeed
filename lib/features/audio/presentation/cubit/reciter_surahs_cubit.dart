import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'reciter_surahs_state.dart';

/// Cubit managing surahs listing grouped by Juz, download operations,
/// progress notifications, cancellation, and retry for Reference 36.
class ReciterSurahsCubit extends Cubit<ReciterSurahsState> {
  final AudioRepository _audioRepository;
  final Map<int, CancelToken> _cancelTokens = {};

  ReciterSurahsCubit({
    required AudioRepository audioRepository,
  })  : _audioRepository = audioRepository,
        super(const ReciterSurahsInitial());

  /// Loads reciter info and available surahs for [reciterId] and [moshafId],
  /// grouped by starting Juz.
  Future<void> loadSurahs({
    required int reciterId,
    int? moshafId,
  }) async {
    emit(const ReciterSurahsLoading());

    try {
      var reciter = await _audioRepository.getReciterById(reciterId);
      if (reciter == null) {
        final all = await _audioRepository.getReciters();
        for (final r in all) {
          if (r.id == reciterId) {
            reciter = r;
            break;
          }
        }
      }

      if (reciter == null) {
        emit(const ReciterSurahsFailure('Reciter not found'));
        return;
      }

      final nonNullReciter = reciter;
      final Moshaf moshaf;
      if (moshafId != null) {
        moshaf = nonNullReciter.moshafs.firstWhere(
          (m) => m.id == moshafId,
          orElse: () => nonNullReciter.defaultMoshaf ?? nonNullReciter.moshafs.first,
        );
      } else {
        moshaf = nonNullReciter.defaultMoshaf ?? nonNullReciter.moshafs.first;
      }

      final surahs = await _audioRepository.getSurahsForMoshaf(
        reciterId: reciter.id,
        moshaf: moshaf,
      );

      final Map<int, SurahDownloadStatus> downloadStatuses = {};
      for (final s in surahs) {
        downloadStatuses[s.surahNumber] = s.isDownloaded
            ? SurahDownloadStatus.downloaded
            : SurahDownloadStatus.notDownloaded;
      }

      final juzGroups = _groupByJuz(surahs);

      emit(ReciterSurahsLoaded(
        reciter: reciter,
        moshaf: moshaf,
        surahs: surahs,
        juzGroups: juzGroups,
        downloadStatuses: downloadStatuses,
      ));
    } on Failure catch (e) {
      emit(ReciterSurahsFailure(e.message));
    } catch (e) {
      emit(ReciterSurahsFailure(e.toString()));
    }
  }

  /// Downloads [surahNumber] for the currently loaded reciter and moshaf.
  Future<void> downloadSurah(int surahNumber) async {
    final currentState = state;
    if (currentState is! ReciterSurahsLoaded) return;

    if (currentState.downloadStatuses[surahNumber] ==
        SurahDownloadStatus.downloading) {
      return;
    }

    final cancelToken = CancelToken();
    _cancelTokens[surahNumber] = cancelToken;

    final updatedStatuses =
        Map<int, SurahDownloadStatus>.from(currentState.downloadStatuses)
          ..[surahNumber] = SurahDownloadStatus.downloading;
    final updatedProgresses =
        Map<int, double>.from(currentState.downloadProgresses)
          ..[surahNumber] = 0.0;
    final updatedErrors =
        Map<int, String>.from(currentState.errorMessages)..remove(surahNumber);

    emit(currentState.copyWith(
      downloadStatuses: updatedStatuses,
      downloadProgresses: updatedProgresses,
      errorMessages: updatedErrors,
    ));

    try {
      await _audioRepository.downloadSurah(
        moshaf: currentState.moshaf,
        surahNumber: surahNumber,
        onProgress: (received, total) {
          if (isClosed) return;
          final current = state;
          if (current is ReciterSurahsLoaded && total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            final newProgresses =
                Map<int, double>.from(current.downloadProgresses)
                  ..[surahNumber] = progress;
            emit(current.copyWith(downloadProgresses: newProgresses));
          }
        },
        cancelToken: cancelToken,
      );

      _cancelTokens.remove(surahNumber);

      if (isClosed) return;
      final current = state;
      if (current is ReciterSurahsLoaded) {
        final finalStatuses =
            Map<int, SurahDownloadStatus>.from(current.downloadStatuses)
              ..[surahNumber] = SurahDownloadStatus.downloaded;
        final finalProgresses =
            Map<int, double>.from(current.downloadProgresses)
              ..[surahNumber] = 1.0;

        // Also update the surahs list localFilePath/isDownloaded
        final updatedSurahs = current.surahs.map((s) {
          if (s.surahNumber == surahNumber) {
            return s.copyWith(isDownloaded: true);
          }
          return s;
        }).toList();

        emit(current.copyWith(
          surahs: updatedSurahs,
          juzGroups: _groupByJuz(updatedSurahs),
          downloadStatuses: finalStatuses,
          downloadProgresses: finalProgresses,
        ));
      }
    } catch (e) {
      _cancelTokens.remove(surahNumber);

      if (isClosed) return;
      final current = state;
      if (current is ReciterSurahsLoaded) {
        final isCancelled = cancelToken.isCancelled ||
            (e is Failure && e.message.toLowerCase().contains('cancel'));

        final finalStatuses =
            Map<int, SurahDownloadStatus>.from(current.downloadStatuses)
              ..[surahNumber] = isCancelled
                  ? SurahDownloadStatus.notDownloaded
                  : SurahDownloadStatus.failed;

        final finalErrors = Map<int, String>.from(current.errorMessages);
        if (!isCancelled) {
          finalErrors[surahNumber] =
              e is Failure ? e.message : e.toString();
        }

        emit(current.copyWith(
          downloadStatuses: finalStatuses,
          errorMessages: finalErrors,
        ));
      }
    }
  }

  /// Cancels an active in-flight download for [surahNumber].
  void cancelDownload(int surahNumber) {
    if (_cancelTokens.containsKey(surahNumber)) {
      _cancelTokens[surahNumber]?.cancel('User cancelled download');
      _cancelTokens.remove(surahNumber);
    }

    final current = state;
    if (current is ReciterSurahsLoaded) {
      final updatedStatuses =
          Map<int, SurahDownloadStatus>.from(current.downloadStatuses)
            ..[surahNumber] = SurahDownloadStatus.notDownloaded;
      final updatedProgresses =
          Map<int, double>.from(current.downloadProgresses)
            ..remove(surahNumber);

      emit(current.copyWith(
        downloadStatuses: updatedStatuses,
        downloadProgresses: updatedProgresses,
      ));
    }
  }

  /// Deletes a previously downloaded surah from local storage.
  Future<void> deleteDownloadedSurah(int surahNumber) async {
    final current = state;
    if (current is! ReciterSurahsLoaded) return;

    try {
      await _audioRepository.deleteDownloadedSurah(
        readId: current.moshaf.id,
        surahNumber: surahNumber,
      );

      final updatedStatuses =
          Map<int, SurahDownloadStatus>.from(current.downloadStatuses)
            ..[surahNumber] = SurahDownloadStatus.notDownloaded;
      final updatedProgresses =
          Map<int, double>.from(current.downloadProgresses)
            ..remove(surahNumber);

      final updatedSurahs = current.surahs.map((s) {
        if (s.surahNumber == surahNumber) {
          return s.copyWith(isDownloaded: false, localFilePath: null);
        }
        return s;
      }).toList();

      emit(current.copyWith(
        surahs: updatedSurahs,
        juzGroups: _groupByJuz(updatedSurahs),
        downloadStatuses: updatedStatuses,
        downloadProgresses: updatedProgresses,
      ));
    } catch (_) {}
  }

  /// Groups surahs by starting Juz number.
  List<ReciterJuzGroup> _groupByJuz(List<ReciterSurah> surahs) {
    final Map<int, List<ReciterSurah>> groupsMap = {};
    for (final s in surahs) {
      groupsMap.putIfAbsent(s.juzNumber, () => []).add(s);
    }

    final sortedKeys = groupsMap.keys.toList()..sort();
    return sortedKeys
        .map((juz) => ReciterJuzGroup(
              juzNumber: juz,
              surahs: groupsMap[juz]!,
            ))
        .toList();
  }

  @override
  Future<void> close() {
    for (final token in _cancelTokens.values) {
      token.cancel('Cubit closed');
    }
    _cancelTokens.clear();
    return super.close();
  }
}
