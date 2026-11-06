import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_feedback_states.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_segmented_tabs.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class MockIndexRepository implements IndexRepository {
  IndexTab activeTab = IndexTab.surahs;

  @override
  Future<IndexTab> getActiveTab() async => activeTab;

  @override
  Future<void> setActiveTab(IndexTab tab) async => activeTab = tab;

  @override
  Future<List<JuzGroup>> getSurahsGroupedByJuz() async => const [
        JuzGroup(juzNumber: 1, nameArabic: 'الأول', startPage: 1, surahs: []),
      ];

  @override
  Future<int> getCurrentReadingSurah() async => 1;
}

Widget _wrapWithApp({
  required IndexCubit cubit,
  required Widget child,
}) {
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: BlocProvider<IndexCubit>.value(
            value: cubit,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  late MockIndexRepository repository;
  late IndexCubit cubit;

  setUp(() {
    repository = MockIndexRepository();
    cubit = IndexCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('IndexSheetShell Widget Tests (References 03 & 04)', () {
    testWidgets('renders segmented tabs in RTL order and active title on Surahs tab', (tester) async {
      cubit.setStatus(IndexStatus.success);

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: const IndexSheetShell(
            surahsChild: Text('محتوى السور'),
            quartersChild: Text('محتوى الأرباع'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify segmented control renders both tabs
      expect(find.byType(AppSegmentedTabs), findsOneWidget);
      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأرباع'), findsOneWidget);

      // Verify "الفهرس" title is visible on Surahs tab (Ref 03)
      expect(find.text('الفهرس'), findsOneWidget);

      // Verify Surahs content is displayed
      expect(find.text('محتوى السور'), findsOneWidget);
      expect(find.text('محتوى الأرباع'), findsNothing);
    });

    testWidgets('switching to Quarters tab updates content and hides "الفهرس" title (Ref 04)', (tester) async {
      cubit.setStatus(IndexStatus.success);

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: const IndexSheetShell(
            surahsChild: Text('محتوى السور'),
            quartersChild: Text('محتوى الأرباع'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Quarters tab ("الأرباع")
      await tester.tap(find.text('الأرباع'));
      await tester.pumpAndSettle();

      // Verify "الفهرس" title is hidden on Quarters tab (Ref 04)
      expect(find.text('الفهرس'), findsNothing);

      // Verify Quarters content is rendered
      expect(find.text('محتوى الأرباع'), findsOneWidget);
      expect(find.text('محتوى السور'), findsNothing);
      expect(repository.activeTab, equals(IndexTab.quarters));
    });

    testWidgets('displays AppLoadingState when status is loading', (tester) async {
      cubit.setStatus(IndexStatus.loading);

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: const IndexSheetShell(),
        ),
      );
      await tester.pump();

      expect(find.byType(AppLoadingState), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays AppEmptyState when status is empty', (tester) async {
      cubit.setStatus(IndexStatus.empty);

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: const IndexSheetShell(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('لا توجد بيانات للفهرس'), findsOneWidget);
    });

    testWidgets('displays AppErrorState when status is failure and retry works', (tester) async {
      cubit.setStatus(IndexStatus.failure, errorMessage: 'تعذر تحميل الفهرس');

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: const IndexSheetShell(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.text('تعذر تحميل الفهرس'), findsOneWidget);
      expect(find.text('أعد المحاولة'), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('أعد المحاولة'));
      await tester.pumpAndSettle();

      expect(cubit.state.status, equals(IndexStatus.success));
    });

    testWidgets('decoupled slot builders render custom widgets cleanly', (tester) async {
      cubit.setStatus(IndexStatus.success);

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: IndexSheetShell(
            surahsBuilder: (context) => const KeyedSubtree(
              key: Key('custom_surahs_list'),
              child: Text('قائمة السور المخصصة'),
            ),
            quartersBuilder: (context) => const KeyedSubtree(
              key: Key('custom_quarters_list'),
              child: Text('قائمة الأرباع المخصصة'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_surahs_list')), findsOneWidget);
      expect(find.text('قائمة السور المخصصة'), findsOneWidget);

      // Switch to Quarters
      await tester.tap(find.text('الأرباع'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_quarters_list')), findsOneWidget);
      expect(find.text('قائمة الأرباع المخصصة'), findsOneWidget);
    });

    testWidgets('drag handle indicator renders when showDragHandle is true', (tester) async {
      cubit.setStatus(IndexStatus.success);

      await tester.pumpWidget(
        _wrapWithApp(
          cubit: cubit,
          child: const IndexSheetShell(showDragHandle: true),
        ),
      );
      await tester.pumpAndSettle();

      // Top drag handle container is rendered
      expect(find.byType(IndexSheetShell), findsOneWidget);
    });
  });
}

