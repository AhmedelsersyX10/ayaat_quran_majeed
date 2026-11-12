import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/starred/data/repositories/starred_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_cubit.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/views/starred_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/starred_repository_impl_test.dart';

void main() {
  late FakeStarredLocalDataSource localDataSource;
  late StarredRepositoryImpl repository;
  late StarredCubit cubit;

  setUp(() {
    localDataSource = FakeStarredLocalDataSource();
    repository = StarredRepositoryImpl(localDataSource: localDataSource);
    cubit = StarredCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  Widget buildTestWidget(StarredCubit starredCubit) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider<StarredCubit>.value(
            value: starredCubit,
            child: const StarredTabView(),
          ),
        ),
      ),
    );
  }

  group('StarredTabView Widget Tests (Screens 12 & 28)', () {
    testWidgets(
      'renders empty state matching screen 12 when no verses are starred',
      (tester) async {
        await cubit.loadStarredVerses();

        await tester.pumpWidget(buildTestWidget(cubit));
        await tester.pumpAndSettle();

        // 1. Title in AppBar
        expect(
          find.text(AppStrings.tr(AppStrings.starredTitle)),
          findsOneWidget,
        );

        // 2. Empty text in body
        expect(
          find.text(AppStrings.tr(AppStrings.emptyStarredTitle)),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders populated grouped list matching screen 28 when verses exist',
      (tester) async {
        // Add verses from Al-Baqarah: 2, 4, 5 (exact match to screen 28)
        await repository.addStarred(2, 2);
        await repository.addStarred(2, 4);
        await repository.addStarred(2, 5);

        await cubit.loadStarredVerses();

        await tester.pumpWidget(buildTestWidget(cubit));
        await tester.pumpAndSettle();

        // 1. Title
        expect(
          find.text(AppStrings.tr(AppStrings.starredTitle)),
          findsOneWidget,
        );

        // 2. Surah header: "البقرة"
        expect(find.text('البقرة'), findsWidgets);

        // 3. Subtitles formatted as "البقرة: ٢ - الصفحة ٢", etc.
        final expectedSubtitle2 = formatPageAyahLabel(
          surahName: 'البقرة',
          ayahNumber: 2,
          pageNumber: 2,
        );
        final expectedSubtitle4 = formatPageAyahLabel(
          surahName: 'البقرة',
          ayahNumber: 4,
          pageNumber: 2,
        );
        final expectedSubtitle5 = formatPageAyahLabel(
          surahName: 'البقرة',
          ayahNumber: 5,
          pageNumber: 2,
        );

        expect(find.text(expectedSubtitle2), findsOneWidget);
        expect(find.text(expectedSubtitle4), findsOneWidget);
        expect(find.text(expectedSubtitle5), findsOneWidget);

        // 4. Verify dividers exist between items (2 dividers for 3 items)
        expect(find.byType(Divider), findsNWidgets(2));
      },
    );
  });
}
