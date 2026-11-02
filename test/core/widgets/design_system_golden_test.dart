import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/catalog/design_system_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Design System Visual Layout & RTL Tests', () {
    testWidgets(
        'DesignSystemCatalogPage renders all primitives without overflow',
        (tester) async {
      // Set surface size to standard phone width (392 x 800)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392.7, 800.7),
          builder: (context, _) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DesignSystemCatalogPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that major sections are present
      expect(find.text('معرض نظام التصميم'), findsOneWidget);
      expect(find.text('1. لوحة الألوان الأساسية (Colors)'), findsOneWidget);
      expect(find.text('2. الطباعة والخطوط (Typography)'), findsOneWidget);
      expect(find.text('3. الأزرار (Buttons & Icon Buttons)'), findsOneWidget);
      expect(find.text('زر أساسي (Primary CTA)'), findsOneWidget);
      expect(find.text('السور'), findsWidgets);
      expect(find.text('الختمة'), findsWidgets);
      expect(find.text('الفواصل'), findsWidgets);

      // Verify no assertion or overflow exceptions were thrown
      expect(tester.takeException(), isNull);
    });
  });
}
