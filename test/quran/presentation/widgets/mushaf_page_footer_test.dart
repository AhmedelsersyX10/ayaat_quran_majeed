import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_footer.dart';
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

  group('QuranMetadataService Hizb & Header Methods', () {
    test('getHizbTextByPage returns correct labels', () {
      expect(metadataService.getHizbTextByPage(1), 'الحزب ١');
      expect(metadataService.getHizbTextByPage(3), isEmpty);
    });

    test('getJuzNameArabic returns correct Arabic ordinals for 1-30', () {
      expect(metadataService.getJuzNameArabic(1), 'الأول');
      expect(metadataService.getJuzNameArabic(2), 'الثاني');
      expect(metadataService.getJuzNameArabic(10), 'العاشر');
      expect(metadataService.getJuzNameArabic(30), 'الثلاثون');
    });

    test('getJuzNumberForPage returns correct Juz numbers', () {
      expect(metadataService.getJuzNumberForPage(1), 1);
      expect(metadataService.getJuzNumberForPage(3), 1);
      expect(metadataService.getJuzNumberForPage(187), 10);
      expect(metadataService.getJuzNumberForPage(604), 30);
    });
  });

  group('MushafPageFooter Widget Tests', () {
    testWidgets('renders page 1 badge with page number and hizb label (ref 01)', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageFooter(pageNumber: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('١'), findsOneWidget);
      expect(find.text('الحزب ١'), findsOneWidget);

      // Verify row order in RTL: page number is child 0 (rightmost), hizb is child 2 (leftmost)
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final rowWidget = tester.widget<Row>(rowFinder);

      final text1 = rowWidget.children[0] as Text;
      final text2 = rowWidget.children[2] as Text;
      expect(text1.data, '١');
      expect(text2.data, 'الحزب ١');
    });

    testWidgets('renders page 3 badge with only page number (ref 02)', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageFooter(pageNumber: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.text('٣'), findsOneWidget);
      // No hizb row on page 3
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('renders CustomPainter badge capsule', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageFooter(pageNumber: 1)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MushafBadgePainter),
        findsOneWidget,
      );
    });

    testWidgets('renders empty shrink for out of range page numbers', (tester) async {
      await tester.pumpWidget(
        _wrap(const MushafPageFooter(pageNumber: 0)),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MushafBadgePainter),
        findsNothing,
      );

      await tester.pumpWidget(
        _wrap(const MushafPageFooter(pageNumber: 605)),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MushafBadgePainter),
        findsNothing,
      );
    });
  });
}
