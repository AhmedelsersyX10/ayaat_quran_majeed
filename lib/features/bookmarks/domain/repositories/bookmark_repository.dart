import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';

/// Contract for bookmarks management and persistence.
abstract class BookmarkRepository {
  /// Retrieves all bookmarks, guaranteeing the 4 default slots exist.
  Future<List<BookmarkItem>> getBookmarks();

  /// Persists the full list of bookmarks.
  Future<void> saveBookmarks(List<BookmarkItem> bookmarks);

  /// Assigns a specific bookmark slot to an Ayah and records current timestamp.
  Future<void> assignBookmark({
    required String id,
    required int surahNumber,
    required int verseNumber,
    required int pageNumber,
  });

  /// Clears assignment for a bookmark slot. If custom, deletes it.
  Future<void> unassignBookmark(String id);

  /// Updates the name and color of a bookmark.
  Future<void> updateBookmarkMetadata(
    String id, {
    required String name,
    required String colorHex,
  });

  /// Adds a new custom bookmark slot.
  Future<void> addCustomBookmark(BookmarkItem bookmark);

  /// Deletes a custom bookmark by ID. Unassigns if it is a default slot.
  Future<void> deleteCustomBookmark(String id);
}
