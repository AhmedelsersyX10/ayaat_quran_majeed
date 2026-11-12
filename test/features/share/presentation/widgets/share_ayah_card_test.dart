import 'package:ayaat_quran_majeed/features/share/presentation/theme/share_card_theme.dart';
import 'package:ayaat_quran_majeed/features/share/domain/entities/share_params.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/widgets/share_ayah_card.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  const metadataService = QuranMetadataService();

  group('ShareAyahCard Widget Tests', () {
    testWidgets('renders surah header badge with surah name and icon', (
      tester,
    ) async {
      const params = ShareParams(
        surahNumber: 1,
        surahName: 'الفاتحة',
        fromAyah: 1,
        toAyah: 1,
      );

      await tester.pumpWidget(
        _wrapWidget(
          const ShareAyahCard(params: params, metadataService: metadataService),
        ),
      );

      expect(find.text('سورة الفاتحة'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets(
      'renders Basmalah for Surah 2 Ayah 1, but omits for Surah 1 and Surah 9',
      (tester) async {
        // 1. Surah 2 Ayah 1 -> Basmalah should be visible
        const paramsBaqarah = ShareParams(
          surahNumber: 2,
          surahName: 'البقرة',
          fromAyah: 1,
          toAyah: 1,
        );
        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: paramsBaqarah,
              metadataService: metadataService,
            ),
          ),
        );
        expect(
          find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
          findsOneWidget,
        );

        // 2. Surah 1 Ayah 1 -> Separate Basmalah omitted (verse itself is Basmalah)
        const paramsFatihah = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
        );
        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: paramsFatihah,
              metadataService: metadataService,
            ),
          ),
        );
        expect(
          find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
          findsNothing,
        );

        // 3. Surah 9 Ayah 1 -> At-Tawbah has no Basmalah
        const paramsTawbah = ShareParams(
          surahNumber: 9,
          surahName: 'التوبة',
          fromAyah: 1,
          toAyah: 1,
        );
        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: paramsTawbah,
              metadataService: metadataService,
            ),
          ),
        );
        expect(
          find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
          findsNothing,
        );
      },
    );

    testWidgets('renders user note quote when noteText is provided (Ref 29)', (
      tester,
    ) async {
      const params = ShareParams(
        surahNumber: 1,
        surahName: 'الفاتحة',
        fromAyah: 2,
        toAyah: 2,
        noteText: 'الحمد لله رب العالمين: إثبات الحمد والثناء لله تعالى',
      );

      await tester.pumpWidget(
        _wrapWidget(
          const ShareAyahCard(params: params, metadataService: metadataService),
        ),
      );

      expect(
        find.text('الحمد لله رب العالمين: إثبات الحمد والثناء لله تعالى'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
    });

    testWidgets(
      'renders tafsir section when includeTafsir is true and text present',
      (tester) async {
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
          includeTafsir: true,
          tafsirText: 'أبدأ قراءتي باسم الله مستعيناً به',
          tafsirBookName: 'التفسير الميسر',
        );

        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: params,
              metadataService: metadataService,
            ),
          ),
        );

        expect(find.text('التفسير الميسر'), findsOneWidget);
        expect(find.text('أبدأ قراءتي باسم الله مستعيناً به'), findsOneWidget);
        expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'renders app branding in footer when includeAppBranding is true',
      (tester) async {
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
          includeAppBranding: true,
        );

        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: params,
              metadataService: metadataService,
            ),
          ),
        );

        expect(find.text('آيات'), findsOneWidget);
      },
    );

    testWidgets(
      'omits app branding in footer when includeAppBranding is false',
      (tester) async {
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
          includeAppBranding: false,
        );

        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: params,
              metadataService: metadataService,
            ),
          ),
        );

        expect(find.text('آيات'), findsNothing);
      },
    );

    testWidgets('applies dark theme styling and colors faithfully', (
      tester,
    ) async {
      const params = ShareParams(
        surahNumber: 114,
        surahName: 'الناس',
        fromAyah: 1,
        toAyah: 1,
      );

      await tester.pumpWidget(
        _wrapWidget(
          const ShareAyahCard(
            params: params,
            cardTheme: ShareCardTheme.royalDark,
            metadataService: metadataService,
          ),
        ),
      );

      expect(find.text('سورة الناس'), findsOneWidget);
    });

    testWidgets(
      'renders verse text without diacritics when withoutTashkeel is true',
      (tester) async {
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
          withoutTashkeel: true,
        );

        await tester.pumpWidget(
          _wrapWidget(
            const ShareAyahCard(
              params: params,
              metadataService: metadataService,
            ),
          ),
        );

        expect(find.text('سورة الفاتحة'), findsOneWidget);
      },
    );
  });
}
