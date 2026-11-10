import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_select_wird_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKhatmaRepository implements KhatmaRepository {
  Khatma? activeKhatma;
  KhatmaProgram? lastCreatedProgram;
  int? lastStartWirdNumber;

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
    lastCreatedProgram = program;
    lastStartWirdNumber = startWirdNumber;
    final dummyWird = KhatmaWird(
      dayNumber: startWirdNumber,
      scheduledDate: startDate,
      startSurahNumber: 1,
      startAyahNumber: 1,
      endSurahNumber: 2,
      endAyahNumber: 141,
      startPageNumber: 1,
      endPageNumber: 21,
      startSurahName: 'الفاتحة',
      endSurahName: 'البقرة',
      firstVerseText: 'بسم الله',
      lastVerseText: 'تلك أمة',
      rangeText: 'من الفاتحة إلى البقرة: ١٤١',
      isCompleted: false,
    );
    final khatma = Khatma(
      id: 'khatma_test',
      programId: program.id,
      programTitle: program.title,
      totalDays: program.totalDays,
      startDate: startDate,
      wirds: [dummyWird],
      createdAt: startDate,
    );
    activeKhatma = khatma;
    return khatma;
  }

  @override
  Future<Khatma> completeCurrentWird({DateTime? completionDate}) =>
      throw UnimplementedError();

  @override
  Future<Khatma> completeWird(int wirdNumber, {DateTime? completionDate}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteKhatma() async {
    activeKhatma = null;
  }

  @override
  Future<Khatma> uncompleteWird(int wirdNumber) => throw UnimplementedError();

  @override
  Future<Khatma> updateReminder({bool? enabled, int? hour, int? minute}) =>
      throw UnimplementedError();
}

void main() {
  group('KhatmaSelectWirdSheet Widget Tests (Reference 08)', () {
    late _FakeKhatmaRepository repository;
    late KhatmaCubit cubit;

    setUp(() {
      repository = _FakeKhatmaRepository();
      cubit = KhatmaCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    Future<void> pumpSelectWirdSheet(
      WidgetTester tester, {
      VoidCallback? onBack,
      ValueChanged<int>? onStartWirdSelected,
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
                  child: KhatmaSelectWirdSheet(
                    program: KhatmaProgram.defaultProgram,
                    onBack: onBack,
                    onStartWirdSelected: onStartWirdSelected,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders top bar with back arrow and title "بدء الختمة من"',
        (tester) async {
      await pumpSelectWirdSheet(tester);

      expect(find.text(AppStrings.tr(AppStrings.startFrom)), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders "بداية المصحف" top option matching Reference 08',
        (tester) async {
      await pumpSelectWirdSheet(tester);

      expect(find.text(AppStrings.tr(AppStrings.mushafBeginning)), findsOneWidget);
    });

    testWidgets(
        'renders daily wird items with Arabic numerals and range text',
        (tester) async {
      await pumpSelectWirdSheet(tester);

      // Verify "ورد اليوم ١" and its subline
      final wird1Title =
          '${AppStrings.tr(AppStrings.wirdOfToday)} ${toArabicDigits(1)}';
      expect(find.text(wird1Title), findsOneWidget);
      expect(find.text('من الفاتحة إلى البقرة: ١٤١'), findsOneWidget);

      // Verify "ورد اليوم ٢"
      final wird2Title =
          '${AppStrings.tr(AppStrings.wirdOfToday)} ${toArabicDigits(2)}';
      expect(find.text(wird2Title), findsOneWidget);
      expect(find.text('من البقرة: ١٤٢ إلى البقرة: ٢٥٢'), findsOneWidget);

      // Verify "ورد اليوم ٦" has customTitle "المائدة"
      final wird6Title =
          '${AppStrings.tr(AppStrings.wirdOfToday)} ${toArabicDigits(6)}';
      await tester.scrollUntilVisible(
        find.text(wird6Title),
        100.0,
      );
      expect(find.text(wird6Title), findsOneWidget);
      expect(find.text('المائدة'), findsOneWidget);
    });

    testWidgets('tapping "بداية المصحف" invokes onStartWirdSelected with 1',
        (tester) async {
      int? selectedWird;
      await pumpSelectWirdSheet(
        tester,
        onStartWirdSelected: (wird) => selectedWird = wird,
      );

      final beginningCard = find.text(AppStrings.tr(AppStrings.mushafBeginning));
      await tester.tap(beginningCard);
      await tester.pumpAndSettle();

      expect(selectedWird, equals(1));
    });

    testWidgets('tapping a daily wird row invokes onStartWirdSelected with its number',
        (tester) async {
      int? selectedWird;
      await pumpSelectWirdSheet(
        tester,
        onStartWirdSelected: (wird) => selectedWird = wird,
      );

      final wird3Title =
          '${AppStrings.tr(AppStrings.wirdOfToday)} ${toArabicDigits(3)}';
      await tester.tap(find.text(wird3Title));
      await tester.pumpAndSettle();

      expect(selectedWird, equals(3));
    });

    testWidgets(
        'tapping a daily wird row without callback creates Khatma starting at that wird',
        (tester) async {
      cubit.startCreation();
      cubit.selectProgram(KhatmaProgram.defaultProgram);

      await pumpSelectWirdSheet(tester);

      final wird4Title =
          '${AppStrings.tr(AppStrings.wirdOfToday)} ${toArabicDigits(4)}';
      await tester.tap(find.text(wird4Title));
      await tester.pumpAndSettle();

      expect(repository.lastCreatedProgram,
          equals(KhatmaProgram.defaultProgram));
      expect(repository.lastStartWirdNumber, equals(4));
      expect(cubit.state, isA<KhatmaLoaded>());
    });

    testWidgets('tapping back arrow invokes onBack callback', (tester) async {
      bool backTapped = false;
      await pumpSelectWirdSheet(
        tester,
        onBack: () => backTapped = true,
      );

      final backButton = find.byIcon(Icons.arrow_forward_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(backTapped, isTrue);
    });

    testWidgets(
        'tapping back arrow without onBack navigates back to startFrom step',
        (tester) async {
      cubit.startCreation();
      cubit.selectProgram(KhatmaProgram.defaultProgram);
      cubit.goToStep(KhatmaCreationStep.selectWird);

      await pumpSelectWirdSheet(tester);

      final backButton = find.byIcon(Icons.arrow_forward_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(cubit.state, isA<KhatmaCreating>());
      final state = cubit.state as KhatmaCreating;
      expect(state.step, equals(KhatmaCreationStep.startFrom));
    });
  });
}

