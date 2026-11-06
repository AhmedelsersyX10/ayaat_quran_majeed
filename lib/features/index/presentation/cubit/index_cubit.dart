import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit managing tab selection, Surah groups, reading position, and status for the Quran Index.
class IndexCubit extends Cubit<IndexState> {
  final IndexRepository _repository;

  IndexCubit(this._repository) : super(const IndexState());

  /// Loads the persisted active tab, Surahs grouped by Juz, and current reading position.
  Future<void> loadState() async {
    emit(state.copyWith(status: IndexStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getActiveTab(),
        _repository.getSurahsGroupedByJuz(),
        _repository.getCurrentReadingSurah(),
      ]);

      final activeTab = results[0] as IndexTab;
      final juzGroups = results[1] as List<JuzGroup>;
      final currentReadingSurah = results[2] as int;

      if (juzGroups.isEmpty) {
        emit(IndexState(
          selectedTab: activeTab,
          status: IndexStatus.empty,
          currentReadingSurah: currentReadingSurah,
        ));
      } else {
        emit(IndexState(
          selectedTab: activeTab,
          status: IndexStatus.success,
          juzGroups: juzGroups,
          currentReadingSurah: currentReadingSurah,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: IndexStatus.failure,
        errorMessage: AppStrings.indexLoadFailed,
      ));
    }
  }

  /// Changes the active tab and persists the user preference.
  Future<void> selectTab(IndexTab tab) async {
    if (state.selectedTab == tab && state.status == IndexStatus.success) {
      return;
    }

    emit(state.copyWith(
      selectedTab: tab,
      status: IndexStatus.success,
      errorMessage: null,
    ));

    try {
      await _repository.setActiveTab(tab);
    } catch (_) {
      // Non-fatal preference persistence failure; UI remains updated.
    }
  }

  /// Refreshes the active reading position without reloading all Quran groups.
  Future<void> refreshReadingPosition() async {
    try {
      final currentReadingSurah = await _repository.getCurrentReadingSurah();
      if (currentReadingSurah != state.currentReadingSurah) {
        emit(state.copyWith(currentReadingSurah: currentReadingSurah));
      }
    } catch (_) {
      // Non-fatal reading position refresh failure.
    }
  }

  /// Sets the operational status of the index sheet (e.g. for loading/empty/error states).
  void setStatus(IndexStatus status, {String? errorMessage}) {
    emit(state.copyWith(
      status: status,
      errorMessage: errorMessage,
    ));
  }

  /// Retries loading the state after an error.
  Future<void> retry() => loadState();
}
