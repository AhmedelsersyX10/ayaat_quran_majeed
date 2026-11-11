import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_active_view.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_time_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockKhatmaRepo implements KhatmaRepository {
  bool completeCurrentCalled = false;
  bool deleteKhatmaCalled = false;
  bool? toggleReminderValue;

  @override
  Future<Khatma?> getActiveKhatma() async => null;

  @override
  Future<Khatma> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  }) async => throw UnimplementedError();

  @override
  Future<Khatma> completeCurrentWird({DateTime? completionDate}) async {
    completeCurrentCalled = true;
    return _buildMockKhatma();
  }

  @override
  Future<Khatma> completeWird(
    int wirdNumber, {
    DateTime? completionDate,
  }) async {
    return _buildMockKhatma();
  }

  @override
  Future<void> deleteKhatma() async {
    deleteKhatmaCalled = true;
  }

  @override
  Future<Khatma> uncompleteWird(int wirdNumber) async =>
      throw UnimplementedError();

  @override
  Future<Khatma> updateReminder({bool? enabled, int? hour, int? minute}) async {
    toggleReminderValue = enabled;
    return _buildMockKhatma();
  }

  static Khatma _buildMockKhatma() {
    final now = DateTime(2026, 11, 10);
    const calculator = KhatmaWirdCalculator();
    final wirds = calculator.calculateWirds(
      program: KhatmaProgram.defaultProgram,
      startDate: now,
      startWirdNumber: 1,
    );
    return Khatma(
      id: 'mock_khatma',
      programId: KhatmaProgram.defaultProgram.id,
      programTitle: KhatmaProgram.defaultProgram.title,
      totalDays: 29,
      startDate: now,
      wirds: wirds,
      completedWirdsCount: 1,
      createdAt: now,
    );
  }
}

