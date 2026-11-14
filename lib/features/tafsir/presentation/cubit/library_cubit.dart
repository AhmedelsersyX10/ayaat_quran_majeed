import 'package:ayaat_quran_majeed/core/network/cancellation_token.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tafsir_book.dart';
import '../../domain/usecases/add_to_my_library_use_case.dart';
import '../../domain/usecases/delete_downloaded_book_use_case.dart';
import '../../domain/usecases/download_tafsir_book_use_case.dart';
import '../../domain/usecases/get_all_catalog_books_use_case.dart';
import '../../domain/usecases/get_my_library_books_use_case.dart';
import '../../domain/usecases/remove_from_my_library_use_case.dart';
import '../../domain/usecases/update_my_library_order_use_case.dart';
import 'library_state.dart';

/// Cubit managing the state of Library Editor ("تحرير المكتبة" - Reference 34).
class LibraryCubit extends Cubit<LibraryState> {
  final GetMyLibraryBooksUseCase _getMyLibraryBooksUseCase;
  final GetAllCatalogBooksUseCase _getAllCatalogBooksUseCase;
  final UpdateMyLibraryOrderUseCase _updateMyLibraryOrderUseCase;
  final AddToMyLibraryUseCase _addToMyLibraryUseCase;
  final RemoveFromMyLibraryUseCase _removeFromMyLibraryUseCase;
  final DownloadTafsirBookUseCase _downloadTafsirBookUseCase;
  final DeleteDownloadedBookUseCase _deleteDownloadedBookUseCase;

  final Map<String, AppCancellationToken> _cancelTokens = {};

  LibraryCubit({
    required GetMyLibraryBooksUseCase getMyLibraryBooksUseCase,
    required GetAllCatalogBooksUseCase getAllCatalogBooksUseCase,
    required UpdateMyLibraryOrderUseCase updateMyLibraryOrderUseCase,
    required AddToMyLibraryUseCase addToMyLibraryUseCase,
    required RemoveFromMyLibraryUseCase removeFromMyLibraryUseCase,
    required DownloadTafsirBookUseCase downloadTafsirBookUseCase,
    required DeleteDownloadedBookUseCase deleteDownloadedBookUseCase,
  }) : _getMyLibraryBooksUseCase = getMyLibraryBooksUseCase,
       _getAllCatalogBooksUseCase = getAllCatalogBooksUseCase,
       _updateMyLibraryOrderUseCase = updateMyLibraryOrderUseCase,
       _addToMyLibraryUseCase = addToMyLibraryUseCase,
       _removeFromMyLibraryUseCase = removeFromMyLibraryUseCase,
       _downloadTafsirBookUseCase = downloadTafsirBookUseCase,
       _deleteDownloadedBookUseCase = deleteDownloadedBookUseCase,
       super(LibraryState.initial());

  /// Loads pinned library books and all available catalog books.
  Future<void> loadLibrary({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      emit(state.copyWith(status: LibraryStatus.loading, clearError: true));
    }

    try {
      final myBooks = await _getMyLibraryBooksUseCase();
      final allBooks = await _getAllCatalogBooksUseCase();

      emit(
        state.copyWith(
          status: LibraryStatus.loaded,
          myLibraryBooks: myBooks,
          availableBooks: allBooks,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: 'تعذر تحميل بيانات المكتبة',
        ),
      );
    }
  }

  /// Reorders items inside "مكتبتي" and persists the updated order.
  Future<void> reorderMyLibrary(int oldIndex, int newIndex) async {
    final books = List<TafsirBook>.from(state.myLibraryBooks);
    if (oldIndex < 0 || oldIndex >= books.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0 || newIndex >= books.length) return;

    final movedItem = books.removeAt(oldIndex);
    books.insert(newIndex, movedItem);

    // Optimistic UI update
    emit(state.copyWith(myLibraryBooks: books));

    try {
      final ids = books.map((b) => b.id).toList();
      await _updateMyLibraryOrderUseCase(ids);
    } catch (_) {
      // Revert if persistence failed
      await loadLibrary(showLoadingIndicator: false);
    }
  }

