import 'package:ayaat_quran_majeed/features/bookmarks/data/datasources/bookmarks_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBookmarksLocalDataSource implements BookmarksLocalDataSource {
  List<BookmarkModel> storage = BookmarkItem.defaultSlots()
      .map(BookmarkModel.fromEntity)
      .toList();

  @override
  Future<List<BookmarkModel>> getBookmarks() async {
    return List.from(storage);
  }

  @override
  Future<void> saveBookmarks(List<BookmarkModel> bookmarks) async {
    storage = List.from(bookmarks);
  }
}

void main() {
  late FakeBookmarksLocalDataSource dataSource;
  late BookmarkRepositoryImpl repository;

  setUp(() {
    dataSource = FakeBookmarksLocalDataSource();
    repository = BookmarkRepositoryImpl(dataSource);
  });

  group('BookmarkRepositoryImpl Unit Tests', () {
    test('getBookmarks returns 4 default slots initially', () async {
      final bookmarks = await repository.getBookmarks();
      expect(bookmarks.length, equals(4));
      expect(bookmarks[0].id, equals(BookmarkItem.defaultRedId));
      expect(bookmarks[1].id, equals(BookmarkItem.defaultYellowId));
      expect(bookmarks[2].id, equals(BookmarkItem.defaultGreenId));
      expect(bookmarks[3].id, equals(BookmarkItem.defaultBlueId));
    });

    test(
      'assignBookmark updates slot with surah, ayah, page and records timestamp',
      () async {
        await repository.assignBookmark(
          id: BookmarkItem.defaultRedId,
          surahNumber: 2,
          verseNumber: 6,
          pageNumber: 3,
        );

        final bookmarks = await repository.getBookmarks();
        final red = bookmarks.firstWhere(
          (b) => b.id == BookmarkItem.defaultRedId,
        );

        expect(red.isAssigned, isTrue);
        expect(red.surahNumber, equals(2));
        expect(red.verseNumber, equals(6));
        expect(red.pageNumber, equals(3));
        expect(red.updatedAt, isNotNull);
      },
    );

    test(
      'unassignBookmark on default slot clears assignment but retains slot',
      () async {
        await repository.assignBookmark(
          id: BookmarkItem.defaultYellowId,
          surahNumber: 1,
          verseNumber: 7,
          pageNumber: 1,
        );

        await repository.unassignBookmark(BookmarkItem.defaultYellowId);

        final bookmarks = await repository.getBookmarks();
        final yellow = bookmarks.firstWhere(
          (b) => b.id == BookmarkItem.defaultYellowId,
        );

        expect(yellow.isAssigned, isFalse);
        expect(yellow.surahNumber, isNull);
        expect(yellow.verseNumber, isNull);
        expect(yellow.pageNumber, isNull);
        expect(yellow.updatedAt, isNull);
      },
    );

    test('updateBookmarkMetadata updates name and color hex', () async {
      await repository.updateBookmarkMetadata(
        BookmarkItem.defaultGreenId,
        name: 'فاصل مخصص',
        colorHex: '#9C27B0',
      );

      final bookmarks = await repository.getBookmarks();
      final green = bookmarks.firstWhere(
        (b) => b.id == BookmarkItem.defaultGreenId,
      );

      expect(green.name, equals('فاصل مخصص'));
      expect(green.colorHex, equals('#9C27B0'));
    });

    test(
      'addCustomBookmark appends custom bookmark and deleteCustomBookmark removes it',
      () async {
        const custom = BookmarkItem(
          id: 'custom_101',
          name: 'ختمة الجمعة',
          colorHex: '#8E44AD',
          surahNumber: 18,
          verseNumber: 1,
          pageNumber: 293,
          isDefault: false,
        );

        await repository.addCustomBookmark(custom);
        var bookmarks = await repository.getBookmarks();
        expect(bookmarks.length, equals(5));
        expect(bookmarks.last.id, equals('custom_101'));

        await repository.deleteCustomBookmark('custom_101');
        bookmarks = await repository.getBookmarks();
        expect(bookmarks.length, equals(4));
        expect(bookmarks.any((b) => b.id == 'custom_101'), isFalse);
      },
    );
  });
}
