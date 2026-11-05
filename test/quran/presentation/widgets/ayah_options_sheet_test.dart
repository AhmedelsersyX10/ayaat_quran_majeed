import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_options_sheet.dart';
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

  group('AyahOptionsSheet Widget Tests (References 19 & 20)', () {
    const metadataService = QuranMetadataService();

    testWidgets('renders header with Surah name and Arabic numeral (البقرة : ٦ matching Ref 19)', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const AyahOptionsSheet(
            surahNumber: 2, // Al-Baqarah
            verseNumber: 6, // Ayah 6 (multi-line in ref 19)
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header title: "البقرة : ٦"
      expect(find.text('البقرة : ٦'), findsOneWidget);

      // Top action buttons: Star & Share
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });

    testWidgets('renders all 4 option cards matching references 19 & 20', (tester) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestableWidget(
          const AyahOptionsSheet(
            surahNumber: 2,
            verseNumber: 6,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Card 1: Bookmarks (Visible in half height ref 19)
      expect(find.text(AppStrings.tr(AppStrings.redBookmark)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.anotherBookmark)), findsOneWidget);

      // Card 2: Recitation (Visible in half height ref 19)
      expect(find.text(AppStrings.tr(AppStrings.recitation)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.playTo)), findsOneWidget);

      // Drag up header to expand to full height matching ref 20
      await tester.drag(find.text('البقرة : ٦'), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Card 3: Library (Fully visible in expanded ref 20)
      expect(find.text(AppStrings.tr(AppStrings.library)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.librarySubtitle)), findsOneWidget);

      // Card 4: Notes (Fully visible in expanded ref 20)
      expect(find.text(AppStrings.tr(AppStrings.notesTitle)), findsOneWidget);
    });

    testWidgets('triggers all interaction callbacks when tapped (contract verification)', (tester) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool starTapped = false;
      bool shareTapped = false;
      bool bookmarkTapped = false;
      bool anotherBookmarkTapped = false;
      bool reciteTapped = false;
      bool playToTapped = false;
      bool libraryTapped = false;
      bool notesTapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          AyahOptionsSheet(
            surahNumber: 2,
            verseNumber: 6,
            onStarTap: () => starTapped = true,
            onShareTap: () => shareTapped = true,
            onBookmarkTap: () => bookmarkTapped = true,
            onAnotherBookmarkTap: () => anotherBookmarkTapped = true,
            onReciteTap: () => reciteTapped = true,
            onPlayToTap: () => playToTapped = true,
            onLibraryTap: () => libraryTapped = true,
            onNotesTap: () => notesTapped = true,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand to full height by dragging the scrollable ListView connected to DraggableScrollableSheet
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // 1. Star tap
      await tester.tap(find.byIcon(Icons.star_border_rounded));
      expect(starTapped, isTrue);

      // 2. Share tap
      await tester.tap(find.byIcon(Icons.share_outlined));
      expect(shareTapped, isTrue);

      // 3. Red Bookmark tap
      await tester.tap(find.text(AppStrings.tr(AppStrings.redBookmark)));
      expect(bookmarkTapped, isTrue);

      // 4. Another Bookmark tap
      await tester.tap(find.text(AppStrings.tr(AppStrings.anotherBookmark)));
      expect(anotherBookmarkTapped, isTrue);

      // 5. Recitation tap
      await tester.tap(find.text(AppStrings.tr(AppStrings.recitation)));
      expect(reciteTapped, isTrue);

      // 6. Play to tap
      await tester.tap(find.text(AppStrings.tr(AppStrings.playTo)));
      expect(playToTapped, isTrue);

      // 7. Library tap
      await tester.tap(find.text(AppStrings.tr(AppStrings.library)));
      expect(libraryTapped, isTrue);

      // 8. Notes tap
      await tester.tap(find.text(AppStrings.tr(AppStrings.notesTitle)));
      expect(notesTapped, isTrue);
    });

    testWidgets('renders filled star icon when isStarred is true', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const AyahOptionsSheet(
            surahNumber: 2,
            verseNumber: 255,
            isStarred: true,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsNothing);
    });
  });
}
