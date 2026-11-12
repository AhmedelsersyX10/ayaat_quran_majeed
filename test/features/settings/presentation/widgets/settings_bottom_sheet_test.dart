import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/app_settings.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/repositories/settings_repository.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/widgets/sources_and_licenses_sheet.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/hijri_adjustment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class StubSettingsRepository implements SettingsRepository {
  AppSettings currentSettings = const AppSettings();

  @override
  AppSettings getSettings() => currentSettings;

  @override
  Future<void> setKeepScreenAwake(bool value) async {
    currentSettings = currentSettings.copyWith(keepScreenAwake: value);
  }

  @override
  Future<void> setHijriOffset(int offset) async {
    currentSettings = currentSettings.copyWith(hijriOffset: offset);
  }

  @override
  Future<void> setMushafFontSize(double fontSize) async {
    currentSettings = currentSettings.copyWith(mushafFontSize: fontSize);
  }

  @override
  List<ContentSource> getSourcesAndAttributions() {
    return const [
      ContentSource(
        title: 'محرك المصحف',
        provider: 'مجمع الملك فهد',
        description: 'خطوط الرسم العثماني',
        category: ContentSourceCategory.quranEngine,
      ),
    ];
  }
}

void main() {
  late StubSettingsRepository stubRepository;
  late SettingsCubit settingsCubit;

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1176,
      2556,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;

    stubRepository = StubSettingsRepository();
    settingsCubit = SettingsCubit(repository: stubRepository);
  });

  tearDown(() {
    settingsCubit.close();
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  Widget buildTestWidget({required SettingsCubit cubit}) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: cubit,
            child: const SettingsBottomSheet(),
          ),
        ),
      ),
    );
  }

  group('SettingsBottomSheet Widget Tests', () {
    testWidgets('renders loading state when initial', (tester) async {
      await tester.pumpWidget(buildTestWidget(cubit: settingsCubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders all 4 settings items when loaded', (tester) async {
      settingsCubit.loadSettings();
      await tester.pumpWidget(buildTestWidget(cubit: settingsCubit));
      await tester.pumpAndSettle();

      // 1. Keep Screen Awake
      expect(find.text('إبقاء الشاشة مستيقظة'), findsOneWidget);
      expect(find.byType(AppSwitch), findsOneWidget);

      // 2. Hijri Calendar Adjustment
      expect(find.text('ضبط التاريخ الهجري'), findsOneWidget);
      expect(
        find.text(AppStrings.tr(AppStrings.hijriDefaultUmmAlQura)),
        findsOneWidget,
      );

      // 3. Mushaf font size info
      expect(find.text('حجم خط المصحف'), findsOneWidget);
      expect(find.text('١٥ سطراً'), findsOneWidget);

      // 4. Sources and attributions
      expect(find.text('المصادر والتراخيص'), findsOneWidget);
    });

    testWidgets('toggles keepScreenAwake on tapping tile or switch', (
      tester,
    ) async {
      settingsCubit.loadSettings();
      await tester.pumpWidget(buildTestWidget(cubit: settingsCubit));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(AppSwitch);
      expect(switchFinder, findsOneWidget);

      final appSwitch = tester.widget<AppSwitch>(switchFinder);
      expect(appSwitch.value, isTrue);

      // Tap on the tile to toggle
      await tester.tap(find.text('إبقاء الشاشة مستيقظة'));
      await tester.pumpAndSettle();

      final toggledSwitch = tester.widget<AppSwitch>(switchFinder);
      expect(toggledSwitch.value, isFalse);
      expect(stubRepository.currentSettings.keepScreenAwake, isFalse);
    });

    testWidgets(
      'opens HijriAdjustmentDialog when tapping Hijri adjustment tile',
      (tester) async {
        settingsCubit.loadSettings();
        await tester.pumpWidget(buildTestWidget(cubit: settingsCubit));
        await tester.pumpAndSettle();

        await tester.tap(find.text('ضبط التاريخ الهجري'));
        await tester.pumpAndSettle();

        expect(find.byType(HijriAdjustmentDialog), findsOneWidget);
      },
    );

    testWidgets('opens SourcesAndLicensesSheet when tapping sources tile', (
      tester,
    ) async {
      if (!sl.isRegistered<SettingsRepository>()) {
        sl.registerLazySingleton<SettingsRepository>(() => stubRepository);
      }

      settingsCubit.loadSettings();
      await tester.pumpWidget(buildTestWidget(cubit: settingsCubit));
      await tester.pumpAndSettle();

      await tester.tap(find.text('المصادر والتراخيص'));
      await tester.pumpAndSettle();

      expect(find.byType(SourcesAndLicensesSheet), findsOneWidget);
    });
  });
}
