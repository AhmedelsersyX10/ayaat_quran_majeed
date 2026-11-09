import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_available_tafsir_books_use_case.dart';
import '../../domain/usecases/get_page_tafsir_use_case.dart';
import '../../domain/usecases/get_selected_tafsir_book_use_case.dart';
import '../../domain/usecases/set_selected_tafsir_book_use_case.dart';
import 'tafsir_state.dart';

/// Cubit managing the state of Tafsir Mode.
///
/// Coordinates between [GetPageTafsirUseCase], [GetSelectedTafsirBookUseCase],
/// [SetSelectedTafsirBookUseCase], and [GetAvailableTafsirBooksUseCase].
class TafsirCubit extends Cubit<TafsirState> {
  final GetPageTafsirUseCase _getPageTafsirUseCase;
  final GetSelectedTafsirBookUseCase _getSelectedTafsirBookUseCase;
  final SetSelectedTafsirBookUseCase _setSelectedTafsirBookUseCase;
  final GetAvailableTafsirBooksUseCase _getAvailableTafsirBooksUseCase;

  TafsirCubit({
    required GetPageTafsirUseCase getPageTafsirUseCase,
    required GetSelectedTafsirBookUseCase getSelectedTafsirBookUseCase,
    required SetSelectedTafsirBookUseCase setSelectedTafsirBookUseCase,
    required GetAvailableTafsirBooksUseCase getAvailableTafsirBooksUseCase,
    int initialPage = 1,
  })  : _getPageTafsirUseCase = getPageTafsirUseCase,
        _getSelectedTafsirBookUseCase = getSelectedTafsirBookUseCase,
        _setSelectedTafsirBookUseCase = setSelectedTafsirBookUseCase,
        _getAvailableTafsirBooksUseCase = getAvailableTafsirBooksUseCase,
        super(TafsirState.initial(initialPage: initialPage));

  /// Loads the Tafsir verses for [pageNumber].
  ///
  /// If the current page and active book are already loaded and [forceReload] is false,
  /// redundant network/disk calls are skipped.
  Future<void> loadPageTafsir(int pageNumber, {bool forceReload = false}) async {
    final int safePage = pageNumber.clamp(1, 604);

    if (!forceReload &&
        state.status == TafsirStatus.loaded &&
        state.pageNumber == safePage &&
        state.verses.isNotEmpty) {
      return;
    }

    emit(state.copyWith(
      status: TafsirStatus.loading,
      pageNumber: safePage,
      clearError: true,
    ));

    try {
      final selectedBook = await _getSelectedTafsirBookUseCase();
      final verses = await _getPageTafsirUseCase(
        pageNumber: safePage,
        bookId: selectedBook.id,
      );

      if (verses.isEmpty) {
        emit(state.copyWith(
          status: TafsirStatus.empty,
          selectedBook: selectedBook,
          verses: const [],
          pageNumber: safePage,
        ));
      } else {
        emit(state.copyWith(
          status: TafsirStatus.loaded,
          selectedBook: selectedBook,
          verses: verses,
          pageNumber: safePage,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TafsirStatus.failure,
        errorMessage: 'تعذر تحميل التفسير للصفحة $safePage',
        pageNumber: safePage,
      ));
    }
  }

  /// Selects a new active Tafsir book by [bookId] and reloads the current page.
  Future<void> selectBook(String bookId) async {
    try {
      emit(state.copyWith(status: TafsirStatus.loading, clearError: true));
      await _setSelectedTafsirBookUseCase(bookId);
      final newBook = await _getSelectedTafsirBookUseCase();

      final verses = await _getPageTafsirUseCase(
        pageNumber: state.pageNumber,
        bookId: newBook.id,
      );

      emit(state.copyWith(
        status: verses.isEmpty ? TafsirStatus.empty : TafsirStatus.loaded,
        selectedBook: newBook,
        verses: verses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TafsirStatus.failure,
        errorMessage: 'تعذر تغيير كتاب التفسير',
      ));
    }
  }

  /// Loads available books for selection in the book picker sheet.
  Future<void> loadAvailableBooks() async {
    try {
      final books = await _getAvailableTafsirBooksUseCase();
      final currentBook = state.selectedBook ?? await _getSelectedTafsirBookUseCase();
      emit(state.copyWith(
        availableBooks: books,
        selectedBook: currentBook,
      ));
    } catch (_) {
      // Keep existing available books on error
    }
  }

  /// Retries loading the current page after a failure.
  Future<void> retry() => loadPageTafsir(state.pageNumber, forceReload: true);
}

