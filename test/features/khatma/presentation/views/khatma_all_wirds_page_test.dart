import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/views/khatma_all_wirds_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhatmaAllWirdsPage Widget Tests (References 24, 25, 33, 35)', () {
    late Khatma canonicalKhatma;

    setUp(() {
      final now = DateTime(2026, 11, 10);
      const calculator = KhatmaWirdCalculator();
      final wirds = calculator.calculateWirds(
        program: KhatmaProgram.defaultProgram,
        startDate: now,
        startWirdNumber: 1,
      );

      canonicalKhatma = Khatma(
        id: 'canonical_test_khatma',
        programId: KhatmaProgram.defaultProgram.id,
        programTitle: KhatmaProgram.defaultProgram.title,
        totalDays: 29,
        startDate: now,
        wirds: wirds,
        completedWirdsCount: 1,
        createdAt: now,
      );
    });

    Future<void> pumpAllWirdsPage(WidgetTester tester, {Khatma? khatma}) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392, 844),
          builder: (_, __) => MaterialApp(
            locale: const Locale('ar'),
            theme: AppTheme.lightTheme,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: KhatmaAllWirdsPage(khatma: khatma ?? canonicalKhatma),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders app bar with title and green back arrow', (
      tester,
    ) async {
      await pumpAllWirdsPage(tester);

      expect(find.text(AppStrings.tr(AppStrings.allWirds)), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders initial rows matching Screenshot 24 (Days 1 to 8)', (
      tester,
    ) async {
      await pumpAllWirdsPage(tester);

      // Day 1
      expect(find.text('ورد اليوم ١'), findsOneWidget);
      expect(find.text('من الفاتحة إلى البقرة: ١٤١'), findsOneWidget);

      // Day 2
      expect(find.text('ورد اليوم ٢'), findsOneWidget);
      expect(find.text('من البقرة: ١٤٢ إلى البقرة: ٢٥٢'), findsOneWidget);

      // Day 3
      expect(find.text('ورد اليوم ٣'), findsOneWidget);
      expect(find.text('من البقرة: ٢٥٣ إلى آل عمران: ٩٢'), findsOneWidget);

      // Day 6 (customTitle)
      expect(find.text('ورد اليوم ٦'), findsOneWidget);
      expect(find.text('المائدة'), findsOneWidget);

      // Day 7
      expect(find.text('ورد اليوم ٧'), findsOneWidget);
      expect(find.text('الأنعام'), findsOneWidget);

      // Day 8
      expect(find.text('ورد اليوم ٨'), findsOneWidget);
      expect(find.text('الأعراف'), findsOneWidget);
    });

    testWidgets(
      'scrolls and displays final rows matching Screenshot 25 (Days 22 to 29)',
      (tester) async {
        await pumpAllWirdsPage(tester);

        // Scroll to end of list
        final listFinder = find.byType(Scrollable);
        await tester.scrollUntilVisible(
          find.text('ورد اليوم ٢٩'),
          500,
          scrollable: listFinder,
        );
        await tester.pumpAndSettle();

        // Day 22
        expect(find.text('ورد اليوم ٢٢'), findsOneWidget);
        expect(find.text('يس و الصافات و ص'), findsOneWidget);

        // Day 26
        expect(find.text('ورد اليوم ٢٦'), findsOneWidget);
        expect(find.text('من ق إلى الحديد'), findsOneWidget);

        // Day 29
        expect(find.text('ورد اليوم ٢٩'), findsOneWidget);
        expect(find.text('من النبأ إلى الناس'), findsOneWidget);
      },
    );

    testWidgets('renders checkmark on completed wird', (tester) async {
      // Modify Day 1 to be completed
      final updatedWirds = canonicalKhatma.wirds.map((w) {
        if (w.dayNumber == 1) return w.copyWith(isCompleted: true);
        return w;
      }).toList();

      final khatmaWithCompleted = canonicalKhatma.copyWith(wirds: updatedWirds);
      await pumpAllWirdsPage(tester, khatma: khatmaWithCompleted);

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
