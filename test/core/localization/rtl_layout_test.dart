import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_nav.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_feedback_states.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_list_tile.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildRtlTestWidget({
  required Widget child,
  double textScaleFactor = 1.0,
}) {
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(392.7, 800.7),
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

void main() {
  group('RTL Layout & Directionality Tests', () {
    testWidgets('Directionality is strictly RTL in test harness', (tester) async {
      await tester.pumpWidget(
        _buildRtlTestWidget(
          child: Builder(
            builder: (context) {
              expect(Directionality.of(context), equals(TextDirection.rtl));
              return const Text('اختبار الاتجاه');
            },
          ),
        ),
      );

      expect(find.text('اختبار الاتجاه'), findsOneWidget);
    });

    testWidgets('Renders mixed Arabic text, punctuation, and Arabic-Indic numerals properly', (tester) async {
      final mixedLabel1 = formatPageAyahLabel(surahName: 'البقرة', ayahNumber: 6, pageNumber: 3);
      final mixedLabel2 = formatArabicTime(hour: 9, minute: 32);
      final mixedLabel3 = formatKhatmaDays(30);

      await tester.pumpWidget(
        _buildRtlTestWidget(
          child: Column(
            children: [
              Text(mixedLabel1),
              Text(mixedLabel2),
              Text(mixedLabel3),
            ],
          ),
        ),
      );

      expect(find.text('البقرة: ٦ - الصفحة ٣'), findsOneWidget);
      expect(find.text('٩:٣٢ ص'), findsOneWidget);
      expect(find.text('٣٠ يوما'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBottomNav renders 5 tabs with custom localized items in RTL without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testItems = [
        const AppBottomNavItem(icon: Icons.book, activeIcon: Icons.book, label: 'السور'),
        const AppBottomNavItem(icon: Icons.calendar_today, activeIcon: Icons.calendar_today, label: 'الختمة'),
        const AppBottomNavItem(icon: Icons.bookmark, activeIcon: Icons.bookmark, label: 'الفواصل'),
        const AppBottomNavItem(icon: Icons.star, activeIcon: Icons.star, label: 'مميزة بنجمة'),
        const AppBottomNavItem(icon: Icons.note, activeIcon: Icons.note, label: 'الملاحظات'),
      ];

      await tester.pumpWidget(
        _buildRtlTestWidget(
          child: AppBottomNav(
            currentIndex: 0,
            onTap: (_) {},
            items: testItems,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الختمة'), findsOneWidget);
      expect(find.text('الفواصل'), findsOneWidget);
      expect(find.text('مميزة بنجمة'), findsOneWidget);
      expect(find.text('الملاحظات'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Accessibility & Large Text Scale Tests (1.0x, 1.5x, 2.0x)', () {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('Core components render without overflow at text scale ${scale}x', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildRtlTestWidget(
            textScaleFactor: scale,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppCard(
                    child: AppListTile(
                      title: Text(formatAyahLabel('الفاتحة', 1)),
                      subtitle: Text(formatPageAyahLabel(surahName: 'الفاتحة', ayahNumber: 1, pageNumber: 1)),
                      trailing: Text(formatArabicTime(hour: 7, minute: 30)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppStepper(
                    value: 3,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  AppEmptyState(
                    title: 'لا توجد ختمة نشطة',
                    description: 'ابدأ ختمة جديدة لقراءة القرآن الكريم بانتظام',
                    buttonText: 'بدء ختمة جديدة',
                    onButtonPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  AppErrorState(
                    message: 'حدث خطأ في الاتصال بالشبكة',
                    retryText: 'أعد المحاولة',
                    onRetry: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('الفاتحة: ١'), findsOneWidget);
        expect(find.text('الفاتحة: ١ - الصفحة ١'), findsOneWidget);
        expect(find.text('٧:٣٠ ص'), findsOneWidget);
        expect(find.text(toArabicDigits('3')), findsOneWidget);
        expect(find.text('لا توجد ختمة نشطة'), findsOneWidget);
        expect(find.text('أعد المحاولة'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
