import 'package:ayaat_quran_majeed/features/bookmarks/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/cubit/bookmark_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit managing the 4 standard bookmarks ("الفواصل الأربعة") and custom bookmarks.
///
/// Features:
/// - Guarantees 4 standard slots (Red, Yellow, Green, Blue) are always present.
/// - Fast toggling of the standard red bookmark from reader and ayah options sheet.
/// - Unassigning (clearing) and editing bookmark titles & colors.
/// - Adding/deleting custom bookmarks ("فاصل آخر...").
class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _repository;

  BookmarkCubit(this._repository) : super(BookmarkState.initial());

  BookmarkRepository get repository => _repository;

  /// Loads all bookmarks from local storage.
  Future<void> loadBookmarks() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final bookmarks = await _repository.getBookmarks();
      emit(
        state.copyWith(
          isLoading: false,
          bookmarks: bookmarks,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Toggles edit mode for deleting/unassigning or customizing bookmarks.
  void toggleEditMode([bool? enabled]) {
    emit(state.copyWith(isEditMode: enabled ?? !state.isEditMode));
  }

  /// Toggles the Red Bookmark on the given Ayah:
  /// - If the red slot is currently assigned to this ayah, it unassigns it.
  /// - If it is unassigned or assigned elsewhere, it assigns it here.
  Future<void> toggleRedBookmark({
    required int surahNumber,
    required int verseNumber,
    required int pageNumber,
  }) async {
    final red = state.bookmarks.cast<BookmarkItem?>().firstWhere(
      (b) => b?.id == BookmarkItem.defaultRedId,
      orElse: () => null,
    );

    final isCurrentlyOnAyah =
        red != null &&
        red.isAssigned &&
        red.surahNumber == surahNumber &&
        red.verseNumber == verseNumber;

    if (isCurrentlyOnAyah) {
      await unassignBookmark(BookmarkItem.defaultRedId);
    } else {
      await assignBookmark(
        id: BookmarkItem.defaultRedId,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        pageNumber: pageNumber,
      );
    }
  }

  /// Assigns a bookmark slot to an Ayah.
  Future<void> assignBookmark({
    required String id,
    required int surahNumber,
    required int verseNumber,
    required int pageNumber,
  }) async {
    try {
      await _repository.assignBookmark(
        id: id,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        pageNumber: pageNumber,
      );
      final refreshed = await _repository.getBookmarks();
      emit(state.copyWith(bookmarks: refreshed));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Unassigns (clears) an assigned bookmark slot, or deletes if custom.
  Future<void> unassignBookmark(String id) async {
    try {
      await _repository.unassignBookmark(id);
      final refreshed = await _repository.getBookmarks();
      emit(state.copyWith(bookmarks: refreshed));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Updates a bookmark's display name and color.
  Future<void> updateBookmarkMetadata(
    String id, {
    required String name,
    required String colorHex,
  }) async {
    try {
      await _repository.updateBookmarkMetadata(
        id,
        name: name,
        colorHex: colorHex,
      );
      final refreshed = await _repository.getBookmarks();
      emit(state.copyWith(bookmarks: refreshed));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Adds a custom bookmark.
  Future<void> addCustomBookmark(BookmarkItem bookmark) async {
    try {
      await _repository.addCustomBookmark(bookmark);
      final refreshed = await _repository.getBookmarks();
      emit(state.copyWith(bookmarks: refreshed));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Deletes a custom bookmark by ID (or unassigns if default).
  Future<void> deleteCustomBookmark(String id) async {
    try {
      await _repository.deleteCustomBookmark(id);
      final refreshed = await _repository.getBookmarks();
      emit(state.copyWith(bookmarks: refreshed));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Checks whether an Ayah has any bookmark assigned.
  bool isAyahBookmarked(int surahNumber, int verseNumber) {
    return state.bookmarks.any(
      (b) =>
          b.isAssigned &&
          b.surahNumber == surahNumber &&
          b.verseNumber == verseNumber,
    );
  }

  /// Returns the first bookmark assigned to the given Ayah, or null.
  BookmarkItem? getBookmarkForAyah(int surahNumber, int verseNumber) {
    for (final b in state.bookmarks) {
      if (b.isAssigned &&
          b.surahNumber == surahNumber &&
          b.verseNumber == verseNumber) {
        return b;
      }
    }
    return null;
  }

  /// Returns all bookmarks assigned to verses on the given page.
  List<BookmarkItem> getBookmarksForPage(int pageNumber) {
    return state.bookmarks
        .where((b) => b.isAssigned && b.pageNumber == pageNumber)
        .toList();
  }

  // ==================== Legacy Backwards Compatibility ====================

  /// Legacy helper method: checks if verse has bookmark.
  bool hasBookmark(int surahNumber, int verseNumber) =>
      isAyahBookmarked(surahNumber, verseNumber);

  /// Legacy helper method: returns bookmark for verse.
  dynamic getBookmarkForVerse(int surahNumber, int verseNumber) =>
      getBookmarkForAyah(surahNumber, verseNumber);

  /// Legacy helper method: adds bookmark.
  Future<void> addBookmark(dynamic bookmark) async {
    if (bookmark is BookmarkItem) {
      await addCustomBookmark(bookmark);
    } else if (bookmark is BookmarkModel) {
      await addCustomBookmark(bookmark.toEntity());
    }
  }

  /// Legacy helper method: removes bookmark.
  Future<void> removeBookmark(dynamic bookmark) async {
    final surah = bookmark?.suraNumber ?? bookmark?.surahNumber;
    final verse = bookmark?.verseNumber;
    if (surah != null && verse != null) {
      final existing = getBookmarkForAyah(surah as int, verse as int);
      if (existing != null) {
        await unassignBookmark(existing.id);
      }
    }
  }
}
