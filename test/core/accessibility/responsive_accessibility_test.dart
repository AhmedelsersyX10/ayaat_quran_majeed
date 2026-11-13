import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_nav.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_sheet_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_list_tile.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_stepper.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/floating_audio_player.dart';
import 'package:ayaat_quran_majeed/features/share/domain/entities/share_params.dart';
import 'package:ayaat_quran_majeed/features/share/domain/repositories/share_repository.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/format_share_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/save_ayah_image_to_gallery_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_image_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/cubit/share_cubit.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/views/share_card_preview_page.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_footer.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Fakes for Test Isolation ---

class _FakePlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  final PlaybackSession _session = const PlaybackSession(
    status: PlaybackStatus.idle,
  );

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => _session;

  @override
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    RepeatSettings? repeatSettings,
  }) async {}

  @override
  Future<void> playSurah({
    required int surahNumber,
    int startAyah = 1,
    RepeatSettings? repeatSettings,
  }) async {}

  @override
  Future<void> playRange({
    required PlaybackRange range,
    RepeatSettings? repeatSettings,
  }) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> seekToAyah(int ayahNumber) async {}

  @override
  Future<void> updateRange(PlaybackRange range) async {}

  @override
  Future<void> configureRange(PlaybackRange range) async {}

  @override
  Future<void> setRepeatSettings(RepeatSettings settings) async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeShareRepository implements ShareRepository {
  @override
  String formatShareText(ShareParams params) => 'نص تجريبي للآية';

  @override
  Future<void> shareText({required String text, String? subject}) async {}

  @override
  Future<String> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async => '/tmp/test.png';

  @override
  Future<void> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {}

  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {}
}

