import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/play_to_sheet.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
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

  group('PlayToSheet Widget Tests (Reference 22)', () {
    const metadataService = QuranMetadataService();

    testWidgets('renders header with Surah name, Eastern Arabic numeral, and actions (البقرة: ٦)', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header title: "البقرة: ٦" (present in header and top verse)
      expect(find.text('البقرة: ٦'), findsWidgets);

      // Back, star, and share icons
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('renders presets card with end of page, end of surah, and continuous recitation', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Preset 1: نهاية الصفحة and الصفحة ٣
      expect(find.text(AppStrings.tr(AppStrings.endOfPage)), findsOneWidget);
      expect(find.text('الصفحة ٣'), findsOneWidget);

      // Preset 2: نهاية السورة and البقرة
      expect(find.text(AppStrings.tr(AppStrings.endOfSurah)), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);

      // Preset 3: تلاوة مستمرة and ∞
      expect(find.text(AppStrings.tr(AppStrings.continuousRecitation)), findsOneWidget);
      expect(find.text('∞'), findsOneWidget);
    });

    testWidgets('tapping نهاية الصفحة selects range ending at last verse of current page', (tester) async {
      PlaybackRange? selectedRange;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
            onRangeSelected: (range) {
              selectedRange = range;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.tr(AppStrings.endOfPage)));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
      expect(selectedRange!.startSurah, 2);
      expect(selectedRange!.startAyah, 6);
      expect(selectedRange!.endSurah, 2);
      expect(selectedRange!.endAyah, 16); // Last verse of page 3 is 2:16
    });

    testWidgets('tapping نهاية السورة selects range ending at last verse of current surah', (tester) async {
      PlaybackRange? selectedRange;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
            onRangeSelected: (range) {
              selectedRange = range;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.tr(AppStrings.endOfSurah)));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
      expect(selectedRange!.startSurah, 2);
      expect(selectedRange!.startAyah, 6);
      expect(selectedRange!.endSurah, 2);
      expect(selectedRange!.endAyah, 286); // Al-Baqarah has 286 verses
    });

    testWidgets('tapping تلاوة مستمرة selects range ending at 114:6', (tester) async {
      PlaybackRange? selectedRange;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
            onRangeSelected: (range) {
              selectedRange = range;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.tr(AppStrings.continuousRecitation)));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
      expect(selectedRange!.startSurah, 2);
      expect(selectedRange!.startAyah, 6);
      expect(selectedRange!.endSurah, 114);
      expect(selectedRange!.endAyah, 6);
    });

    testWidgets('tapping star icon toggles state and invokes callback', (tester) async {
      bool starCalled = false;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            isStarred: false,
            metadataService: metadataService,
            onStarTap: () {
              starCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();

      expect(starCalled, isTrue);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('default tab displays ayat and tapping an ayah selects range', (tester) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      PlaybackRange? selectedRange;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
            onRangeSelected: (range) {
              selectedRange = range;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check 3 tab labels
      expect(find.text(AppStrings.tr(AppStrings.ayatTab)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.pages)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.tabSurahs)), findsOneWidget);

      // Default tab: Ayat. Verify Ayah 6 and Ayah 7 are visible
      expect(find.text('البقرة: ٦'), findsWidgets);
      expect(find.text('البقرة: ٧'), findsOneWidget);

      // Tap an ayah to select range
      await tester.tap(find.text('البقرة: ٧'));
      await tester.pumpAndSettle();
      expect(selectedRange, isNotNull);
      expect(selectedRange!.endSurah, 2);
      expect(selectedRange!.endAyah, 7);
    });

    testWidgets('switching to Pages tab displays pages and selecting page sets range', (tester) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      PlaybackRange? selectedRange;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
            onRangeSelected: (range) {
              selectedRange = range;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.tr(AppStrings.pages)));
      await tester.pumpAndSettle();

      // Verify page list displayed
      expect(find.text('الصفحة ٤'), findsOneWidget);
      await tester.tap(find.text('الصفحة ٤'));
      await tester.pumpAndSettle();
      expect(selectedRange, isNotNull);
      expect(selectedRange!.endSurah, 2);
      expect(selectedRange!.endAyah, 24); // Last verse on page 4 is 2:24
    });

    testWidgets('switching to Surahs tab displays surahs and selecting surah sets range', (tester) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      PlaybackRange? selectedRange;

      await tester.pumpWidget(
        createTestableWidget(
          PlayToSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
            onRangeSelected: (range) {
              selectedRange = range;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.tr(AppStrings.tabSurahs)));
      await tester.pumpAndSettle();

      // Verify surahs list displayed
      expect(find.text('سورة آل عمران'), findsOneWidget);
      await tester.tap(find.text('سورة آل عمران'));
      await tester.pumpAndSettle();
      expect(selectedRange, isNotNull);
      expect(selectedRange!.endSurah, 3);
      expect(selectedRange!.endAyah, 200); // Ali 'Imran has 200 verses
    });
  });
}
