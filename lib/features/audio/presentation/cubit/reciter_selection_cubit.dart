import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'reciter_selection_state.dart';

/// Cubit managing reciter list retrieval, qualified reciters filtering (timing policy 0.01),
/// and persistence of the selected reciter and moshaf edition.
class ReciterSelectionCubit extends Cubit<ReciterSelectionState> {
  final AudioRepository _audioRepository;

  ReciterSelectionCubit({
    required AudioRepository audioRepository,
  })  : _audioRepository = audioRepository,
        super(const ReciterSelectionInitial());

  /// Loads reciters, filters for only those meeting the timing policy (0.01),
  /// sorts them alphabetically, and resolves the selected reciter & moshaf.
  Future<void> loadReciters({bool forceRefresh = false}) async {
    emit(const ReciterSelectionLoading());
    try {
      final allReciters =
          await _audioRepository.getReciters(forceRefresh: forceRefresh);

      // Task-specific constraint: Only list reciters meeting the timing policy from 0.01.
      final qualifiedReciters = allReciters
          .where((r) => r.hasAnyTimingSupport)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      if (qualifiedReciters.isEmpty) {
        emit(const ReciterSelectionEmpty());
        return;
      }

      final savedReciter = await _audioRepository.getSelectedReciter();
      final savedMoshaf = await _audioRepository.getSelectedMoshaf();

      // Ensure the selected reciter is among the qualified ones, or fall back
      final effectiveReciter = (savedReciter != null &&
              qualifiedReciters.any((r) => r.id == savedReciter.id))
          ? qualifiedReciters.firstWhere((r) => r.id == savedReciter.id)
          : qualifiedReciters.first;

      final effectiveMoshaf = (savedMoshaf != null &&
              effectiveReciter.moshafs
                  .any((m) => m.id == savedMoshaf.id && m.hasTiming))
          ? effectiveReciter.moshafs.firstWhere((m) => m.id == savedMoshaf.id)
          : (effectiveReciter.defaultMoshaf ?? effectiveReciter.moshafs.first);

      emit(ReciterSelectionSuccess(
        reciters: qualifiedReciters,
        selectedReciter: effectiveReciter,
        selectedMoshaf: effectiveMoshaf,
      ));
    } on Failure catch (e) {
      emit(ReciterSelectionFailure(e.message));
    } catch (e) {
      emit(ReciterSelectionFailure(e.toString()));
    }
  }

  /// Selects a reciter and specific moshaf edition, persisting to preferences.
  Future<void> selectReciterAndMoshaf({
    required Reciter reciter,
    required Moshaf moshaf,
  }) async {
    try {
      await _audioRepository.setSelectedReciterAndMoshaf(
        reciterId: reciter.id,
        moshafId: moshaf.id,
      );

      final currentState = state;
      if (currentState is ReciterSelectionSuccess) {
        emit(currentState.copyWith(
          selectedReciter: reciter,
          selectedMoshaf: moshaf,
        ));
      }
    } on Failure catch (e) {
      emit(ReciterSelectionFailure(e.message));
    } catch (e) {
      emit(ReciterSelectionFailure(e.toString()));
    }
  }
}
