import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
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
  group('AppCard Widget Tests', () {
    testWidgets('renders child content in all variants', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              AppCard.standard(child: Text('بطاقة قياسية')),
              AppCard.primary(child: Text('بطاقة خضراء')),
              AppCard.quote(child: Text('بطاقة اقتباس')),
            ],
          ),
        ),
      );

      expect(find.text('بطاقة قياسية'), findsOneWidget);
      expect(find.text('بطاقة خضراء'), findsOneWidget);
      expect(find.text('بطاقة اقتباس'), findsOneWidget);
    });

    testWidgets('fires onTap callback when card is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppCard.standard(
            onTap: () => tapped = true,
            child: const Text('بطاقة قابلة للنقر'),
          ),
        ),
      );

      await tester.tap(find.text('بطاقة قابلة للنقر'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
