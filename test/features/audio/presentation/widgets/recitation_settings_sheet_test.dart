import 'dart:async';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/recitation_settings_sheet.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  PlaybackSession _session = const PlaybackSession(status: PlaybackStatus.idle);

  int setRepeatSettingsCalls = 0;
  int configureRangeCalls = 0;
  int updateRangeCalls = 0;
  RepeatSettings? lastRepeatSettings;
  PlaybackRange? lastConfiguredRange;

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => _session;

  void emit(PlaybackSession s) {
    _session = s;
    _controller.add(s);
  }

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
  Future<void> updateRange(PlaybackRange range) async {
    updateRangeCalls++;
    emit(_session.copyWith(range: range));
  }

  @override
  Future<void> configureRange(PlaybackRange range) async {
    configureRangeCalls++;
    lastConfiguredRange = range;
    emit(_session.copyWith(range: range));
  }

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
  Future<void> setRepeatSettings(RepeatSettings settings) async {
    setRepeatSettingsCalls++;
    lastRepeatSettings = settings;
    emit(_session.copyWith(repeatSettings: settings));
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late _FakePlaybackRepository mockRepo;
  late AudioPlaybackCubit cubit;
  const metadataService = QuranMetadataService();

  setUp(() {
    mockRepo = _FakePlaybackRepository();
    cubit = AudioPlaybackCubit(playbackRepository: mockRepo);
  });

  tearDown(() async {
    await cubit.close();
    await mockRepo.dispose();
  });

  Future<void> pumpSettingsSheet(WidgetTester tester, {PlaybackSession? initialSession}) async {
    if (initialSession != null) {
      mockRepo.emit(initialSession);
      await tester.pump();
    }
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(392, 852),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: BlocProvider<AudioPlaybackCubit>.value(
              value: cubit,
              child: const RecitationSettingsSheet(
                metadataService: metadataService,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RecitationSettingsSheet Widget Tests (Reference 40)', () {
    testWidgets('renders all headers, labels, and default Arabic numerals matching Ref 40', (tester) async {
      await pumpSettingsSheet(tester);

      // Header title: "إعدادات التلاوة"
      expect(find.text(AppStrings.tr(AppStrings.recitationSettings)), findsOneWidget);

      // Section 1: "نطاق التلاوة"
      expect(find.text(AppStrings.tr(AppStrings.recitationRange)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.fromAyah)), findsOneWidget);
      expect(find.text('الفاتحة: ١'), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.toAyah)), findsOneWidget);
      expect(find.text('الفاتحة: ٧'), findsOneWidget);

      // Section 2: "التكرار"
      expect(find.text(AppStrings.tr(AppStrings.repeatSection)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.repeatRange)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.repeatAyah)), findsOneWidget);
      expect(find.text(AppStrings.tr(AppStrings.repeatCount)), findsNWidgets(2));

      // Lavender boxed counters display "٢" for both range and ayah
      expect(find.text('٢'), findsNWidgets(2));

      // Switches are initially OFF (repeat is 1 in default session)
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, equals(2));
      expect(switches[0].value, isFalse); // Range repeat switch OFF
      expect(switches[1].value, isFalse); // Ayah repeat switch OFF
    });

    testWidgets('toggling range repeat switch ON sets repeatRange to 2 and updates engine', (tester) async {
      await pumpSettingsSheet(tester);

      // Toggle first switch (تكرار النطاق)
      final switches = find.byType(Switch);
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(1));
      expect(mockRepo.lastRepeatSettings?.repeatRange, equals(2));
    });

    testWidgets('toggling range repeat switch OFF resets repeatRange to 1 and updates engine', (tester) async {
      await pumpSettingsSheet(tester,
        initialSession: const PlaybackSession(
          repeatSettings: RepeatSettings(repeatRange: 3),
        ),
      );

      final firstSwitch = tester.widgetList<Switch>(find.byType(Switch)).first;
      expect(firstSwitch.value, isTrue);

      // Toggle it OFF
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(1));
      expect(mockRepo.lastRepeatSettings?.repeatRange, equals(1));
    });

    testWidgets('pressing + on range repeat increments count and updates engine', (tester) async {
      await pumpSettingsSheet(tester,
        initialSession: const PlaybackSession(
          repeatSettings: RepeatSettings(repeatRange: 2),
        ),
      );

      final addButtons = find.bySemanticsLabel('زيادة التكرار');
      expect(addButtons, findsNWidgets(2));

      // Tap range add button
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(1));
      expect(mockRepo.lastRepeatSettings?.repeatRange, equals(3));
      expect(find.text('٣'), findsOneWidget);
    });

    testWidgets('pressing - on range repeat decrements count and turns off at 2', (tester) async {
      await pumpSettingsSheet(tester,
        initialSession: const PlaybackSession(
          repeatSettings: RepeatSettings(repeatRange: 3),
        ),
      );

      final minusButtons = find.bySemanticsLabel('إنقاص التكرار');
      expect(minusButtons, findsNWidgets(2));

      // Decrement from 3 to 2
      await tester.tap(minusButtons.first);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(1));
      expect(mockRepo.lastRepeatSettings?.repeatRange, equals(2));

      // Decrement from 2 should revert to 1 (switch off)
      await tester.tap(minusButtons.first);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(2));
      expect(mockRepo.lastRepeatSettings?.repeatRange, equals(1));
    });

    testWidgets('toggling and steppers for ayah repeat work correctly', (tester) async {
      await pumpSettingsSheet(tester);

      // Toggle second switch (تكرار الآية)
      final switches = find.byType(Switch);
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(1));
      expect(mockRepo.lastRepeatSettings?.repeatAyah, equals(2));

      // Tap ayah add button
      final addButtons = find.bySemanticsLabel('زيادة التكرار');
      await tester.ensureVisible(addButtons.last);
      await tester.tap(addButtons.last);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(2));
      expect(mockRepo.lastRepeatSettings?.repeatAyah, equals(3));

      // Tap ayah minus button
      final minusButtons = find.bySemanticsLabel('إنقاص التكرار');
      await tester.ensureVisible(minusButtons.last);
      await tester.tap(minusButtons.last);
      await tester.pumpAndSettle();

      expect(mockRepo.setRepeatSettingsCalls, equals(3));
      expect(mockRepo.lastRepeatSettings?.repeatAyah, equals(2));
    });

    testWidgets('tapping من opens AyahPickerSheet and adjusts order if needed', (tester) async {
      await pumpSettingsSheet(tester,
        initialSession: const PlaybackSession(
          range: PlaybackRange(
            startSurah: 1,
            startAyah: 1,
            endSurah: 1,
            endAyah: 5,
          ),
        ),
      );

      // Tap "من" row
      await tester.tap(find.text(AppStrings.tr(AppStrings.fromAyah)));
      await tester.pumpAndSettle();

      // AyahPickerSheet is opened
      expect(find.text(AppStrings.tr(AppStrings.selectAyah)), findsOneWidget);
      expect(find.text('الفاتحة : ٣'), findsOneWidget);

      // Select verse 3
      await tester.tap(find.text('الفاتحة : ٣'));
      await tester.pumpAndSettle();

      // Returned to settings
      expect(mockRepo.configureRangeCalls, equals(1));
      expect(mockRepo.lastConfiguredRange?.startAyah, equals(3));
      expect(mockRepo.lastConfiguredRange?.endAyah, equals(5));
      expect(find.text('الفاتحة: ٣'), findsOneWidget);
    });

    testWidgets('tapping إلى opens AyahPickerSheet and adjusts order if before start', (tester) async {
      await pumpSettingsSheet(tester,
        initialSession: const PlaybackSession(
          range: PlaybackRange(
            startSurah: 1,
            startAyah: 3,
            endSurah: 1,
            endAyah: 7,
          ),
        ),
      );

      // Tap "إلى" row
      await tester.tap(find.text(AppStrings.tr(AppStrings.toAyah)));
      await tester.pumpAndSettle();

      // AyahPickerSheet is opened
      expect(find.text(AppStrings.tr(AppStrings.selectAyah)), findsOneWidget);

      // Select verse 2 (which is before start verse 3)
      await tester.tap(find.text('الفاتحة : ٢'));
      await tester.pumpAndSettle();

      // Returned to settings: order validation should clamp start to 2
      expect(mockRepo.configureRangeCalls, equals(1));
      expect(mockRepo.lastConfiguredRange?.startAyah, equals(2));
      expect(mockRepo.lastConfiguredRange?.endAyah, equals(2));
    });
  });
}
