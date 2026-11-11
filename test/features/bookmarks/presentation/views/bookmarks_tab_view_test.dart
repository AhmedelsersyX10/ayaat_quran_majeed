import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/views/bookmarks_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  Widget buildTestWidget(BookmarkCubit bCubit) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider<BookmarkCubit>.value(
            value: bCubit,
            child: const BookmarksTabView(),
          ),
        ),
      ),
    );
  }

  group('BookmarksTabView Widget Tests (Screens 11 & 27)', () {
    testWidgets(
      'renders title "الفواصل", "تحرير" action, and 4 default slots',
      (tester) async {
        await cubit.loadBookmarks();

        await tester.pumpWidget(buildTestWidget(cubit));
        await tester.pumpAndSettle();

        expect(
          find.text(AppStrings.tr(AppStrings.bookmarksTitle)),
          findsOneWidget,
        );
        expect(
          find.text(AppStrings.tr(AppStrings.editBookmarks)),
          findsOneWidget,
        );

        expect(find.text('الأحمر'), findsOneWidget);
        expect(find.text('الأصفر'), findsOneWidget);
        expect(find.text('الأخضر'), findsOneWidget);
        expect(find.text('الأزرق'), findsOneWidget);
      },
    );

    testWidgets('renders assigned bookmark details matching Reference 27', (
      tester,
    ) async {
      await cubit.loadBookmarks();
      await cubit.assignBookmark(
        id: BookmarkItem.defaultRedId,
        surahNumber: 2,
        verseNumber: 6,
        pageNumber: 3,
      );

      await tester.pumpWidget(buildTestWidget(cubit));
      await tester.pumpAndSettle();

      // Filled bookmark icon for assigned red bookmark
      expect(find.byIcon(Icons.bookmark), findsAtLeastNWidgets(1));

      // Subtitle containing page number in Arabic
      expect(find.textContaining('الصفحة'), findsOneWidget);
      expect(find.textContaining('٦'), findsOneWidget);
    });

    testWidgets(
      'tapping "تحرير" switches label to "تم" and enables edit mode with delete buttons',
      (tester) async {
        await cubit.loadBookmarks();
        await cubit.assignBookmark(
          id: BookmarkItem.defaultRedId,
          surahNumber: 2,
          verseNumber: 6,
          pageNumber: 3,
        );

        await tester.pumpWidget(buildTestWidget(cubit));
        await tester.pumpAndSettle();

        expect(
          find.text(AppStrings.tr(AppStrings.editBookmarks)),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.close), findsNothing);

        // Tap "تحرير"
        await tester.tap(find.text(AppStrings.tr(AppStrings.editBookmarks)));
        await tester.pumpAndSettle();

        // Changes to "تم"
        expect(find.text(AppStrings.tr(AppStrings.done)), findsOneWidget);
        // Delete 'X' appears for the assigned bookmark
        expect(find.byIcon(Icons.close), findsOneWidget);

        // Tapping 'X' unassigns the bookmark
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(cubit.isAyahBookmarked(2, 6), isFalse);
      },
    );
  });
}
