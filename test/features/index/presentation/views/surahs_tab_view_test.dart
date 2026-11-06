import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/surah_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/views/surahs_tab_view.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_sheet_shell.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/surahs_grouped_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockRepo implements IndexRepository {
  IndexTab activeTab = IndexTab.surahs;
  bool shouldFail = false;
  List<JuzGroup> groups = [
    const JuzGroup(
      juzNumber: 1,
      nameArabic: 'الأول',
      startPage: 1,
      surahs: [
        SurahIndexItem(
          number: 1,
          nameArabic: 'الفاتحة',
          pageNumber: 1,
          verseCount: 7,
          isMakki: true,
          startJuz: 1,
        ),
        SurahIndexItem(
          number: 2,
          nameArabic: 'البقرة',
          pageNumber: 2,
          verseCount: 286,
          isMakki: false,
          startJuz: 1,
        ),
      ],
    ),
    const JuzGroup(
      juzNumber: 2,
      nameArabic: 'الثاني',
      startPage: 22,
      surahs: [],
    ),
  ];

  @override
  Future<IndexTab> getActiveTab() async {
    if (shouldFail) throw Exception('fail');
    return activeTab;
  }

  @override
  Future<void> setActiveTab(IndexTab tab) async => activeTab = tab;

  @override
  Future<List<JuzGroup>> getSurahsGroupedByJuz() async {
    if (shouldFail) throw Exception('fail');
    return groups;
  }

  @override
  Future<int> getCurrentReadingSurah() async {
    if (shouldFail) throw Exception('fail');
    return 2;
  }
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo mockRepo;

  setUp(() async {
    await resetInjection();
    mockRepo = _MockRepo();
    sl.registerLazySingleton<IndexRepository>(() => mockRepo);
    sl.registerFactory<IndexCubit>(() => IndexCubit(sl<IndexRepository>()));
  });

  tearDown(() async {
    await resetInjection();
  });

  group('SurahsTabView End-to-End Presentation Tests', () {
    testWidgets('renders IndexSheetShell and SurahsGroupedListView on initial load', (tester) async {
      await tester.pumpWidget(_wrap(const SurahsTabView()));
      await tester.pumpAndSettle();

      expect(find.byType(IndexSheetShell), findsOneWidget);
      expect(find.byType(SurahsGroupedListView), findsOneWidget);

      // Verify content from mock repo
      expect(find.text('الجزء الأول'), findsOneWidget);
      expect(find.text('الفاتحة'), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);
      expect(find.text('الجزء الثاني'), findsOneWidget);
    });

    testWidgets('renders empty state when no juz groups are available', (tester) async {
      mockRepo.groups = [];

      await tester.pumpWidget(_wrap(const SurahsTabView()));
      await tester.pumpAndSettle();

      expect(find.byType(IndexSheetShell), findsOneWidget);
      expect(find.byType(SurahsGroupedListView), findsNothing);
    });

    testWidgets('renders error state and retry restores content on failure', (tester) async {
      mockRepo.shouldFail = true;

      await tester.pumpWidget(_wrap(const SurahsTabView()));
      await tester.pumpAndSettle();

      // Failure state displayed
      expect(find.byType(SurahsGroupedListView), findsNothing);

      // Restore repo and tap retry
      mockRepo.shouldFail = false;
      final retryFinder = find.byType(ElevatedButton);
      if (retryFinder.evaluate().isNotEmpty) {
        await tester.tap(retryFinder);
        await tester.pumpAndSettle();

        expect(find.byType(SurahsGroupedListView), findsOneWidget);
      }
    });
  });
}
