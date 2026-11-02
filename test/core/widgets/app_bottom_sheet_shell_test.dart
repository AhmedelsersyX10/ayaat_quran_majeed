import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_sheet_shell.dart';
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
  group('AppBottomSheetShell Widget Tests', () {
    testWidgets('renders title, drag handle, and content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppBottomSheetShell(
            title: 'خيارات التلاوة',
            child: Text('محتوى القائمة السفلية'),
          ),
        ),
      );

      expect(find.text('خيارات التلاوة'), findsOneWidget);
      expect(find.text('محتوى القائمة السفلية'), findsOneWidget);
    });
  });
}

