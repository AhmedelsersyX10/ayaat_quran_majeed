import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_segmented_tabs.dart';
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
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('AppSegmentedTabs Widget Tests', () {
    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSegmentedTabs(
            tabs: const ['السور', 'الأرباع', 'الأجزاء'],
            selectedIndex: 0,
            onTabChanged: (_) {},
          ),
        ),
      );

      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأرباع'), findsOneWidget);
      expect(find.text('الأجزاء'), findsOneWidget);
    });

    testWidgets('fires onTabChanged when a tab is tapped', (tester) async {
      int? selected;

      await tester.pumpWidget(
        _wrap(
          AppSegmentedTabs(
            tabs: const ['السور', 'الأرباع', 'الأجزاء'],
            selectedIndex: 0,
            onTabChanged: (index) => selected = index,
          ),
        ),
      );

      await tester.tap(find.text('الأرباع'));
      await tester.pumpAndSettle();

      expect(selected, equals(1));

      await tester.tap(find.text('الأجزاء'));
      await tester.pumpAndSettle();

      expect(selected, equals(2));
    });

    testWidgets('renders outlined variant with custom width and border styling', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSegmentedTabs(
            width: 200,
            variant: AppSegmentedTabVariant.outlined,
            tabs: const ['السور', 'الأرباع'],
            selectedIndex: 1,
            onTabChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأرباع'), findsOneWidget);
      expect(find.byType(AppSegmentedTabs), findsOneWidget);
    });
  });
}

