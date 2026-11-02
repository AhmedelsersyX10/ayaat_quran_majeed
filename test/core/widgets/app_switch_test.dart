import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
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
  group('AppSwitch Widget Tests', () {
    testWidgets('toggles value on tap', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => AppSwitch(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      expect(value, isFalse);

      await tester.tap(find.byType(AppSwitch));
      await tester.pumpAndSettle();

      expect(value, isTrue);

      await tester.tap(find.byType(AppSwitch));
      await tester.pumpAndSettle();

      expect(value, isFalse);
    });

    testWidgets('does not toggle when isEnabled is false', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        _wrap(
          AppSwitch(
            value: value,
            isEnabled: false,
            onChanged: (v) => value = v,
          ),
        ),
      );

      await tester.tap(find.byType(AppSwitch));
      await tester.pumpAndSettle();

      expect(value, isFalse);
    });
  });
}

