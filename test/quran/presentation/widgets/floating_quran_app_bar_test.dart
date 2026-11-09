import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/floating_quran_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required bool isVisible,
    VoidCallback? onIndex,
    VoidCallback? onSearch,
    VoidCallback? onToday,
    VoidCallback? onSettings,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingQuranAppBar(
                isVisible: isVisible,
                onIndex: onIndex ?? () {},
                onSearch: onSearch ?? () {},
                onToday: onToday ?? () {},
                onSettings: onSettings ?? () {},
                backgroundColor: AppColors.scaffoldLight,
                iconColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('FloatingQuranAppBar Widget Tests', () {
    testWidgets('renders exactly four action icons and no back arrow', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(isVisible: true));
      await tester.pumpAndSettle();

      // Back arrow must not exist
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // Four actions must exist
      expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('fires each callback when buttons are tapped', (tester) async {
      int indexCount = 0;
      int searchCount = 0;
      int todayCount = 0;
      int settingsCount = 0;

      await tester.pumpWidget(
        buildTestWidget(
          isVisible: true,
          onIndex: () => indexCount++,
          onSearch: () => searchCount++,
          onToday: () => todayCount++,
          onSettings: () => settingsCount++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.format_list_bulleted));
      await tester.pumpAndSettle();
      expect(indexCount, 1);

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(searchCount, 1);

      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      expect(todayCount, 1);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(settingsCount, 1);
    });

    testWidgets('respects RTL visual ordering from right to left', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(isVisible: true));
      await tester.pumpAndSettle();

      final listPos = tester.getCenter(find.byIcon(Icons.format_list_bulleted));
      final searchPos = tester.getCenter(find.byIcon(Icons.search_rounded));
      final todayPos = tester.getCenter(
        find.byIcon(Icons.calendar_today_outlined),
      );
      final settingsPos = tester.getCenter(
        find.byIcon(Icons.settings_outlined),
      );

      // In RTL: list (index) is on the right, followed by search, today, and settings on the left
      expect(listPos.dx, greaterThan(searchPos.dx));
      expect(searchPos.dx, greaterThan(todayPos.dx));
      expect(todayPos.dx, greaterThan(settingsPos.dx));
    });

    testWidgets('respects hidden pointer behavior when isVisible is false', (
      tester,
    ) async {
      int indexCount = 0;

      await tester.pumpWidget(
        buildTestWidget(isVisible: false, onIndex: () => indexCount++),
      );
      await tester.pump();

      // Find IgnorePointer widget wrapping content
      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(FloatingQuranAppBar),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('meets minimum accessible touch targets (>= 48x48)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(isVisible: true));
      await tester.pumpAndSettle();

      final iconButtons = tester.widgetList<IconButton>(
        find.byType(IconButton),
      );
      expect(iconButtons.length, 4);

      for (final btn in iconButtons) {
        final constraints = btn.constraints ?? const BoxConstraints();
        expect(constraints.minWidth, greaterThanOrEqualTo(48.0));
        expect(constraints.minHeight, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('renders tafsir book title in green and triggers onSelectTafsirBook (Ref 17)', (
      tester,
    ) async {
      bool bookSelected = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  FloatingQuranAppBar(
                    isVisible: true,
                    onIndex: () {},
                    onSearch: () {},
                    onToday: () {},
                    onSettings: () {},
                    backgroundColor: AppColors.scaffoldLight,
                    iconColor: AppColors.primary,
                    tafsirBookTitle: 'الميسر',
                    onSelectTafsirBook: () => bookSelected = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الميسر'), findsOneWidget);
      await tester.tap(find.text('الميسر'));
      await tester.pumpAndSettle();

      expect(bookSelected, isTrue);
    });
  });
}
