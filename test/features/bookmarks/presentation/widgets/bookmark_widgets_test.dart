import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_edit_dialog.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_picker_dialog.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_row_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/mushaf_bookmark_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('BookmarkRowItem Widget Tests', () {
    testWidgets(
      'unassigned row shows outline bookmark and title without subtitle',
      (tester) async {
        const item = BookmarkItem(
          id: 'red',
          name: 'الأحمر',
          colorHex: '#C9484A',
          isDefault: true,
        );

        await tester.pumpWidget(wrapWidget(const BookmarkRowItem(item: item)));
        await tester.pumpAndSettle();

        expect(find.text('الأحمر'), findsOneWidget);
        expect(find.byIcon(Iconsax.bookmark), findsOneWidget);
        expect(find.textContaining('الصفحة'), findsNothing);
      },
    );

    testWidgets(
      'assigned row shows filled bookmark and subtitle with page and ayah',
      (tester) async {
        final item = BookmarkItem(
          id: 'red',
          name: 'الأحمر',
          colorHex: '#C9484A',
          surahNumber: 2,
          verseNumber: 6,
          pageNumber: 3,
          updatedAt: DateTime(2023, 10, 30, 9, 32),
          isDefault: true,
        );

        await tester.pumpWidget(wrapWidget(BookmarkRowItem(item: item)));
        await tester.pumpAndSettle();

        expect(find.text('الأحمر'), findsOneWidget);
        expect(find.byIcon(Icons.bookmark), findsOneWidget);
        expect(find.textContaining('الصفحة'), findsOneWidget);
      },
    );

    testWidgets(
      'assigned row without updatedAt does not have leading spaces in subtitle',
      (tester) async {
        const item = BookmarkItem(
          id: 'legacy',
          name: 'الأصفر',
          colorHex: '#D7AC3C',
          surahNumber: 2,
          verseNumber: 142,
          pageNumber: 22,
          updatedAt: null,
        );

        await tester.pumpWidget(wrapWidget(const BookmarkRowItem(item: item)));
        await tester.pumpAndSettle();

        expect(find.textContaining('الصفحة'), findsOneWidget);
        final subtitleFinder = find.textContaining('2:');
        expect(subtitleFinder, findsOneWidget);
        final textWidget = tester.widget<Text>(subtitleFinder);
        expect(textWidget.data!.startsWith(' '), isFalse);
      },
    );
  });

  group('BookmarkEditDialog Widget Tests', () {
    testWidgets(
      'renders name TextField and color circles, saves updated values',
      (tester) async {
        String savedName = '';
        String savedColor = '';

        const item = BookmarkItem(
          id: 'yellow',
          name: 'الأصفر',
          colorHex: '#D7AC3C',
          isDefault: true,
        );

        await tester.pumpWidget(
          wrapWidget(
            BookmarkEditDialog(
              item: item,
              onSave: (newName, newColorHex) {
                savedName = newName;
                savedColor = newColorHex;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('تعديل الفاصل'), findsOneWidget);
        expect(
          find.text(AppStrings.tr(AppStrings.bookmarkName)),
          findsOneWidget,
        );
        expect(find.text('الأصفر'), findsOneWidget);

        // Edit name
        await tester.enterText(find.byType(TextField), 'فاصل الحفظ اليومي');
        await tester.pumpAndSettle();

        // Tap save
        await tester.tap(find.text(AppStrings.tr(AppStrings.save)));
        await tester.pumpAndSettle();

        expect(savedName, equals('فاصل الحفظ اليومي'));
        expect(savedColor, equals('#D7AC3C'));
      },
    );
  });

  group('BookmarkPickerDialog Widget Tests', () {
    testWidgets('lists bookmarks and allows selecting slot', (tester) async {
      String selectedId = '';

      final slots = BookmarkItem.defaultSlots();

      await tester.pumpWidget(
        wrapWidget(
          BookmarkPickerDialog(
            surahNumber: 2,
            verseNumber: 255,
            pageNumber: 42,
            bookmarks: slots,
            onSelectBookmark: (id) => selectedId = id,
            onAddNewBookmark: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.tr(AppStrings.anotherBookmark)),
        findsOneWidget,
      );
      expect(find.text('الأحمر'), findsOneWidget);
      expect(find.text('الأصفر'), findsOneWidget);

      await tester.tap(find.text('الأزرق'));
      await tester.pumpAndSettle();

      expect(selectedId, equals(BookmarkItem.defaultBlueId));
    });
  });

  group('MushafBookmarkMarker Widget Tests', () {
    testWidgets('renders ribbon tabs when bookmarks are present', (
      tester,
    ) async {
      final bookmarks = [
        const BookmarkItem(id: 'red', name: 'الأحمر', colorHex: '#C9484A'),
        const BookmarkItem(id: 'green', name: 'الأخضر', colorHex: '#62A77B'),
      ];

      await tester.pumpWidget(
        wrapWidget(
          Stack(children: [MushafBookmarkMarker(bookmarks: bookmarks)]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClipPath), findsNWidgets(2));
    });

    testWidgets('renders SizedBox.shrink when bookmarks are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWidget(
          const Stack(children: [MushafBookmarkMarker(bookmarks: [])]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClipPath), findsNothing);
    });

    testWidgets(
      'positions ribbons in center to avoid clashing with header text',
      (tester) async {
        final bookmarks = [
          const BookmarkItem(id: 'red', name: 'الأحمر', colorHex: '#C9484A'),
        ];

        await tester.pumpWidget(
          wrapWidget(
            Stack(children: [MushafBookmarkMarker(bookmarks: bookmarks)]),
          ),
        );
        await tester.pumpAndSettle();

        final positionedFinder = find.byType(Positioned);
        expect(positionedFinder, findsOneWidget);
        final positioned = tester.widget<Positioned>(positionedFinder);
        expect(positioned.left, equals(0));
        expect(positioned.right, equals(0));
        expect(positioned.top, equals(0));

        final centerFinder = find.descendant(
          of: positionedFinder,
          matching: find.byType(Center),
        );
        expect(centerFinder, findsOneWidget);
      },
    );
  });
}
