import 'package:ayaat_quran_majeed/features/bookmarks/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';

/// State representation for bookmarks.
class BookmarkState {
  final bool isLoading;
  final List<BookmarkItem> bookmarks;
  final bool isEditMode;
  final String? errorMessage;

  const BookmarkState({
    required this.isLoading,
    required this.bookmarks,
    this.isEditMode = false,
    this.errorMessage,
  });

  factory BookmarkState.initial() {
    return const BookmarkState(
      isLoading: true,
      bookmarks: <BookmarkItem>[],
      isEditMode: false,
    );
  }

  /// Backward-compatibility getter for legacy views expecting `List<BookmarkModel>`.
  List<BookmarkModel> get legacyBookmarks =>
      bookmarks.map(BookmarkModel.fromEntity).toList();

  BookmarkState copyWith({
    bool? isLoading,
    List<BookmarkItem>? bookmarks,
    bool? isEditMode,
    String? errorMessage,
  }) {
    return BookmarkState(
      isLoading: isLoading ?? this.isLoading,
      bookmarks: bookmarks ?? this.bookmarks,
      isEditMode: isEditMode ?? this.isEditMode,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkState &&
        other.isLoading == isLoading &&
        other.isEditMode == isEditMode &&
        other.errorMessage == errorMessage &&
        _listEquals(other.bookmarks, bookmarks);
  }

  @override
  int get hashCode => Object.hash(
    isLoading,
    isEditMode,
    errorMessage,
    Object.hashAll(bookmarks),
  );

  static bool _listEquals(List<BookmarkItem> a, List<BookmarkItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
