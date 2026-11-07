import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/page_search_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/search_navigation_target.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/search_query_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/verse_search_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_state.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/views/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class StubSearchRepository implements SearchRepository {
  SearchQueryResult stubResult;

  StubSearchRepository({SearchQueryResult? initialResult})
      : stubResult = initialResult ?? const SearchQueryResult.empty();

  @override
  Future<void> init() async {}

  @override
  Future<SearchQueryResult> search(String query) async {
    return stubResult;
  }
}

Widget createSearchTestHarness({
  required SearchCubit cubit,
  SearchNavigationTarget? poppedTarget,
  void Function(SearchNavigationTarget?)? onPopped,
}) {
  return ScreenUtilInit(
    designSize: const Size(392, 852),
    minTextAdapt: true,
    builder: (context, child) => MaterialApp(
      home: Builder(
        builder: (innerContext) => Scaffold(
          body: ElevatedButton(
            key: const Key('open_search_button'),
            onPressed: () async {
              final result = await Navigator.of(innerContext).push<SearchNavigationTarget>(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<SearchCubit>.value(
                    value: cubit,
                    child: const SearchPage(),
                  ),
                ),
              );
              onPopped?.call(result);
            },
            child: const Text('Open Search'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SearchPage Widget Tests', () {
    late StubSearchRepository repository;
    late SearchCubit cubit;

    setUp(() {
      repository = StubSearchRepository();
      cubit = SearchCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('Renders top bar with hint and back arrow in initial state (Screenshot 21)', (tester) async {
      await tester.pumpWidget(createSearchTestHarness(cubit: cubit));
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_input_field')), findsOneWidget);
      expect(find.byKey(const Key('search_back_button')), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.searchHint)), findsOneWidget);

      // Scrim is present in initial state
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Renders verse results list with counter matching Screenshot 15', (tester) async {
      repository.stubResult = const SearchQueryResult(
        verses: [
          VerseSearchResult(
            surahNumber: 2,
            verseNumber: 111,
            pageNumber: 17,
            originalText: 'وَقَالُوا لَن يَدْخُلَ الْجَنَّةَ إِلَّا مَن كَانَ هُودًا',
            surahName: 'البقرة',
            score: 70,
          ),
          VerseSearchResult(
            surahNumber: 2,
            verseNumber: 134,
            pageNumber: 20,
            originalText: 'تِلْكَ أُمَّةٌ قَدْ خَلَتْ لَهَا مَا كَسَبَتْ',
            surahName: 'البقرة',
            score: 60,
          ),
        ],
        query: 'تلك',
      );

      await tester.pumpWidget(createSearchTestHarness(cubit: cubit));
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byKey(const Key('search_input_field')), 'تلك');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Counter header "الآيات (٢)"
      expect(find.text('${AppStrings.tr(AppStrings.searchVersesHeader)} (${toArabicDigits(2)})'), findsOneWidget);

      // Verses
      expect(find.text(formatAyahLabel('البقرة', 111)), findsOneWidget);
      expect(find.text(toArabicDigits(17)), findsOneWidget);
      expect(find.text(formatAyahLabel('البقرة', 134)), findsOneWidget);
      expect(find.text(toArabicDigits(20)), findsOneWidget);
    });

    testWidgets('Renders page navigation card when page number is searched', (tester) async {
      repository.stubResult = const SearchQueryResult(
        verses: [],
        pageResult: PageSearchResult(
          pageNumber: 20,
          surahNumber: 2,
          verseNumber: 127,
          surahName: 'البقرة',
        ),
        query: '20',
      );

      await tester.pumpWidget(createSearchTestHarness(cubit: cubit));
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_input_field')), '20');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Page card title
      expect(find.text('${AppStrings.tr(AppStrings.goToPage)} ${toArabicDigits(20)}'), findsOneWidget);
      expect(find.text('البقرة - ${AppStrings.tr(AppStrings.ayah)} ${toArabicDigits(127)}'), findsOneWidget);
    });

    testWidgets('Renders empty state when query returns no matches', (tester) async {
      repository.stubResult = const SearchQueryResult(
        verses: [],
        pageResult: null,
        query: 'unknown',
      );

      await tester.pumpWidget(createSearchTestHarness(cubit: cubit));
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_input_field')), 'unknown');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tr(AppStrings.noSearchResults)), findsOneWidget);
    });

    testWidgets('Tapping a verse item pops with SearchNavigationTarget', (tester) async {
      SearchNavigationTarget? poppedTarget;

      repository.stubResult = const SearchQueryResult(
        verses: [
          VerseSearchResult(
            surahNumber: 2,
            verseNumber: 111,
            pageNumber: 17,
            originalText: 'وَقَالُوا لَن يَدْخُلَ الْجَنَّةَ',
            surahName: 'البقرة',
            score: 70,
          ),
        ],
        query: 'تلك',
      );

      await tester.pumpWidget(
        createSearchTestHarness(
          cubit: cubit,
          onPopped: (target) => poppedTarget = target,
        ),
      );
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_input_field')), 'تلك');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.text(formatAyahLabel('البقرة', 111)));
      await tester.pumpAndSettle();

      expect(poppedTarget, isNotNull);
      expect(poppedTarget!.pageNumber, 17);
      expect(poppedTarget!.surahNumber, 2);
      expect(poppedTarget!.ayahNumber, 111);
    });

    testWidgets('Tapping page card pops with SearchNavigationTarget', (tester) async {
      SearchNavigationTarget? poppedTarget;

      repository.stubResult = const SearchQueryResult(
        verses: [],
        pageResult: PageSearchResult(
          pageNumber: 20,
          surahNumber: 2,
          verseNumber: 127,
          surahName: 'البقرة',
        ),
        query: '20',
      );

      await tester.pumpWidget(
        createSearchTestHarness(
          cubit: cubit,
          onPopped: (target) => poppedTarget = target,
        ),
      );
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_input_field')), '20');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('${AppStrings.tr(AppStrings.goToPage)} ${toArabicDigits(20)}'));
      await tester.pumpAndSettle();

      expect(poppedTarget, isNotNull);
      expect(poppedTarget!.pageNumber, 20);
      expect(poppedTarget!.surahNumber, 2);
      expect(poppedTarget!.ayahNumber, 127);
    });

    testWidgets('Back button pops without navigation target', (tester) async {
      SearchNavigationTarget? poppedTarget;

      await tester.pumpWidget(
        createSearchTestHarness(
          cubit: cubit,
          onPopped: (target) => poppedTarget = target,
        ),
      );
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('search_back_button')));
      await tester.pumpAndSettle();

      expect(poppedTarget, isNull);
    });

    testWidgets('Clear button clears text input and resets to SearchInitial', (tester) async {
      await tester.pumpWidget(createSearchTestHarness(cubit: cubit));
      await tester.tap(find.byKey(const Key('open_search_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_input_field')), 'تلك');
      await tester.pump();

      expect(find.byKey(const Key('search_clear_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('search_clear_button')));
      await tester.pump();

      final input = tester.widget<TextField>(find.byKey(const Key('search_input_field')));
      expect(input.controller?.text, isEmpty);
      expect(cubit.state, isA<SearchInitial>());
    });
  });
}
