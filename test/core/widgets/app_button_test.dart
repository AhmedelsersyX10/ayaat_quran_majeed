import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
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
  group('AppButton Widget Tests', () {
    testWidgets('renders text and fires onPressed callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppButton.primary(
            text: 'بدء الختمة',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('بدء الختمة'), findsOneWidget);

      await tester.tap(find.text('بدء الختمة'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('shows loading spinner and disables tap when isLoading is true',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppButton.primary(
            text: 'بدء الختمة',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('بدء الختمة'), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isFalse);
    });

    testWidgets('does not fire onPressed when isEnabled is false',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppButton.primary(
            text: 'زر معطل',
            isEnabled: false,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('زر معطل'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('renders secondary and destructive variants correctly',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              AppButton.secondary(
                text: 'عرض جميع الأوراد',
                onPressed: () {},
              ),
              AppButton.destructive(
                text: 'حذف الختمة',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.text('عرض جميع الأوراد'), findsOneWidget);
      expect(find.text('حذف الختمة'), findsOneWidget);
    });
  });
}
