import 'package:ayaat_quran_majeed/core/routing/app_router.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRoutes Constants Tests', () {
    test('Route path and name definitions are standard', () {
      expect(AppRoutes.splash, equals('/'));
      expect(AppRoutes.splashName, equals('splash'));
      expect(AppRoutes.reader, equals('/reader'));
      expect(AppRoutes.readerName, equals('reader'));
    });
  });

  group('AppRouter Configuration Tests', () {
    test('createRouter builds valid GoRouter instance with defined routes', () {
      final router = AppRouter.createRouter();
      expect(router, isA<GoRouter>());
      expect(router.configuration.routes.length, greaterThanOrEqualTo(2));

      final routePaths = router.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toList();

      expect(routePaths, contains(AppRoutes.splash));
      expect(routePaths, contains(AppRoutes.reader));
    });

    testWidgets('errorBuilder renders error message for unknown routes',
        (tester) async {
      final testRouter =
          AppRouter.createRouter(initialLocation: '/unknown-route-test');

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('الصفحة غير موجودة'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
    });
  });
}

