import 'package:ayaat_quran_majeed/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/bookmark_repository_impl_test.dart';

void main() {
  late FakeBookmarksLocalDataSource dataSource;
  late BookmarkRepositoryImpl repository;
  late BookmarkCubit cubit;

  setUp(() {
    dataSource = FakeBookmarksLocalDataSource();
    repository = BookmarkRepositoryImpl(dataSource);
    cubit = BookmarkCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('BookmarkCubit Unit Tests', () {
    test('initial state has isLoading true and empty bookmarks', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.bookmarks, isEmpty);
      expect(cubit.state.isEditMode, isFalse);
    });

    test(
      'loadBookmarks populates bookmarks and sets isLoading false',
      () async {
        await cubit.loadBookmarks();

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.bookmarks.length, equals(4));
        expect(cubit.state.errorMessage, isNull);
      },
    );

    test('toggleEditMode toggles boolean state flag correctly', () {
      expect(cubit.state.isEditMode, isFalse);

      cubit.toggleEditMode();
      expect(cubit.state.isEditMode, isTrue);

      cubit.toggleEditMode();
      expect(cubit.state.isEditMode, isFalse);

      cubit.toggleEditMode(true);
      expect(cubit.state.isEditMode, isTrue);
    });

    test(
      'toggleRedBookmark assigns red bookmark when unassigned and unassigns when already on that ayah',
      () async {
        await cubit.loadBookmarks();

        // First toggle: assign to Surah 2, Ayah 6, Page 3
        await cubit.toggleRedBookmark(
          surahNumber: 2,
          verseNumber: 6,
          pageNumber: 3,
        );
        expect(cubit.isAyahBookmarked(2, 6), isTrue);

        final red = cubit.getBookmarkForAyah(2, 6);
        expect(red, isNotNull);
        expect(red!.id, equals(BookmarkItem.defaultRedId));
        expect(red.pageNumber, equals(3));

        // Second toggle on same ayah: unassigns it
        await cubit.toggleRedBookmark(
          surahNumber: 2,
          verseNumber: 6,
          pageNumber: 3,
        );
        expect(cubit.isAyahBookmarked(2, 6), isFalse);
      },
    );

    test('assignBookmark and unassignBookmark update state', () async {
      await cubit.loadBookmarks();

      await cubit.assignBookmark(
        id: BookmarkItem.defaultBlueId,
        surahNumber: 2,
        verseNumber: 5,
        pageNumber: 2,
      );
      expect(cubit.isAyahBookmarked(2, 5), isTrue);

      await cubit.unassignBookmark(BookmarkItem.defaultBlueId);
      expect(cubit.isAyahBookmarked(2, 5), isFalse);
    });

    test(
      'getBookmarksForPage returns only bookmarks assigned to that page',
      () async {
        await cubit.loadBookmarks();

        await cubit.assignBookmark(
          id: BookmarkItem.defaultYellowId,
          surahNumber: 1,
          verseNumber: 7,
          pageNumber: 1,
        );

        await cubit.assignBookmark(
          id: BookmarkItem.defaultGreenId,
          surahNumber: 2,
          verseNumber: 3,
          pageNumber: 2,
        );

        final page1Bookmarks = cubit.getBookmarksForPage(1);
        expect(page1Bookmarks.length, equals(1));
        expect(page1Bookmarks.first.id, equals(BookmarkItem.defaultYellowId));

        final page2Bookmarks = cubit.getBookmarksForPage(2);
        expect(page2Bookmarks.length, equals(1));
        expect(page2Bookmarks.first.id, equals(BookmarkItem.defaultGreenId));

        final page3Bookmarks = cubit.getBookmarksForPage(3);
        expect(page3Bookmarks, isEmpty);
      },
    );

    test('updateBookmarkMetadata updates name and color in state', () async {
      await cubit.loadBookmarks();

      await cubit.updateBookmarkMetadata(
        BookmarkItem.defaultYellowId,
        name: 'الورد الصباحي',
        colorHex: '#FFC107',
      );

      final yellow = cubit.state.bookmarks.firstWhere(
        (b) => b.id == BookmarkItem.defaultYellowId,
      );
      expect(yellow.name, equals('الورد الصباحي'));
      expect(yellow.colorHex, equals('#FFC107'));
    });
  });
}
