import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_surah_group.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/repositories/starred_repository.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StarredCubit extends Cubit<StarredState> {
  final StarredRepository _repository;

  StarredCubit(this._repository) : super(StarredState.initial());

  /// Synchronous fast lookup for verse starred state.
  bool isStarred(int surahNumber, int verseNumber) =>
      state.isStarred(surahNumber, verseNumber);

  /// Loads all starred verses and organizes them into deterministic surah groups.
  Future<void> loadStarredVerses() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final items = await _repository.getStarredVerses();
      _emitSuccess(items);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Toggles the starred status of an Ayah idempotently.
  Future<void> toggleStarred(int surahNumber, int verseNumber) async {
    final key = '$surahNumber:$verseNumber';
    final wasStarred = state.starredKeys.contains(key);

    // Optimistic state update
    if (wasStarred) {
      final updatedItems = state.items.where((i) => i.key != key).toList();
      _emitSuccess(updatedItems);
    }

    try {
      await _repository.toggleStarred(surahNumber, verseNumber);
      final refreshed = await _repository.getStarredVerses();
      _emitSuccess(refreshed);
    } catch (e) {
      // Revert / re-sync on failure
      final fallback = await _repository.getStarredVerses();
      _emitSuccess(fallback);
    }
  }

  /// Idempotently adds a verse to starred verses.
  Future<void> addStarred(int surahNumber, int verseNumber) async {
    if (isStarred(surahNumber, verseNumber)) return;

    try {
      await _repository.addStarred(surahNumber, verseNumber);
      final refreshed = await _repository.getStarredVerses();
      _emitSuccess(refreshed);
    } catch (e) {
      final fallback = await _repository.getStarredVerses();
      _emitSuccess(fallback);
    }
  }

  /// Idempotently removes a verse from starred verses.
  Future<void> removeStarred(int surahNumber, int verseNumber) async {
    if (!isStarred(surahNumber, verseNumber)) return;

    final key = '$surahNumber:$verseNumber';
    final updatedItems = state.items.where((i) => i.key != key).toList();
    _emitSuccess(updatedItems);

    try {
      await _repository.removeStarred(surahNumber, verseNumber);
      final refreshed = await _repository.getStarredVerses();
      _emitSuccess(refreshed);
    } catch (e) {
      final fallback = await _repository.getStarredVerses();
      _emitSuccess(fallback);
    }
  }

  void _emitSuccess(List<StarredAyahItem> items) {
    final groups = StarredSurahGroup.groupBySurah(items);
    final keys = items.map((i) => i.key).toSet();
    emit(
      state.copyWith(
        isLoading: false,
        items: List.unmodifiable(items),
        groups: groups,
        starredKeys: keys,
        errorMessage: null,
      ),
    );
  }
}