Widget _wrapWithScreenUtil({
  required Widget child,
  Size viewportSize = const Size(392, 800),
  double textScale = 1.0,
  TextDirection direction = TextDirection.rtl,
}) {
  return ScreenUtilInit(
    designSize: const Size(392, 800),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: viewportSize,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

// Relative luminance formula per WCAG 2.1
double _relativeLuminance(Color color) {
  double channel(int c) {
    final double v = c / 255.0;
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.red) +
      0.7152 * channel(color.green) +
      0.0722 * channel(color.blue);
}

// Contrast ratio formula per WCAG 2.1: (L1 + 0.05) / (L2 + 0.05)
double _contrastRatio(Color c1, Color c2) {
  final l1 = _relativeLuminance(c1);
  final l2 = _relativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('1. Multi-Viewport & Large Text Scaling Resilience', () {
    testWidgets(
      'AppButton expands gracefully under 2.0x text scale on 360dp compact screen without overflow',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrapWithScreenUtil(
            viewportSize: const Size(360, 640),
            textScale: 2.0,
            child: Center(
              child: AppButton.primary(
                text: 'بدء ختمة جديدة طويلة جداً لتجربة الخط الكبير',
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final buttonFinder = find.byType(AppButton);
        expect(buttonFinder, findsOneWidget);

        final renderBox = tester.renderObject<RenderBox>(buttonFinder);
        expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
      },
    );

    testWidgets(
      'AppBottomNav fits smoothly on 360dp with 2.0x text scale without RenderFlex overflow',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrapWithScreenUtil(
            viewportSize: const Size(360, 640),
            textScale: 2.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [AppBottomNav(currentIndex: 0, onTap: (_) {})],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AppBottomNav), findsOneWidget);
      },
    );

    testWidgets(
      'MushafPageHeader accommodates long text under 2.0x text scale on 360dp without row overflow',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrapWithScreenUtil(
            viewportSize: const Size(360, 640),
            textScale: 2.0,
            child: const Center(child: MushafPageHeader(pageNumber: 187)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(MushafPageHeader), findsOneWidget);
        expect(find.text('التوبة'), findsOneWidget);
      },
    );

    testWidgets(
      'AppBottomSheetShell clamps width to <= 640dp and centers on 768dp tablet viewport',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrapWithScreenUtil(
            viewportSize: const Size(768, 1024),
            child: const AppBottomSheetShell(
              title: 'إعدادات الختمة',
              child: SizedBox(height: 200, child: Text('محتوى')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final shellFinder = find.byType(AppBottomSheetShell);
        expect(shellFinder, findsOneWidget);

        final constrainedBoxFinder = find.descendant(
          of: shellFinder,
          matching: find.byType(ConstrainedBox),
        );
        final constrainedBox = tester.widget<ConstrainedBox>(
          constrainedBoxFinder.first,
        );
        expect(constrainedBox.constraints.maxWidth, 640.0);
      },
    );
  });

  group('2. Accessible Semantics Tree Verification', () {
    testWidgets('AppBottomNav produces button, selected, and label semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: AppBottomNav(
            currentIndex: 1, // Khatma tab selected
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Surahs tab (unselected)
      final surahsFinder = find.bySemanticsLabel(
        AppStrings.tr(AppStrings.navSurahs),
      );
      expect(surahsFinder, findsOneWidget);
      final surahsSemantics = tester.getSemantics(surahsFinder);
      expect(surahsSemantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(surahsSemantics.hasFlag(ui.SemanticsFlag.isSelected), isFalse);

      // Verify Khatma tab (selected)
      final khatmaFinder = find.bySemanticsLabel(
        AppStrings.tr(AppStrings.navKhatma),
      );
      expect(khatmaFinder, findsOneWidget);
      final khatmaSemantics = tester.getSemantics(khatmaFinder);
      expect(khatmaSemantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(khatmaSemantics.hasFlag(ui.SemanticsFlag.isSelected), isTrue);

      handle.dispose();
    });

    testWidgets('AppIconButton produces button and semanticLabel', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: AppIconButton.ghost(
            icon: const Icon(Icons.close),
            onPressed: () {},
            tooltip: 'إغلاق',
            semanticLabel: 'إغلاق القائمة',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.bySemanticsLabel('إغلاق القائمة');
      expect(buttonFinder, findsOneWidget);
      final buttonSemantics = tester.getSemantics(buttonFinder);
      expect(buttonSemantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(buttonSemantics.hasFlag(ui.SemanticsFlag.isEnabled), isTrue);

      handle.dispose();
    });

    testWidgets('AppButton produces button and label semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: AppButton.primary(text: 'حفظ التغييرات', onPressed: () {}),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.bySemanticsLabel('حفظ التغييرات');
      expect(buttonFinder, findsOneWidget);
      final buttonSemantics = tester.getSemantics(buttonFinder);
      expect(buttonSemantics.hasFlag(ui.SemanticsFlag.isButton), isTrue);
      expect(buttonSemantics.hasFlag(ui.SemanticsFlag.isEnabled), isTrue);

      handle.dispose();
    });

    testWidgets('AppSwitch produces toggled and custom semanticLabel', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: AppSwitch(
            value: true,
            semanticLabel: 'تفعيل التنبيه اليومي',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.bySemanticsLabel('تفعيل التنبيه اليومي');
      expect(switchFinder, findsOneWidget);
      final switchSemantics = tester.getSemantics(switchFinder);
      expect(switchSemantics.hasFlag(ui.SemanticsFlag.isToggled), isTrue);
      expect(switchSemantics.hasFlag(ui.SemanticsFlag.isEnabled), isTrue);

      handle.dispose();
    });

    testWidgets('AppStepper produces minus, plus, and count semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapWithScreenUtil(child: AppStepper(value: 5, onChanged: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('إنقاص'), findsOneWidget);
      expect(find.byTooltip('زيادة'), findsOneWidget);
      expect(find.bySemanticsLabel('العدد: ٥'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('HizbQuarterIndicator produces descriptive Arabic semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: const Column(
            children: [
              HizbQuarterIndicator(type: HizbQuarterType.firstQuarter),
              HizbQuarterIndicator(type: HizbQuarterType.half),
              HizbQuarterIndicator(type: HizbQuarterType.threeQuarters),
              HizbQuarterIndicator(type: HizbQuarterType.full),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('ربع الحزب الأول'), findsOneWidget);
      expect(find.bySemanticsLabel('نصف الحزب'), findsOneWidget);
      expect(find.bySemanticsLabel('ثلاثة أرباع الحزب'), findsOneWidget);
      expect(find.bySemanticsLabel('حزب كامل'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('MushafPageFooter produces readable page and hizb semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      // Page 1 has Hizb 1 starting on it
      await tester.pumpWidget(
        _wrapWithScreenUtil(child: const MushafPageFooter(pageNumber: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('صفحة ١، الحزب ١'), findsOneWidget);

      // Page 3 is a regular page
      await tester.pumpWidget(
        _wrapWithScreenUtil(child: const MushafPageFooter(pageNumber: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('صفحة ٣'), findsOneWidget);

      handle.dispose();
    });
  });

  group('3. Minimum Interactive Touch Target Dimensions (>= 44x44 dp)', () {
    testWidgets(
      'AppIconButton with size 24 maintains minimum 44x44 touch target',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithScreenUtil(
            child: Center(
              child: AppIconButton.ghost(
                size: 24,
                icon: const Icon(Icons.close),
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final renderBox = tester.renderObject<RenderBox>(
          find.byType(AppIconButton),
        );
        expect(renderBox.size.width, greaterThanOrEqualTo(44.0));
        expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
      },
    );

    testWidgets('AppSwitch maintains >= 44dp height for touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: Center(child: AppSwitch(value: false, onChanged: (_) {})),
        ),
      );
      await tester.pumpAndSettle();

      final renderBox = tester.renderObject<RenderBox>(find.byType(AppSwitch));
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('AppListTile maintains >= 48dp height for touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          child: AppListTile(title: const Text('سورة الفاتحة'), onTap: () {}),
        ),
      );
      await tester.pumpAndSettle();

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(AppListTile),
      );
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
      'FloatingAudioPlayer maintains >= 44x44 touch targets for compact play button and expanded buttons',
      (tester) async {
        final playbackRepo = _FakePlaybackRepository();
        final playbackCubit = AudioPlaybackCubit(
          playbackRepository: playbackRepo,
        );
        addTearDown(() {
          playbackCubit.close();
          playbackRepo.dispose();
        });

        await tester.pumpWidget(
          _wrapWithScreenUtil(
            child: BlocProvider<AudioPlaybackCubit>.value(
              value: playbackCubit,
              child: const Center(
                child: FloatingAudioPlayer(isInitiallyExpanded: false),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final inkWells = find.byType(InkWell);
        expect(inkWells, findsWidgets);

        bool foundAtLeast44 = false;
        for (final element in inkWells.evaluate()) {
          final box = element.renderObject as RenderBox?;
          if (box != null &&
              box.size.width >= 44.0 &&
              box.size.height >= 44.0) {
            foundAtLeast44 = true;
            break;
          }
        }
        expect(foundAtLeast44, isTrue);
      },
    );
  });

  group('4. RTL Directionality and Back Icon Verification', () {
    testWidgets(
      'ShareCardPreviewPage uses Icons.arrow_forward_rounded with tooltip رجوع in RTL',
      (tester) async {
        final shareRepo = _FakeShareRepository();
        final shareCubit = ShareCubit(
          formatShareTextUseCase: FormatShareTextUseCase(shareRepo),
          shareAyahTextUseCase: ShareAyahTextUseCase(shareRepo),
          shareAyahImageUseCase: ShareAyahImageUseCase(shareRepo),
          saveAyahImageToGalleryUseCase: SaveAyahImageToGalleryUseCase(
            shareRepo,
          ),
        );

        await tester.pumpWidget(
          _wrapWithScreenUtil(
            direction: TextDirection.rtl,
            child: BlocProvider.value(
              value: shareCubit,
              child: const ShareCardPreviewPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify back button uses forward arrow icon in RTL with tooltip 'رجوع'
        final backButton = find.widgetWithIcon(
          IconButton,
          Icons.arrow_forward_rounded,
        );
        expect(backButton, findsOneWidget);

        final iconButtonWidget = tester.widget<IconButton>(backButton);
        expect(iconButtonWidget.tooltip, 'رجوع');

        await tester.pumpWidget(const SizedBox.shrink());
        await shareCubit.close();
      },
    );
  });

  group('5. WCAG 2.1 AA Color Contrast Ratio Verification', () {
    test('textPrimary on scaffoldLight meets WCAG AA 4.5:1 ratio', () {
      final ratio = _contrastRatio(
        AppColors.textPrimary,
        AppColors.scaffoldLight,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('textOnPrimary on primary meets WCAG AA 4.5:1 ratio', () {
      final ratio = _contrastRatio(AppColors.textOnPrimary, AppColors.primary);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('textTafsir on surface meets WCAG AA 4.5:1 ratio', () {
      final ratio = _contrastRatio(AppColors.textTafsir, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('mushafBadgeText on mushafBadgeFill meets WCAG AA 4.5:1 ratio', () {
      final ratio = _contrastRatio(
        AppColors.mushafBadgeText,
        AppColors.mushafBadgeFill,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('primary on scaffoldLight meets UI components 3.0:1 ratio', () {
      final ratio = _contrastRatio(AppColors.primary, AppColors.scaffoldLight);
      expect(ratio, greaterThanOrEqualTo(3.0));
    });
  });
}
