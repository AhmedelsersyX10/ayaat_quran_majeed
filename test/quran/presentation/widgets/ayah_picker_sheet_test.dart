import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_picker_sheet.dart';
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

  group('AyahPickerSheet Widget Tests', () {
    const metadataService = QuranMetadataService();

    testWidgets('renders title, surah name banner, and verses list', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const AyahPickerSheet(
            surahNumber: 1, // Al-Fatiha
            initialAyahNumber: 1,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tr(AppStrings.selectAyah)), findsOneWidget);
      expect(find.text('الفاتحة'), findsWidgets);
      // Al-Fatiha has 7 verses
      expect(find.text('الفاتحة : ١'), findsOneWidget);
      // Selected verse 1 has checkmark
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('renders checkmark on selected verse 7 matching ref 39', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const AyahPickerSheet(
            surahNumber: 1,
            initialAyahNumber: 7,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final verse7 = find.text('الفاتحة : ٧');
      if (tester.any(verse7)) {
        expect(verse7, findsOneWidget);
      } else {
        await tester.scrollUntilVisible(verse7, 200.0);
        expect(verse7, findsOneWidget);
      }
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('tapping a verse triggers callback with chosen ayah number', (tester) async {
      int? chosenAyah;

      await tester.pumpWidget(
        createTestableWidget(
          AyahPickerSheet(
            surahNumber: 1,
            initialAyahNumber: 1,
            onAyahSelected: (a) => chosenAyah = a,
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on verse 2
      final verse2 = find.text('الفاتحة : ٢');
      expect(verse2, findsOneWidget);
      await tester.tap(verse2);
      await tester.pumpAndSettle();

      expect(chosenAyah, 2);
    });

    testWidgets('triggers onVerseSelected with both surah and ayah numbers', (tester) async {
      int? chosenSurah;
      int? chosenAyah;

      await tester.pumpWidget(
        createTestableWidget(
          AyahPickerSheet(
            surahNumber: 1,
            initialAyahNumber: 1,
            onVerseSelected: (s, a) {
              chosenSurah = s;
              chosenAyah = a;
            },
            metadataService: metadataService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final verse3 = find.text('الفاتحة : ٣');
      expect(verse3, findsOneWidget);
      await tester.tap(verse3);
      await tester.pumpAndSettle();

      expect(chosenSurah, 1);
      expect(chosenAyah, 3);
    });
  });
}
