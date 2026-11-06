import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_bottom_sheet.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_sheet_shell.dart';
import 'package:flutter/material.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIndexRepository repository;

  setUp(() async {
    await resetInjection();
    repository = MockIndexRepository();
    sl.registerLazySingleton<IndexRepository>(() => repository);
    sl.registerFactory<IndexCubit>(() => IndexCubit(sl<IndexRepository>()));
  });

  tearDown(() async {
    await resetInjection();
  });

  group('IndexBottomSheet Modal Tests', () {
    testWidgets('IndexBottomSheet.show launches modal sheet containing IndexSheetShell', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392.7, 800.7),
          builder: (context, _) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Builder(
                  builder: (ctx) {
                    capturedContext = ctx;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Launch modal sheet
      IndexBottomSheet.show(
        capturedContext,
        surahsChild: const Text('سور المودال'),
      );
      await tester.pumpAndSettle();

      // Verify modal sheet with IndexSheetShell is on screen
      expect(find.byType(IndexSheetShell), findsOneWidget);
      expect(find.text('سور المودال'), findsOneWidget);
      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأرباع'), findsOneWidget);
    });

    testWidgets('tapping barrier dismisses modal bottom sheet cleanly', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392.7, 800.7),
          builder: (context, _) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Builder(
                  builder: (ctx) {
                    capturedContext = ctx;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      IndexBottomSheet.show(
        capturedContext,
        surahsChild: const Text('محتوى قابل للإغلاق'),
      );
      await tester.pumpAndSettle();
      expect(find.text('محتوى قابل للإغلاق'), findsOneWidget);

      // Tap on the top barrier above sheet to dismiss
      await tester.tapAt(const Offset(100, 20));
      await tester.pumpAndSettle();

      expect(find.text('محتوى قابل للإغلاق'), findsNothing);
      expect(find.byType(IndexSheetShell), findsNothing);
    });
  });
}
