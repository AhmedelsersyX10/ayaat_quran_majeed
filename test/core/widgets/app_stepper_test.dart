import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_stepper.dart';
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
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  group('AppStepper Widget Tests', () {
    testWidgets('renders current value in Arabic numerals', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppStepper(
            value: 5,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text(toArabicDigits('5')), findsOneWidget);
    });

    testWidgets('increments value on plus button tap', (tester) async {
      int? changedValue;

      await tester.pumpWidget(
        _wrap(
          AppStepper(
            value: 3,
            minValue: 1,
            maxValue: 10,
            onChanged: (v) => changedValue = v,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(changedValue, equals(4));
    });

    testWidgets('decrements value on minus button tap', (tester) async {
      int? changedValue;

      await tester.pumpWidget(
        _wrap(
          AppStepper(
            value: 3,
            minValue: 1,
            maxValue: 10,
            onChanged: (v) => changedValue = v,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(changedValue, equals(2));
    });

    testWidgets('respects minValue and does not decrement beyond it',
        (tester) async {
      int? changedValue;

      await tester.pumpWidget(
        _wrap(
          AppStepper(
            value: 1,
            minValue: 1,
            maxValue: 10,
            onChanged: (v) => changedValue = v,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(changedValue, isNull);
    });
  });
}
