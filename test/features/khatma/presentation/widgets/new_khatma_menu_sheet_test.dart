import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/new_khatma_menu_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKhatmaRepository implements KhatmaRepository {
  Khatma? activeKhatma;

  @override
  Future<Khatma?> getActiveKhatma() async => activeKhatma;

  @override
  Future<Khatma> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  }) async {
    throw const KhatmaException('Should not be called during menu navigation');
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
  group('NewKhatmaMenuSheet Widget Tests (Reference 06)', () {
    late _FakeKhatmaRepository repository;
    late KhatmaCubit cubit;

    setUp(() {
      repository = _FakeKhatmaRepository();
      cubit = KhatmaCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    Future<void> pumpMenuSheet(WidgetTester tester) async {
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
              child: Scaffold(
                body: BlocProvider<KhatmaCubit>.value(
                  value: cubit,
                  child: const NewKhatmaMenuSheet(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders top bar with back arrow and title "ختمة جديدة"',
        (tester) async {
      await pumpMenuSheet(tester);

      expect(find.text(AppStrings.tr(AppStrings.newKhatma)), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders "ختمة مقترحة" section and suggested 29-day program card',
        (tester) async {
      await pumpMenuSheet(tester);

      expect(
        find.text(AppStrings.tr(AppStrings.suggestedKhatmaHeader)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.tr(AppStrings.suggestedKhatmaDesc)),
        findsOneWidget,
      );
      expect(find.text(KhatmaProgram.defaultProgram.title), findsOneWidget);
      expect(find.text(KhatmaProgram.defaultProgram.subtitle), findsOneWidget);
    });

    testWidgets('renders "أخرى" section with meaning and parts divisions',
        (tester) async {
      await pumpMenuSheet(tester);

      expect(
        find.text(AppStrings.tr(AppStrings.otherCategory)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.tr(AppStrings.khatmaMeaningDivision)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.tr(AppStrings.khatmaPartsAndQuartersDivision)),
        findsOneWidget,
      );
    });

    testWidgets('tapping suggested card updates cubit state without persisting',
        (tester) async {
      cubit.startCreation();
      await pumpMenuSheet(tester);

      final suggestedCard = find.text(KhatmaProgram.defaultProgram.title);
      await tester.tap(suggestedCard);
      await tester.pumpAndSettle();

      expect(cubit.state, isA<KhatmaCreating>());
      final state = cubit.state as KhatmaCreating;
      expect(state.selectedProgram, equals(KhatmaProgram.defaultProgram));
      expect(state.step, equals(KhatmaCreationStep.startFrom));
      expect(repository.activeKhatma, isNull, reason: 'Must not persist yet');
    });

    testWidgets(
        'tapping "ختمة مقسمة بالمعنى" updates cubit category without persisting',
        (tester) async {
      cubit.startCreation();
      await pumpMenuSheet(tester);

      final meaningOption =
          find.text(AppStrings.tr(AppStrings.khatmaMeaningDivision));
      await tester.ensureVisible(meaningOption);
      await tester.tap(meaningOption);
      await tester.pumpAndSettle();

      expect(cubit.state, isA<KhatmaCreating>());
      final state = cubit.state as KhatmaCreating;
      expect(state.customProgramCategory, equals(KhatmaProgramCategory.meaning));
      expect(state.step, equals(KhatmaCreationStep.programPicker));
      expect(repository.activeKhatma, isNull, reason: 'Must not persist yet');
    });

    testWidgets(
        'tapping "ختمة مقسمة بالأجزاء والأرباع" updates cubit category without persisting',
        (tester) async {
      cubit.startCreation();
      await pumpMenuSheet(tester);

      final partsOption =
          find.text(AppStrings.tr(AppStrings.khatmaPartsAndQuartersDivision));
      await tester.ensureVisible(partsOption);
      await tester.tap(partsOption);
      await tester.pumpAndSettle();

      expect(cubit.state, isA<KhatmaCreating>());
      final state = cubit.state as KhatmaCreating;
      expect(state.customProgramCategory,
          equals(KhatmaProgramCategory.partsAndQuarters));
      expect(state.step, equals(KhatmaCreationStep.programPicker));
      expect(repository.activeKhatma, isNull, reason: 'Must not persist yet');
    });

    testWidgets('tapping back arrow calls cubit.cancelCreation()',
        (tester) async {
      cubit.startCreation();
      await pumpMenuSheet(tester);

      final backButton = find.byIcon(Icons.arrow_forward_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(cubit.state, equals(const KhatmaEmpty()));
      expect(repository.activeKhatma, isNull);
    });
  });
}
