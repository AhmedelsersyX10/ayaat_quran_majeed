import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_program_picker_sheet.dart';
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
  group('KhatmaProgramPickerSheet Widget Tests (References 09, 14, 32)', () {
    late _FakeKhatmaRepository repository;
    late KhatmaCubit cubit;

    setUp(() {
      repository = _FakeKhatmaRepository();
      cubit = KhatmaCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    Future<void> pumpPickerSheet(
      WidgetTester tester, {
      required KhatmaProgramCategory category,
      VoidCallback? onBack,
      ValueChanged<KhatmaProgram>? onProgramSelected,
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
              child: Scaffold(
                body: BlocProvider<KhatmaCubit>.value(
                  value: cubit,
                  child: KhatmaProgramPickerSheet(
                    category: category,
                    onBack: onBack,
                    onProgramSelected: onProgramSelected,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders top bar with back arrow and title "برنامج الختمة"',
        (tester) async {
      await pumpPickerSheet(
        tester,
        category: KhatmaProgramCategory.meaning,
      );

      expect(find.text(AppStrings.tr(AppStrings.programPicker)), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets(
        'renders meaning programs matching Reference 09 (60, 29, 7 days)',
        (tester) async {
      await pumpPickerSheet(
        tester,
        category: KhatmaProgramCategory.meaning,
      );

      // 60 days
      expect(find.text('ختمة شهرين (٦٠ يومًا)'), findsOneWidget);
      expect(find.text('الورد اليومي: ١٠ صفحات تقريبًا'), findsOneWidget);

      // 29 days
      expect(find.text('ختمة شهر (٢٩ يومًا)'), findsOneWidget);
      expect(find.text('الورد اليومي: ٢١ صفحة تقريبًا'), findsOneWidget);

      // 7 days
      expect(find.text('ختمة أسبوع (٧ أيام)'), findsOneWidget);
      expect(find.text('الورد اليومي: ٥ أجزاء تقريبًا'), findsOneWidget);
    });

    testWidgets(
        'renders parts and quarters programs matching Reference 14 and 32',
        (tester) async {
      await pumpPickerSheet(
        tester,
        category: KhatmaProgramCategory.partsAndQuarters,
      );

      // Section 1: الأشهر
      expect(find.text(AppStrings.tr(AppStrings.monthsCategory)), findsOneWidget);
      // Section 2: أخرى
      expect(find.text(AppStrings.tr(AppStrings.otherCategory)), findsOneWidget);

      // Verify top 240-day item in أخرى
      expect(find.text('ختمة ٢٤٠ يوما'), findsOneWidget);
      expect(find.text('الورد اليومي: ربع'), findsOneWidget);

      // Verify 120-day item
      expect(find.text('ختمة ١٢٠ يوما'), findsOneWidget);
      expect(find.text('الورد اليومي: ربعان'), findsOneWidget);

      // Verify 80-day item
      expect(find.text('ختمة ٨٠ يوما'), findsOneWidget);
      expect(find.text('الورد اليومي: ٣ أرباع'), findsOneWidget);

      // Verify 60-day item
      expect(find.text('ختمة ٦٠ يوما'), findsOneWidget);
      expect(find.text('الورد اليومي: حزب'), findsOneWidget);

      // Verify 40-day item
      expect(find.text('ختمة ٤٠ يوما'), findsOneWidget);
      expect(find.text('الورد اليومي: حزب ونصف'), findsOneWidget);

      // 30 days appears twice (once in "الأشهر" and once in "أخرى")
      expect(find.text('ختمة ٣٠ يوما'), findsNWidgets(2));
      expect(find.text('الورد اليومي: جزء'), findsNWidgets(2));

      // Scroll to view remaining items
      final item3Days = find.text('ختمة ٣ أيام');
      await tester.scrollUntilVisible(
        item3Days,
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('ختمة ٢٠ يوما'), findsOneWidget);
      expect(find.text('ختمة ١٥ يوما'), findsOneWidget);
      expect(find.text('ختمة ١٠ أيام'), findsOneWidget);
      expect(find.text('ختمة ٦ أيام'), findsOneWidget);
      expect(find.text('ختمة ٣ أيام'), findsOneWidget);
      expect(find.text('الورد اليومي: ١٠ أجزاء'), findsOneWidget);
    });

    testWidgets('tapping a program triggers selection callback',
        (tester) async {
      KhatmaProgram? selected;
      await pumpPickerSheet(
        tester,
        category: KhatmaProgramCategory.meaning,
        onProgramSelected: (prog) => selected = prog,
      );

      final item29 = find.text('ختمة شهر (٢٩ يومًا)');
      await tester.tap(item29);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected?.id, equals('meaning_29'));
      expect(selected?.totalDays, equals(29));
    });

    testWidgets('tapping back arrow calls onBack callback', (tester) async {
      bool backCalled = false;
      await pumpPickerSheet(
        tester,
        category: KhatmaProgramCategory.meaning,
        onBack: () => backCalled = true,
      );

      final backButton = find.byIcon(Icons.arrow_forward_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets(
        'interactive flow: NewKhatmaMenuSheet transitions to picker and back',
        (tester) async {
      cubit.startCreation();

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

      // Step 1: Initial Menu
      expect(find.text(AppStrings.tr(AppStrings.newKhatma)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.khatmaMeaningDivision)),
          findsOneWidget);

      // Step 2: Tap meaning division -> transitions to program picker (Ref 09)
      final meaningOption =
          find.text(AppStrings.tr(AppStrings.khatmaMeaningDivision));
      await tester.ensureVisible(meaningOption);
      await tester.tap(meaningOption);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tr(AppStrings.programPicker)), findsOneWidget);
      expect(find.text('ختمة شهرين (٦٠ يومًا)'), findsOneWidget);
      expect(find.text('ختمة أسبوع (٧ أيام)'), findsOneWidget);

      // Step 3: Tap back button in picker -> transitions back to Menu (Ref 06)
      final backButton = find.byIcon(Icons.arrow_forward_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tr(AppStrings.newKhatma)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.khatmaMeaningDivision)),
          findsOneWidget);

      // Step 4: Tap parts division -> transitions to full picker (Ref 14 & 32)
      final partsOption =
          find.text(AppStrings.tr(AppStrings.khatmaPartsAndQuartersDivision));
      await tester.ensureVisible(partsOption);
      await tester.tap(partsOption);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tr(AppStrings.programPicker)), findsOneWidget);
      expect(find.text('ختمة ٢٤٠ يوما'), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.monthsCategory)), findsOneWidget);

      // Step 5: Select a program in the picker
      final prog240 = find.text('ختمة ٢٤٠ يوما');
      await tester.tap(prog240);
      await tester.pumpAndSettle();

      final state = cubit.state as KhatmaCreating;
      expect(state.selectedProgram?.totalDays, equals(240));
      expect(state.step, equals(KhatmaCreationStep.startFrom));
    });
  });
}

