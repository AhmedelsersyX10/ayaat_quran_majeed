import 'dart:async';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';

/// Cubit managing search state, debouncing, and execution.
class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repository;
  Timer? _debounceTimer;

  SearchCubit(this._repository) : super(const SearchInitial()) {
    // Warm up the search index in the background to avoid latency on first query.
    _repository.init();
  }

  /// Called on text field changes with a 300ms debounce window.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  /// Immediately executes search without waiting for debounce (e.g. keyboard submit).
  void searchImmediate(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    _executeSearch(query);
  }

  /// Clears search and resets to initial state.
  void clearSearch() {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  Future<void> _executeSearch(String query) async {
    emit(const SearchLoading());
    try {
      final result = await _repository.search(query);
      emit(SearchLoaded(result));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
