import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/quarter_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/quarters_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required List<QuarterIndexItem> quarters,
    int currentReadingQuarter = 1,
    QuarterSelectedCallback? onQuarterSelected,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392.7, 800.7),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuartersListView(
              quarters: quarters,
              currentReadingQuarter: currentReadingQuarter,
              onQuarterSelected: onQuarterSelected,
            ),
          ),
        ),
      ),
    );
  }

  final testQuarters = [
    // Hizb 1 - Quarter 1
    const QuarterIndexItem(
      quarterNumber: 1,
      hizbNumber: 1,
      quarterInHizb: 1,
      surahNumber: 1,
      surahNameArabic: 'الفاتحة',
      ayahNumber: 1,
      pageNumber: 1,
      ayahText: 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ',
    ),
    // Hizb 1 - Quarter 2 (1/4)
    const QuarterIndexItem(
      quarterNumber: 2,
      hizbNumber: 1,
      quarterInHizb: 2,
      surahNumber: 2,
      surahNameArabic: 'البقرة',
      ayahNumber: 26,
      pageNumber: 5,
      ayahText: 'إِنَّ اللَّهَ لَا يَسْتَحْىِۦٓ أَن يَضْرِبَ مَثَلًا',
    ),
    // Hizb 1 - Quarter 3 (1/2)
    const QuarterIndexItem(
      quarterNumber: 3,
      hizbNumber: 1,
      quarterInHizb: 3,
      surahNumber: 2,
      surahNameArabic: 'البقرة',
      ayahNumber: 44,
      pageNumber: 7,
      ayahText: 'أَتَأْمُرُونَ النَّاسَ بِالْبِرِّ',
    ),
    // Hizb 1 - Quarter 4 (3/4)
    const QuarterIndexItem(
      quarterNumber: 4,
      hizbNumber: 1,
      quarterInHizb: 4,
      surahNumber: 2,
      surahNameArabic: 'البقرة',
      ayahNumber: 60,
      pageNumber: 9,
      ayahText: 'وَإِذِ اسْتَسْقَىٰ مُوسَىٰ لِقَوْمِهِۦ',
    ),
    // Hizb 2 - Quarter 1
    const QuarterIndexItem(
      quarterNumber: 5,
      hizbNumber: 2,
      quarterInHizb: 1,
      surahNumber: 2,
      surahNameArabic: 'البقرة',
      ayahNumber: 75,
      pageNumber: 11,
      ayahText: 'أَفَتَطْمَعُونَ أَن يُؤْمِنُوا لَكُمْ',
    ),
  ];

  group('QuartersListView Widget Tests (Reference 04)', () {
    testWidgets('renders all quarters with verse snippets and metadata', (tester) async {
      await tester.pumpWidget(buildTestableWidget(quarters: testQuarters));
      await tester.pumpAndSettle();

      // Opening verse text snippets
      expect(find.text('بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ'), findsOneWidget);
      expect(find.text('إِنَّ اللَّهَ لَا يَسْتَحْىِۦٓ أَن يَضْرِبَ مَثَلًا'), findsOneWidget);
      expect(find.text('أَتَأْمُرُونَ النَّاسَ بِالْبِرِّ'), findsOneWidget);

      // Subtitle metadata with Arabic-Indic digits
      expect(find.text('الفاتحة: ١ - الصفحة ١'), findsOneWidget);
      expect(find.text('البقرة: ٢٦ - الصفحة ٥'), findsOneWidget);
      expect(find.text('البقرة: ٤٤ - الصفحة ٧'), findsOneWidget);
    });

    testWidgets('renders Hizb start badge with Hizb number and highlights current reading position', (tester) async {
      // Current reading position is Quarter 1
      await tester.pumpWidget(buildTestableWidget(
        quarters: testQuarters,
        currentReadingQuarter: 1,
      ));
      await tester.pumpAndSettle();

      // Quarter 1 shows Hizb 1 number '١'
      expect(find.text('١'), findsOneWidget);

      // Quarter 5 shows Hizb 2 number '٢'
      expect(find.text('٢'), findsOneWidget);

      // Verify Quarter 1 container has primary green background
      final q1Finder = find.ancestor(
        of: find.text('١'),
        matching: find.byType(Container),
      ).first;
      final q1Container = tester.widget<Container>(q1Finder);
      final q1Dec = q1Container.decoration as BoxDecoration;
      expect(q1Dec.color, equals(AppColors.primary));

      // Verify Quarter 5 (inactive Hizb start) container has neutral beige background
      final q5Finder = find.ancestor(
        of: find.text('٢'),
        matching: find.byType(Container),
      ).first;
      final q5Container = tester.widget<Container>(q5Finder);
      final q5Dec = q5Container.decoration as BoxDecoration;
      expect(q5Dec.color, equals(const Color(0xFFDDD1C5)));
    });

    testWidgets('renders HizbQuarterIndicator for quarterInHizb 2, 3, 4 with correct types', (tester) async {
      await tester.pumpWidget(buildTestableWidget(quarters: testQuarters));
      await tester.pumpAndSettle();

      final indicatorFinders = find.byType(HizbQuarterIndicator);
      // Quarters 2, 3, 4 are HizbQuarterIndicators
      expect(indicatorFinders, findsNWidgets(3));

      final indicator1 = tester.widget<HizbQuarterIndicator>(indicatorFinders.at(0));
      expect(indicator1.type, equals(HizbQuarterType.firstQuarter));

      final indicator2 = tester.widget<HizbQuarterIndicator>(indicatorFinders.at(1));
      expect(indicator2.type, equals(HizbQuarterType.half));

      final indicator3 = tester.widget<HizbQuarterIndicator>(indicatorFinders.at(2));
      expect(indicator3.type, equals(HizbQuarterType.threeQuarters));
    });

    testWidgets('highlights intermediate quarter indicator in primary green when current', (tester) async {
      // Current reading position is Quarter 2 (1/4 arc)
      await tester.pumpWidget(buildTestableWidget(
        quarters: testQuarters,
        currentReadingQuarter: 2,
      ));
      await tester.pumpAndSettle();

      final indicatorFinders = find.byType(HizbQuarterIndicator);
      final indicator1 = tester.widget<HizbQuarterIndicator>(indicatorFinders.at(0));

      // Quarter 2 active color is primary green
      expect(indicator1.activeColor, equals(AppColors.primary));

      // Quarter 3 (inactive) active color is neutral taupe
      final indicator2 = tester.widget<HizbQuarterIndicator>(indicatorFinders.at(1));
      expect(indicator2.activeColor, equals(const Color(0xFFBAA797)));
    });

    testWidgets('tapping a quarter row invokes onQuarterSelected with pageNumber and quarterNumber', (tester) async {
      int? tappedPage;
      int? tappedQuarter;

      await tester.pumpWidget(buildTestableWidget(
        quarters: testQuarters,
        onQuarterSelected: (page, quarter) {
          tappedPage = page;
          tappedQuarter = quarter;
        },
      ));
      await tester.pumpAndSettle();

      // Tap on Quarter 2 (Al-Baqarah 26, Page 5)
      await tester.tap(find.text('إِنَّ اللَّهَ لَا يَسْتَحْىِۦٓ أَن يَضْرِبَ مَثَلًا'));
      await tester.pumpAndSettle();

      expect(tappedPage, equals(5));
      expect(tappedQuarter, equals(2));
    });

    testWidgets('renders empty list gracefully without error', (tester) async {
      await tester.pumpWidget(buildTestableWidget(quarters: const []));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(HizbQuarterIndicator), findsNothing);
    });
  });
}
