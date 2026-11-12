import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/hijri_adjustment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required int initialOffset,
    required ValueChanged<int> onOffsetSelected,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                HijriAdjustmentDialog.show(
                  context: ctx,
                  initialOffset: initialOffset,
                  onOffsetSelected: onOffsetSelected,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('HijriAdjustmentDialog Widget Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(
        1176,
        2556,
      );
      binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    testWidgets('renders all three adjustment options and title', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialOffset: 0, onOffsetSelected: (_) {}),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('تعديل التاريخ الهجري'), findsOneWidget);
      expect(find.text('تقديم يوم واحد (+١)'), findsOneWidget);
      expect(find.text('تقويم أم القرى (بدون تعديل)'), findsOneWidget);
      expect(find.text('تأخير يوم واحد (-١)'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
    });

    testWidgets('selecting -1 and confirming calls callback with -1', (
      tester,
    ) async {
      int? selectedOffset;

      await tester.pumpWidget(
        buildTestWidget(
          initialOffset: 0,
          onOffsetSelected: (val) => selectedOffset = val,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تأخير يوم واحد (-١)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();

      expect(selectedOffset, -1);
      expect(find.text('تعديل التاريخ الهجري'), findsNothing);
    });

    testWidgets('canceling dialog dismisses without invoking callback', (
      tester,
    ) async {
      int? selectedOffset;

      await tester.pumpWidget(
        buildTestWidget(
          initialOffset: 0,
          onOffsetSelected: (val) => selectedOffset = val,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تقديم يوم واحد (+١)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      expect(selectedOffset, isNull);
      expect(find.text('تعديل التاريخ الهجري'), findsNothing);
    });
  });
}
