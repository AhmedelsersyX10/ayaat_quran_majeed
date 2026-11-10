import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhatmaEmptyView Widget Tests (Reference 10)', () {
    Widget createTestWidget({required VoidCallback onStartKhatma}) {
      return ScreenUtilInit(
        designSize: const Size(392, 844),
        builder: (_, __) => MaterialApp(
          locale: const Locale('ar'),
          theme: AppTheme.lightTheme,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: KhatmaEmptyView(onStartKhatma: onStartKhatma),
          ),
        ),
      );
    }

    testWidgets('renders title "الختمة" and centered guidance description',
        (tester) async {
      await tester.pumpWidget(createTestWidget(onStartKhatma: () {}));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tr(AppStrings.khatmaTitle)), findsOneWidget);
      expect(
        find.text(AppStrings.tr(AppStrings.khatmaGuidanceDesc)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.tr(AppStrings.startKhatmaBtn)),
        findsOneWidget,
      );
    });

    testWidgets('tapping "بدء ختمة جديدة" triggers onStartKhatma callback',
        (tester) async {
      var triggered = false;
      await tester.pumpWidget(createTestWidget(onStartKhatma: () {
        triggered = true;
      }));
      await tester.pumpAndSettle();

      final button = find.text(AppStrings.tr(AppStrings.startKhatmaBtn));
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(triggered, isTrue);
    });
  });
}
