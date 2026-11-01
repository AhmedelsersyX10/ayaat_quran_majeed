import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/quran_search_result.dart';
import '../../data/repositories/quran_search_repository.dart';

part 'quran_search_state.dart';

class QuranSearchCubit extends Cubit<QuranSearchState> {
  final QuranSearchRepository _repository;
  Timer? _debounceTimer;

  QuranSearchCubit(this._repository) : super(QuranSearchInitial()) {
    // Initialize the search index in the background to avoid UI blocks
    _repository.init();
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      emit(QuranSearchInitial());
      return;
    }

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      emit(QuranSearchLoading());
      try {
        final results = await _repository.search(query);
        emit(QuranSearchLoaded(results));
      } catch (e) {
        emit(QuranSearchError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