  /// Removes a book from "مكتبتي".
  /// Strictly protects the default readable book (Al-Tafsir Al-Muyassar).
  Future<void> removeFromMyLibrary(String bookId) async {
    if (bookId == TafsirBook.defaultBookId) {
      emit(
        state.copyWith(
          userNotice:
              'لا يمكن حذف التفسير الميسر لأنه التفسير الافتراضي للمصحف',
        ),
      );
      return;
    }

    try {
      await _removeFromMyLibraryUseCase(bookId);
      // Reload both lists so the unpinned book returns to the available list
      await loadLibrary(showLoadingIndicator: false);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'تعذر حذف الكتاب من مكتبتي'));
    }
  }

  /// Adds a book to "مكتبتي".
  /// If the book is already bundled or downloaded, it is added immediately.
  /// If remote and not yet downloaded, initiates downloading.
  Future<void> addToMyLibrary(String bookId) async {
    TafsirBook? targetBook;
    for (final book in state.availableBooks) {
      if (book.id == bookId) {
        targetBook = book;
        break;
      }
    }

    if (targetBook == null) return;

    if (targetBook.isBundled || targetBook.isDownloaded) {
      try {
        await _addToMyLibraryUseCase(bookId);
        await loadLibrary(showLoadingIndicator: false);
      } catch (e) {
        emit(state.copyWith(errorMessage: 'تعذر إضافة الكتاب إلى مكتبتي'));
      }
    } else {
      await downloadAndAddToLibrary(bookId);
    }
  }

  /// Downloads a remote book and pins it to "مكتبتي" upon completion.
  Future<void> downloadAndAddToLibrary(String bookId) async {
    final cancelToken = AppCancellationToken();
    _cancelTokens[bookId] = cancelToken;

    final progressMap = Map<String, double>.from(state.downloadingProgress);
    progressMap[bookId] = 0.0;

    final failedMap = Map<String, String>.from(state.failedDownloads);
    failedMap.remove(bookId);

    emit(
      state.copyWith(
        downloadingProgress: progressMap,
        failedDownloads: failedMap,
        clearError: true,
      ),
    );

    try {
      await _downloadTafsirBookUseCase(
        bookId,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            final updatedProgress = Map<String, double>.from(
              state.downloadingProgress,
            );
            updatedProgress[bookId] = progress;
            emit(state.copyWith(downloadingProgress: updatedProgress));
          }
        },
      );

      // Add to library once file is safely saved
      await _addToMyLibraryUseCase(bookId);

      _cancelTokens.remove(bookId);
      final finalProgress = Map<String, double>.from(state.downloadingProgress)
        ..remove(bookId);
      emit(state.copyWith(downloadingProgress: finalProgress));

      await loadLibrary(showLoadingIndicator: false);
    } catch (e) {
      _cancelTokens.remove(bookId);
      final finalProgress = Map<String, double>.from(state.downloadingProgress)
        ..remove(bookId);
      final updatedFailed = Map<String, String>.from(state.failedDownloads);
      updatedFailed[bookId] =
          'تعذر تنزيل الكتاب. يرجى التحقق من اتصال الإنترنت';

      emit(
        state.copyWith(
          downloadingProgress: finalProgress,
          failedDownloads: updatedFailed,
        ),
      );
    }
  }

  /// Cancels an in-flight download for [bookId].
  void cancelDownload(String bookId) {
    final token = _cancelTokens.remove(bookId);
    token?.cancel('Download cancelled by user');

    final progressMap = Map<String, double>.from(state.downloadingProgress)
      ..remove(bookId);
    emit(state.copyWith(downloadingProgress: progressMap));
  }

  /// Deletes a downloaded book from storage.
  Future<void> deleteDownloadedBook(String bookId) async {
    try {
      await _deleteDownloadedBookUseCase(bookId);
      await loadLibrary(showLoadingIndicator: false);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'تعذر حذف ملف الكتاب من الجهاز'));
    }
  }

  /// Clears temporary user notice.
  void clearNotice() {
    emit(state.copyWith(clearNotice: true));
  }

  @override
  Future<void> close() {
    for (final token in _cancelTokens.values) {
      token.cancel('Cubit disposed');
    }
    _cancelTokens.clear();
    return super.close();
  }
}
