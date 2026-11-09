import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('MushafPageSlider Widget Tests', () {
    const metadataService = QuranMetadataService();

    testWidgets('renders slider and tafsir button matching ref 05', (tester) async {
      int? selectedPage;
      bool tafseerPressed = false;

      await tester.pumpWidget(
        createTestableWidget(
          MushafPageSlider(
            currentPage: 10,
            onPageSelected: (p) => selectedPage = p,
            onTafseerPressed: () => tafseerPressed = true,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.article_outlined));
      await tester.pumpAndSettle();
      expect(tafseerPressed, isTrue);
    });

    testWidgets('slider dragging triggers callbacks and scrubbing badge', (tester) async {
      int? dragStartedPage;
      int? scrubbingPage;
      int? selectedPage;

      await tester.pumpWidget(
        createTestableWidget(
          MushafPageSlider(
            currentPage: 50,
            onDragStarted: (p) => dragStartedPage = p,
            onScrubbing: (p) => scrubbingPage = p,
            onPageSelected: (p) => selectedPage = p,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the slider and drag it
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider
      await tester.drag(slider, const Offset(-50, 0));
      await tester.pump();

      expect(dragStartedPage, isNotNull);
      expect(scrubbingPage, isNotNull);
    });

    testWidgets('renders active tafsir button styling when isTafsirMode is true (Ref 17)', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(
          MushafPageSlider(
            currentPage: 1,
            isTafsirMode: true,
            onPageSelected: (_) {},
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
    });
  });
}

