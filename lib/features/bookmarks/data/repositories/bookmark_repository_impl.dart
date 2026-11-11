import 'package:ayaat_quran_majeed/features/bookmarks/data/datasources/bookmarks_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/repositories/bookmark_repository.dart';

/// Implementation of [BookmarkRepository] backed by [BookmarksLocalDataSource].
class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarksLocalDataSource _localDataSource;

  BookmarkRepositoryImpl(this._localDataSource);

  @override
  Future<List<BookmarkItem>> getBookmarks() async {
    final models = await _localDataSource.getBookmarks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveBookmarks(List<BookmarkItem> bookmarks) async {
    final models = bookmarks.map(BookmarkModel.fromEntity).toList();
    await _localDataSource.saveBookmarks(models);
  }

  @override
  Future<void> assignBookmark({
    required String id,
    required int surahNumber,
    required int verseNumber,
    required int pageNumber,
  }) async {
    final current = await getBookmarks();
    final updated = <BookmarkItem>[];
    bool found = false;

    for (final item in current) {
      if (item.id == id) {
        found = true;
        updated.add(
          item.copyWith(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            pageNumber: pageNumber,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        updated.add(item);
      }
    }

    if (!found) {
      updated.add(
        BookmarkItem(
          id: id,
          name: 'علامة',
          colorHex: '#C9484A',
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: pageNumber,
          updatedAt: DateTime.now(),
        ),
      );
    }

    await saveBookmarks(updated);
  }

  @override
  Future<void> unassignBookmark(String id) async {
    final current = await getBookmarks();
    final updated = <BookmarkItem>[];

    for (final item in current) {
      if (item.id == id) {
        if (item.isDefault) {
          updated.add(item.copyWith(clearAssignment: true));
        }
        // If not default (custom), omit it so it gets deleted
      } else {
        updated.add(item);
      }
    }

    await saveBookmarks(updated);
  }

  @override
  Future<void> updateBookmarkMetadata(
    String id, {
    required String name,
    required String colorHex,
  }) async {
    final current = await getBookmarks();
    final updated = current.map((item) {
      if (item.id == id) {
        return item.copyWith(
          name: name.trim().isNotEmpty ? name.trim() : item.name,
          colorHex: colorHex.isNotEmpty ? colorHex : item.colorHex,
        );
      }
      return item;
    }).toList();

    await saveBookmarks(updated);
  }

  @override
  Future<void> addCustomBookmark(BookmarkItem bookmark) async {
    final current = await getBookmarks();
    final updated = List<BookmarkItem>.from(current)..add(bookmark);
    await saveBookmarks(updated);
  }

  @override
  Future<void> deleteCustomBookmark(String id) async {
    final current = await getBookmarks();
    final updated = <BookmarkItem>[];

    for (final item in current) {
      if (item.id == id) {
        if (item.isDefault) {
          updated.add(item.copyWith(clearAssignment: true));
        }
      } else {
        updated.add(item);
      }
    }

    await saveBookmarks(updated);
  }
}
