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

      // 5 Shell tabs
      expect(AppRoutes.surahs, equals('/surahs'));
      expect(AppRoutes.surahsName, equals('surahs'));
      expect(AppRoutes.khatma, equals('/khatma'));
      expect(AppRoutes.khatmaName, equals('khatma'));
      expect(AppRoutes.bookmarks, equals('/bookmarks'));
      expect(AppRoutes.bookmarksName, equals('bookmarks'));
      expect(AppRoutes.starred, equals('/starred'));
      expect(AppRoutes.starredName, equals('starred'));
      expect(AppRoutes.notes, equals('/notes'));
      expect(AppRoutes.notesName, equals('notes'));
    });
  });

  group('AppRouter Configuration Tests', () {
    test(
      'createRouter builds valid GoRouter instance with defined routes and shell',
      () {
        final router = AppRouter.createRouter();
        expect(router, isA<GoRouter>());

        // Top-level routes
        final topRoutes = router.configuration.routes;
        final goRoutes = topRoutes.whereType<GoRoute>().toList();
        final shellRoutes = topRoutes.whereType<StatefulShellRoute>().toList();

        expect(goRoutes.map((r) => r.path), contains(AppRoutes.splash));
        expect(goRoutes.map((r) => r.path), contains(AppRoutes.reader));

        // StatefulShellRoute with 5 branches
        expect(shellRoutes, hasLength(1));
        final shell = shellRoutes.first;
        expect(shell.branches, hasLength(5));

        final branchPaths = shell.branches
            .expand((b) => b.routes.whereType<GoRoute>())
            .map((r) => r.path)
            .toList();

        expect(
          branchPaths,
          equals([
            AppRoutes.surahs,
            AppRoutes.khatma,
            AppRoutes.bookmarks,
            AppRoutes.starred,
            AppRoutes.notes,
          ]),
        );
      },
    );

    test('All 5 branches have distinct navigator keys', () {
      final router = AppRouter.createRouter();
      final shell = router.configuration.routes
          .whereType<StatefulShellRoute>()
          .first;

      final navigatorKeys = shell.branches.map((b) => b.navigatorKey).toList();
      final uniqueKeys = navigatorKeys.toSet();

      expect(uniqueKeys.length, equals(5));
      expect(uniqueKeys, contains(AppRouter.surahsNavigatorKey));
      expect(uniqueKeys, contains(AppRouter.khatmaNavigatorKey));
      expect(uniqueKeys, contains(AppRouter.bookmarksNavigatorKey));
      expect(uniqueKeys, contains(AppRouter.starredNavigatorKey));
      expect(uniqueKeys, contains(AppRouter.notesNavigatorKey));
    });

    testWidgets('errorBuilder renders error message for unknown routes', (
      tester,
    ) async {
      final testRouter = AppRouter.createRouter(
        initialLocation: '/unknown-route-test',
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
      await tester.pumpAndSettle();

      expect(find.textContaining('الصفحة غير موجودة'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
    });
  });
}
