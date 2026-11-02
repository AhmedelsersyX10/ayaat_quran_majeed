import 'package:ayaat_quran_majeed/core/routing/app_router.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_nav.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/views/bookmarks_tab_view.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/views/surahs_tab_view.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/views/khatma_tab_view.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/views/notes_tab_view.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/views/starred_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp({required String initialLocation}) {
  final router = AppRouter.createRouter(initialLocation: initialLocation);
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) =>
        MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppShell & 5 Tabs Routing Tests', () {
    testWidgets(
      'Initial navigation to /surahs displays SurahsTabView and AppBottomNav with index 0',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(initialLocation: AppRoutes.surahs),
        );
        await tester.pumpAndSettle();

        // AppBottomNav is rendered with all 5 tabs
        expect(find.byType(AppBottomNav), findsOneWidget);
        expect(find.text('السور'), findsWidgets);
        expect(find.text('الختمة'), findsOneWidget);
        expect(find.text('الفواصل'), findsOneWidget);
        expect(find.text('مميزة بنجمة'), findsOneWidget);
        expect(find.text('الملاحظات'), findsOneWidget);

        // Tab 0 view is active
        expect(find.byType(SurahsTabView), findsOneWidget);
        expect(find.text('الفهرس'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation to /khatma displays KhatmaTabView matching screen 10',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(initialLocation: AppRoutes.khatma),
        );
        await tester.pumpAndSettle();

        expect(find.byType(KhatmaTabView), findsOneWidget);
        expect(find.text('الختمة'), findsWidgets);
        expect(find.text('بدء ختمة جديدة'), findsOneWidget);
        expect(
          find.text(
            'حدّد وردك اليومي أو المدة التي تريد ختم القرآن فيها، وتابع ختمتك في شهر رمضان وطوال العام.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Navigation to /bookmarks displays BookmarksTabView matching screen 11',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(initialLocation: AppRoutes.bookmarks),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BookmarksTabView), findsOneWidget);
        expect(find.text('الفواصل'), findsWidgets);
        expect(find.text('تحرير'), findsOneWidget);
        expect(find.text('الأحمر'), findsOneWidget);
        expect(find.text('الأصفر'), findsOneWidget);
        expect(find.text('الأخضر'), findsOneWidget);
        expect(find.text('الأزرق'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation to /starred displays StarredTabView matching screen 12',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(initialLocation: AppRoutes.starred),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StarredTabView), findsOneWidget);
        expect(find.text('مميزة بنجمة'), findsWidgets);
        expect(find.text('لا توجد آيات مميزة بنجمة'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation to /notes displays NotesTabView matching screen 13',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(initialLocation: AppRoutes.notes),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NotesTabView), findsOneWidget);
        expect(find.text('الملاحظات'), findsWidgets);
        expect(find.text('لا توجد ملاحظات'), findsOneWidget);
      },
    );

    testWidgets('Tapping bottom nav tab switches view and preserves tab state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(initialLocation: AppRoutes.surahs));
      await tester.pumpAndSettle();

      expect(find.byType(SurahsTabView), findsOneWidget);

      // In SurahsTabView, switch segmented tab to "الأرباع"
      final quartersSegment = find.text('الأرباع');
      expect(quartersSegment, findsOneWidget);
      await tester.tap(quartersSegment);
      await tester.pumpAndSettle();

      // Now tap on "الختمة" tab in the bottom bar
      final khatmaBottomTab = find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('الختمة'),
      );
      await tester.tap(khatmaBottomTab);
      await tester.pumpAndSettle();

      // KhatmaTabView is now visible
      expect(find.byType(KhatmaTabView), findsOneWidget);
      expect(find.text('بدء ختمة جديدة'), findsOneWidget);

      // Switch back to "السور" in the bottom bar
      final surahsBottomTab = find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('السور'),
      );
      await tester.tap(surahsBottomTab);
      await tester.pumpAndSettle();

      // Verify that SurahsTabView state was preserved (still on "الأرباع" tab)
      expect(find.byType(SurahsTabView), findsOneWidget);
      expect(find.text('الفهرس'), findsOneWidget);
    });
  });
}
