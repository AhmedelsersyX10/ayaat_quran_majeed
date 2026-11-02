import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
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
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('AppEmptyState Widget Tests', () {
    testWidgets('renders title, description, and action button',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            icon: const Icon(Icons.hourglass_empty),
            title: 'لا توجد ختمة نشطة',
            description: 'ابدأ ختمة جديدة لمتابعة وردك اليومي',
            buttonText: 'بدء ختمة جديدة',
            onButtonPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('لا توجد ختمة نشطة'), findsOneWidget);
      expect(find.text('ابدأ ختمة جديدة لمتابعة وردك اليومي'), findsOneWidget);
      expect(find.text('بدء ختمة جديدة'), findsOneWidget);

      await tester.tap(find.text('بدء ختمة جديدة'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
