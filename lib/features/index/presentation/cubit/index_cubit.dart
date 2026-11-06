import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit managing tab selection, state restoration, and status for the Quran Index feature.
class IndexCubit extends Cubit<IndexState> {
  final IndexRepository _repository;

  IndexCubit(this._repository) : super(const IndexState());

  /// Loads the persisted active tab from storage and sets the status to success.
  Future<void> loadState() async {
    emit(state.copyWith(status: IndexStatus.loading));
    try {
      final activeTab = await _repository.getActiveTab();
      emit(IndexState(
        selectedTab: activeTab,
        status: IndexStatus.success,
      ));
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

