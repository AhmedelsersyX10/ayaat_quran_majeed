import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/surah_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/surahs_grouped_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithApp({required Widget child}) {
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleGroups = [
    const JuzGroup(
      juzNumber: 1,
      nameArabic: 'الأول',
      startPage: 1,
      surahs: [
        SurahIndexItem(
          number: 1,
          nameArabic: 'الفاتحة',
          pageNumber: 1,
          verseCount: 7,
          isMakki: true,
          startJuz: 1,
        ),
        SurahIndexItem(
          number: 2,
          nameArabic: 'البقرة',
          pageNumber: 2,
          verseCount: 286,
          isMakki: false,
          startJuz: 1,
        ),
      ],
    ),
    const JuzGroup(
      juzNumber: 2,
      nameArabic: 'الثاني',
      startPage: 22,
      surahs: [], // Boundary Juz with 0 surahs
    ),
    const JuzGroup(
      juzNumber: 3,
      nameArabic: 'الثالث',
      startPage: 42,
      surahs: [
        SurahIndexItem(
          number: 3,
          nameArabic: 'آل عمران',
          pageNumber: 50,
          verseCount: 200,
          isMakki: false,
          startJuz: 3,
        ),
      ],
    ),
  ];

  group('SurahsGroupedListView Widget Tests (Reference 03)', () {
    testWidgets('renders Juz headers and Surah items matching Reference 03', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          child: SurahsGroupedListView(
            groups: sampleGroups,
            currentReadingSurah: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Juz 1 Header
      expect(find.text('الجزء الأول'), findsOneWidget);

      // Surah 1 (الفاتحة)
      expect(find.text('الفاتحة'), findsOneWidget);
      expect(find.text('الصفحة ١ - آياتها ٧ - مكية'), findsOneWidget);
      expect(find.text('١'), findsOneWidget);

      // Surah 2 (البقرة)
      expect(find.text('البقرة'), findsOneWidget);
      expect(find.text('الصفحة ٢ - آياتها ٢٨٦ - مدنية'), findsOneWidget);
      expect(find.text('٢'), findsOneWidget);

      // Consecutive empty Juz 2 header followed by Juz 3
      expect(find.text('الجزء الثاني'), findsOneWidget);
      expect(find.text('الجزء الثالث'), findsOneWidget);
      expect(find.text('آل عمران'), findsOneWidget);
      expect(find.text('الصفحة ٥٠ - آياتها ٢٠٠ - مدنية'), findsOneWidget);
      expect(find.text('٣'), findsOneWidget);
    });

    testWidgets('highlights active reading surah with green badge and white text', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          child: SurahsGroupedListView(
            groups: sampleGroups,
            currentReadingSurah: 2, // Al-Baqarah active
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the container for Surah 2 (active)
      final text2 = tester.widget<Text>(find.text('٢'));
      expect(text2.style?.color, equals(AppColors.textOnPrimary));

      // Find container ancestor
      final container2Finder = find.ancestor(
        of: find.text('٢'),
        matching: find.byType(Container),
      ).first;
      final container2 = tester.widget<Container>(container2Finder);
      final decoration2 = container2.decoration as BoxDecoration;
      expect(decoration2.color, equals(AppColors.primary));

      // Inactive Surah 1 (الفاتحة)
      final text1 = tester.widget<Text>(find.text('١'));
      expect(text1.style?.color, equals(AppColors.textPrimary));

      final container1Finder = find.ancestor(
        of: find.text('١'),
        matching: find.byType(Container),
      ).first;
      final container1 = tester.widget<Container>(container1Finder);
      final decoration1 = container1.decoration as BoxDecoration;
      expect(decoration1.color, equals(const Color(0xFFDDD1C5)));
    });

    testWidgets('tapping a surah triggers onSurahSelected with page and surah number', (tester) async {
      int? selectedPage;
      int? selectedSurah;

      await tester.pumpWidget(
        _wrapWithApp(
          child: SurahsGroupedListView(
            groups: sampleGroups,
            currentReadingSurah: 1,
            onSurahSelected: (page, surah) {
              selectedPage = page;
              selectedSurah = surah;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Al-Baqarah
      await tester.tap(find.text('البقرة'));
      await tester.pumpAndSettle();

      expect(selectedPage, equals(2));
      expect(selectedSurah, equals(2));
    });

    testWidgets('tapping a Juz header triggers onJuzSelected with start page and juz number', (tester) async {
      int? selectedPage;
      int? selectedJuz;

      await tester.pumpWidget(
        _wrapWithApp(
          child: SurahsGroupedListView(
            groups: sampleGroups,
            onJuzSelected: (page, juz) {
              selectedPage = page;
              selectedJuz = juz;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Juz 2 header (which has no surahs)
      await tester.tap(find.text('الجزء الثاني'));
      await tester.pumpAndSettle();

      expect(selectedPage, equals(22));
      expect(selectedJuz, equals(2));
    });
  });
}
