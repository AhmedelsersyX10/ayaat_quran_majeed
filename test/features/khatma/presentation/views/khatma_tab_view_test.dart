import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/views/khatma_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockKhatmaRepository implements KhatmaRepository {
  Khatma? activeKhatma;
  bool shouldThrow = false;

  @override
  Future<Khatma?> getActiveKhatma() async {
    if (shouldThrow) throw Exception('Database error');
    return activeKhatma;
  }

  @override
  Future<Khatma> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Khatma> completeCurrentWird({DateTime? completionDate}) async {
    throw UnimplementedError();
  }

  @override
  Future<Khatma> completeWird(int wirdNumber, {DateTime? completionDate}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteKhatma() async {
    activeKhatma = null;
  }

  @override
  Future<Khatma> uncompleteWird(int wirdNumber) async {
    throw UnimplementedError();
  }

  @override
  Future<Khatma> updateReminder({
    bool? enabled,
    int? hour,
    int? minute,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('KhatmaTabView Integration & State Tests (References 06 & 10)', () {
    late _MockKhatmaRepository repository;
    late KhatmaCubit cubit;

    setUp(() {
      repository = _MockKhatmaRepository();
      cubit = KhatmaCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    Future<void> pumpTabView(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1176, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392, 844),
          builder: (_, __) => MaterialApp(
            locale: const Locale('ar'),
            theme: AppTheme.lightTheme,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocProvider<KhatmaCubit>.value(
                value: cubit,
                child: const KhatmaTabView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders KhatmaEmptyView when active khatma is null',
        (tester) async {
      await cubit.loadKhatma();
      await pumpTabView(tester);

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

    testWidgets('tapping "بدء ختمة جديدة" triggers sheet with "ختمة جديدة"',
        (tester) async {
      await cubit.loadKhatma();
      await pumpTabView(tester);

      final startButton = find.text(AppStrings.tr(AppStrings.startKhatmaBtn));
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Sheet is presented
      expect(find.text(AppStrings.tr(AppStrings.newKhatma)), findsOneWidget);
      expect(
        find.text(AppStrings.tr(AppStrings.suggestedKhatmaHeader)),
        findsOneWidget,
      );
      expect(find.text(KhatmaProgram.defaultProgram.title), findsOneWidget);
    });

    testWidgets('renders failure state and retries on button press',
        (tester) async {
      repository.shouldThrow = true;
      await cubit.loadKhatma();

      await pumpTabView(tester);

      expect(find.textContaining('فشل تحميل الختمة'), findsOneWidget);

      repository.shouldThrow = false;
      final retryButton = find.text(AppStrings.tr(AppStrings.returnHome));
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.tr(AppStrings.startKhatmaBtn)),
        findsOneWidget,
      );
    });

    testWidgets('renders active khatma summary when loaded', (tester) async {
      final now = DateTime(2026, 11, 10);
      final testWird = KhatmaWird(
        dayNumber: 1,
        scheduledDate: now,
        startSurahNumber: 1,
        startAyahNumber: 1,
        endSurahNumber: 2,
        endAyahNumber: 141,
        startPageNumber: 1,
        endPageNumber: 21,
        startSurahName: 'الفاتحة',
        endSurahName: 'البقرة',
        firstVerseText: 'بسم الله الرحمن الرحيم',
        lastVerseText: 'تلك أمة قد خلت',
        rangeText: 'الفاتحة ١ - البقرة ١٤١',
      );

      repository.activeKhatma = Khatma(
        id: 'test_khatma',
        programId: 'meaning_29',
        programTitle: 'ختمة شهر (٢٩ يومًا)',
        totalDays: 29,
        startDate: now,
        wirds: [testWird],
        completedWirdsCount: 0,
        createdAt: now,
      );

      await cubit.loadKhatma(currentDate: now);
      await pumpTabView(tester);

      expect(find.textContaining('ختمة شهر (٢٩ يومًا)'), findsOneWidget);
    });
  });
}
