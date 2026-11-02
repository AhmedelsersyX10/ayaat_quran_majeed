import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_list_tile.dart';
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
  group('AppListTile Widget Tests', () {
    testWidgets('renders title, subtitle, leading, and trailing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppListTile(
            leading: const Icon(Icons.star),
            title: const Text('سورة الفاتحة'),
            subtitle: const Text('مكية - ٧ آيات'),
            trailing: const Text('ص ١'),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('سورة الفاتحة'), findsOneWidget);
      expect(find.text('مكية - ٧ آيات'), findsOneWidget);
      expect(find.text('ص ١'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('fires onTap callback when row is clicked', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppListTile(
            title: const Text('سورة البقرة'),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('سورة البقرة'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
