import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookmarkItem Entity Tests', () {
    test(
      'defaultSlots returns 4 standard slots in order: Red, Yellow, Green, Blue',
      () {
        final slots = BookmarkItem.defaultSlots();
        expect(slots.length, equals(4));

        expect(slots[0].id, equals(BookmarkItem.defaultRedId));
        expect(slots[0].name, equals('الأحمر'));
        expect(slots[0].colorHex, equals('#C9484A'));
        expect(slots[0].isDefault, isTrue);
        expect(slots[0].isAssigned, isFalse);

        expect(slots[1].id, equals(BookmarkItem.defaultYellowId));
        expect(slots[1].name, equals('الأصفر'));
        expect(slots[1].colorHex, equals('#D7AC3C'));
        expect(slots[1].isDefault, isTrue);

        expect(slots[2].id, equals(BookmarkItem.defaultGreenId));
        expect(slots[2].name, equals('الأخضر'));
        expect(slots[2].colorHex, equals('#62A77B'));
        expect(slots[2].isDefault, isTrue);

        expect(slots[3].id, equals(BookmarkItem.defaultBlueId));
        expect(slots[3].name, equals('الأزرق'));
        expect(slots[3].colorHex, equals('#218FC9'));
        expect(slots[3].isDefault, isTrue);
      },
    );

    test(
      'isAssigned returns true when surah and verse are set, false otherwise',
      () {
        const unassigned = BookmarkItem(
          id: 'red',
          name: 'الأحمر',
          colorHex: '#C9484A',
        );
        expect(unassigned.isAssigned, isFalse);

        final assigned = unassigned.copyWith(
          surahNumber: 2,
          verseNumber: 255,
          pageNumber: 42,
        );
        expect(assigned.isAssigned, isTrue);
      },
    );

    test('color property parses hex string cleanly into Color', () {
      const item = BookmarkItem(id: 'red', name: 'الأحمر', colorHex: '#C9484A');
      expect(item.color, equals(const Color(0xFFC9484A)));

      const itemWithoutHash = BookmarkItem(
        id: 'green',
        name: 'الأخضر',
        colorHex: '62A77B',
      );
      expect(itemWithoutHash.color, equals(const Color(0xFF62A77B)));
    });

    test(
      'copyWith updates fields correctly and clearAssignment resets verse and page',
      () {
        final now = DateTime.now();
        final item = BookmarkItem(
          id: 'red',
          name: 'الأحمر',
          colorHex: '#C9484A',
          surahNumber: 1,
          verseNumber: 7,
          pageNumber: 1,
          updatedAt: now,
        );

        final updated = item.copyWith(name: 'الفاصل المفضل');
        expect(updated.name, equals('الفاصل المفضل'));
        expect(updated.surahNumber, equals(1));

        final cleared = item.copyWith(clearAssignment: true);
        expect(cleared.isAssigned, isFalse);
        expect(cleared.surahNumber, isNull);
        expect(cleared.verseNumber, isNull);
        expect(cleared.pageNumber, isNull);
        expect(cleared.updatedAt, isNull);
      },
    );

    test('equality and hashCode evaluate properly based on fields', () {
      const item1 = BookmarkItem(
        id: 'red',
        name: 'الأحمر',
        colorHex: '#C9484A',
        surahNumber: 2,
        verseNumber: 1,
        pageNumber: 2,
        isDefault: true,
      );

      const item2 = BookmarkItem(
        id: 'red',
        name: 'الأحمر',
        colorHex: '#C9484A',
        surahNumber: 2,
        verseNumber: 1,
        pageNumber: 2,
        isDefault: true,
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });
  });
}
