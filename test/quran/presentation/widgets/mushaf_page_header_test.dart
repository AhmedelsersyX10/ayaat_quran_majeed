import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  const metadataService = QuranMetadataService();

  group('MushafPageHeader Widget Tests', () {
    testWidgets('renders Al-Fatihah and Juz 1 on page 1 matching reference 01', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageHeader(pageNumber: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('الجزء الأول'), findsOneWidget);
      expect(find.text('الفاتحة'), findsOneWidget);

      // Verify ordering in RTL Row: first child is rightmost (Juz), second is leftmost (Surah)
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final rowWidget = tester.widget<Row>(rowFinder);
      expect(rowWidget.mainAxisAlignment, MainAxisAlignment.spaceBetween);

      final text1 = rowWidget.children[0] as Text;
      final text2 = rowWidget.children[1] as Text;
      expect(text1.data, 'الجزء الأول');
      expect(text2.data, 'الفاتحة');
    });

    testWidgets('renders Al-Baqarah and Juz 1 on page 3 matching reference 02', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageHeader(pageNumber: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.text('الجزء الأول'), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);
    });

    testWidgets('renders At-Tawbah and correct Juz on page 187', (tester) async {
      final expectedJuz = metadataService.getJuzNumberForPage(187);
      final expectedJuzName = metadataService.getJuzNameArabic(expectedJuz);
      final expectedSurah = metadataService.getSurahNameArabicForPage(187);

      expect(expectedSurah, 'التوبة');

      await tester.pumpWidget(
        _wrap(const MushafPageHeader(pageNumber: 187)),
      );
      await tester.pumpAndSettle();

      expect(find.text('الجزء $expectedJuzName'), findsOneWidget);
      expect(find.text('التوبة'), findsOneWidget);
    });

    testWidgets('renders empty shrink for out of range page numbers', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageHeader(pageNumber: 0)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MushafPageHeader), findsOneWidget);
      expect(find.byType(Row), findsNothing);

      await tester.pumpWidget(
        _wrap(const MushafPageHeader(pageNumber: 605)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Row), findsNothing);
    });
  });
}