void main() {
  group('KhatmaActiveView Tests (References 26 & 31)', () {
    late _MockKhatmaRepo mockRepo;
    late KhatmaCubit cubit;
    late Khatma testKhatmaDay1;
    late Khatma testKhatmaDay3;

    setUp(() {
      mockRepo = _MockKhatmaRepo();
      cubit = KhatmaCubit(repository: mockRepo);

      final now = DateTime(2026, 11, 10);
      const calculator = KhatmaWirdCalculator();
      final wirds = calculator.calculateWirds(
        program: KhatmaProgram.defaultProgram,
        startDate: now,
        startWirdNumber: 1,
      );

      testKhatmaDay1 = Khatma(
        id: 'khatma_day_1',
        programId: KhatmaProgram.defaultProgram.id,
        programTitle: KhatmaProgram.defaultProgram.title,
        totalDays: 29,
        startDate: now,
        wirds: wirds,
        reminderEnabled: false,
        reminderTimeHour: 19,
        reminderTimeMinute: 0,
        completedWirdsCount: 0,
        createdAt: now,
      );

      // Day 3 active (Day 1 and 2 completed)
      final wirdsDay3 = wirds.map((w) {
        if (w.dayNumber < 3) return w.copyWith(isCompleted: true);
        return w;
      }).toList();

      testKhatmaDay3 = Khatma(
        id: 'khatma_day_3',
        programId: KhatmaProgram.defaultProgram.id,
        programTitle: KhatmaProgram.defaultProgram.title,
        totalDays: 29,
        startDate: now,
        wirds: wirdsDay3,
        reminderEnabled: true,
        reminderTimeHour: 19,
        reminderTimeMinute: 0,
        completedWirdsCount: 2,
        createdAt: now,
      );
    });

    tearDown(() {
      cubit.close();
    });

    Future<void> pumpActiveView(
      WidgetTester tester, {
      required KhatmaLoaded loadedState,
    }) async {
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
                child: KhatmaActiveView(loadedState: loadedState),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders Day 1 elements faithfully to Screenshot 31', (
      tester,
    ) async {
      final now = DateTime(2026, 11, 10);
      final loadedState = KhatmaLoaded(
        khatma: testKhatmaDay1,
        currentWird: testKhatmaDay1.wirds[0],
        relativeDayLabel: testKhatmaDay1.wirds[0].relativeDayLabel(now),
      );

      await pumpActiveView(tester, loadedState: loadedState);

      // Title
      expect(find.text(AppStrings.tr(AppStrings.khatmaTitle)), findsOneWidget);

      // Sub-header: Day 1 and "اليوم"
      expect(find.text('ورد اليوم ١'), findsOneWidget);
      expect(find.text('اليوم'), findsOneWidget);

      // Card verse boundaries
      expect(find.text('من الفاتحة: ١'), findsOneWidget);
      expect(find.text('١'), findsOneWidget); // page 1
      expect(find.text('إلى البقرة: ١٤١'), findsOneWidget);
      expect(find.text('٢١'), findsOneWidget); // page 21

      // CTA button
      expect(
        find.text(AppStrings.tr(AppStrings.completedWird)),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Reminder section
      expect(find.text(AppStrings.tr(AppStrings.reminder)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.dailyWird)), findsOneWidget);
      expect(find.text(testKhatmaDay1.formattedReminderTime), findsOneWidget);
      final switchWidget = tester.widget<AppSwitch>(find.byType(AppSwitch));
      expect(switchWidget.value, isFalse);

      // All wirds and delete cards
      expect(find.text(AppStrings.tr(AppStrings.allWirds)), findsOneWidget);
      expect(find.text('٢٩'), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.deleteKhatma)), findsOneWidget);
    });

    testWidgets('renders Day 3 elements faithfully to Screenshot 26', (
      tester,
    ) async {
      final now = DateTime(2026, 11, 10);
      final loadedState = KhatmaLoaded(
        khatma: testKhatmaDay3,
        currentWird: testKhatmaDay3.wirds[2],
        relativeDayLabel: testKhatmaDay3.wirds[2].relativeDayLabel(now),
      );

      await pumpActiveView(tester, loadedState: loadedState);

      // Sub-header: Day 3 and "بعد يومين"
      expect(find.text('ورد اليوم ٣'), findsOneWidget);
      expect(find.text('بعد يومين'), findsOneWidget);

      // Card verse boundaries
      expect(find.text('من البقرة: ٢٥٣'), findsOneWidget);
      expect(find.text('٤٢'), findsOneWidget); // page 42
      expect(find.text('إلى آل عمران: ٩٢'), findsOneWidget);
      expect(find.text('٦٢'), findsOneWidget); // page 62

      // Reminder switch ON
      final switchWidget = tester.widget<AppSwitch>(find.byType(AppSwitch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets(
      'tapping "أكملت هذا الورد" triggers cubit.completeCurrentWird',
      (tester) async {
        final now = DateTime(2026, 11, 10);
        final loadedState = KhatmaLoaded(
          khatma: testKhatmaDay1,
          currentWird: testKhatmaDay1.wirds[0],
          relativeDayLabel: 'اليوم',
        );

        await pumpActiveView(tester, loadedState: loadedState);

        final ctaFinder = find.text(AppStrings.tr(AppStrings.completedWird));
        await tester.tap(ctaFinder);
        await tester.pumpAndSettle();

        expect(mockRepo.completeCurrentCalled, isTrue);
      },
    );

    testWidgets('toggling reminder switch triggers cubit.toggleReminder', (
      tester,
    ) async {
      final loadedState = KhatmaLoaded(
        khatma: testKhatmaDay1,
        currentWird: testKhatmaDay1.wirds[0],
        relativeDayLabel: 'اليوم',
      );

      await pumpActiveView(tester, loadedState: loadedState);

      await tester.tap(find.byType(AppSwitch));
      await tester.pumpAndSettle();

      expect(mockRepo.toggleReminderValue, isTrue);
    });

    testWidgets(
      'tapping "حذف الختمة" presents confirmation dialog and executes delete',
      (tester) async {
        final loadedState = KhatmaLoaded(
          khatma: testKhatmaDay1,
          currentWird: testKhatmaDay1.wirds[0],
          relativeDayLabel: 'اليوم',
        );

        await pumpActiveView(tester, loadedState: loadedState);

        // Tap delete card
        await tester.tap(find.text(AppStrings.tr(AppStrings.deleteKhatma)));
        await tester.pumpAndSettle();

        // Dialog is visible with confirmation message
        expect(
          find.text(AppStrings.tr(AppStrings.deleteKhatmaConfirm)),
          findsOneWidget,
        );

        // Tap Confirm Delete
        final deleteConfirmBtn = find.descendant(
          of: find.byType(TextButton),
          matching: find.text(AppStrings.tr(AppStrings.delete)),
        );
        await tester.tap(deleteConfirmBtn);
        await tester.pumpAndSettle();

        expect(mockRepo.deleteKhatmaCalled, isTrue);
      },
    );

    testWidgets('displays completion message when all wirds are completed', (
      tester,
    ) async {
      final completedWirds = testKhatmaDay1.wirds
          .map((w) => w.copyWith(isCompleted: true))
          .toList();
      final allCompletedKhatma = testKhatmaDay1.copyWith(
        wirds: completedWirds,
        completedWirdsCount: 29,
        isCompleted: true,
      );

      final loadedState = KhatmaLoaded(
        khatma: allCompletedKhatma,
        currentWird: completedWirds.last,
        relativeDayLabel: 'مكتملة',
      );

      await pumpActiveView(tester, loadedState: loadedState);

      expect(
        find.text(AppStrings.tr(AppStrings.khatmaCompleted)),
        findsOneWidget,
      );
    });

    testWidgets('completion button is disabled when isCompleted is true', (
      tester,
    ) async {
      final completedWirds = testKhatmaDay1.wirds
          .map((w) => w.copyWith(isCompleted: true))
          .toList();
      final allCompletedKhatma = testKhatmaDay1.copyWith(
        wirds: completedWirds,
        completedWirdsCount: 29,
        isCompleted: true,
      );

      final loadedState = KhatmaLoaded(
        khatma: allCompletedKhatma,
        currentWird: completedWirds.last,
        relativeDayLabel: 'مكتملة',
      );

      await pumpActiveView(tester, loadedState: loadedState);

      final inkWellFinder = find.ancestor(
        of: find.text(AppStrings.tr(AppStrings.khatmaCompleted)),
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsOneWidget);
      final inkWell = tester.widget<InkWell>(inkWellFinder);
      expect(inkWell.onTap, isNull);

      await tester.tap(inkWellFinder);
      await tester.pumpAndSettle();
      expect(mockRepo.completeCurrentCalled, isFalse);
    });

    testWidgets(
      'confetti triggers on wird completion and resetCompletionFeedback is invoked',
      (tester) async {
        final initialLoadedState = KhatmaLoaded(
          khatma: testKhatmaDay1,
          currentWird: testKhatmaDay1.wirds[0],
          relativeDayLabel: 'اليوم',
        );

        await pumpActiveView(tester, loadedState: initialLoadedState);

        cubit.emit(
          KhatmaLoaded(
            khatma: testKhatmaDay1,
            currentWird: testKhatmaDay1.wirds[0],
            relativeDayLabel: 'اليوم',
            justCompletedWird: true,
          ),
        );
        await tester.pumpAndSettle();

        final currentState = cubit.state as KhatmaLoaded;
        expect(currentState.justCompletedWird, isFalse);
      },
    );

    testWidgets(
      'tapping reminder card opens KhatmaTimePickerDialog (Reference 23)',
      (tester) async {
        final loadedState = KhatmaLoaded(
          khatma: testKhatmaDay1,
          currentWird: testKhatmaDay1.wirds[0],
          relativeDayLabel: 'اليوم',
        );

        await pumpActiveView(tester, loadedState: loadedState);

        await tester.tap(find.text(AppStrings.tr(AppStrings.dailyWird)));
        await tester.pumpAndSettle();

        expect(find.byType(KhatmaTimePickerDialog), findsOneWidget);
      },
    );

    testWidgets('shows SnackBar when permissionDeniedNotice is emitted', (
      tester,
    ) async {
      final initialLoadedState = KhatmaLoaded(
        khatma: testKhatmaDay1,
        currentWird: testKhatmaDay1.wirds[0],
        relativeDayLabel: 'اليوم',
      );

      await pumpActiveView(tester, loadedState: initialLoadedState);

      cubit.emit(
        KhatmaLoaded(
          khatma: testKhatmaDay1,
          currentWird: testKhatmaDay1.wirds[0],
          relativeDayLabel: 'اليوم',
          permissionDeniedNotice: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(AppStrings.tr(AppStrings.notificationPermissionRequired)),
        findsOneWidget,
      );
    });
  });
}
