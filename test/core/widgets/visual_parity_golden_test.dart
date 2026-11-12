import 'dart:async';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_nav.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/play_to_sheet.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/recitation_settings_sheet.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_row_item.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_empty_view.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_time_picker_dialog.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/new_khatma_menu_sheet.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_editor_dialog.dart';
import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/today_ayah_sheet.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  PlaybackSession _session = const PlaybackSession(status: PlaybackStatus.idle);

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
    _session = _session.copyWith(range: range);
    _controller.add(_session);
  }

  @override
  Future<void> configureRange(PlaybackRange range) async {
    _session = _session.copyWith(range: range);
    _controller.add(_session);
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
    _session = _session.copyWith(repeatSettings: settings);
    _controller.add(_session);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class _StubTodayRepository implements TodayRepository {
  @override
  int getHijriOffset() => 0;

  @override
  Future<void> setHijriOffset(int offset) async {}

  @override
  Future<TodayAyah> getTodayAyah({DateTime? forDate}) async {
    return TodayAyah(
      surahNumber: 1,
      ayahNumber: 2,
      ayahText: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
      ayahEndSymbol: '﴿٢﴾',
      pageNumber: 1,
      surahNameArabic: 'الفاتحة',
      hijriDay: '١٩',
      hijriMonthName: 'جمادى الأولى',
      gregorianDay: '٣٠',
      gregorianMonthName: 'أكتوبر',
      localDate: DateTime(2023, 10, 30),
      hijriOffset: 0,
    );
  }
}

void main() {
  const metadataService = QuranMetadataService();
  late _FakePlaybackRepository playbackRepo;
  late AudioPlaybackCubit audioCubit;
  late _StubTodayRepository todayRepo;
  late TodayCubit todayCubit;

  setUp(() async {
    playbackRepo = _FakePlaybackRepository();
    audioCubit = AudioPlaybackCubit(playbackRepository: playbackRepo);
    todayRepo = _StubTodayRepository();
    todayCubit = TodayCubit(todayRepo);
    await todayCubit.loadTodayAyah();
  });

  tearDown(() async {
    await audioCubit.close();
    await playbackRepo.dispose();
    await todayCubit.close();
  });

  /// Helper to test a widget across 3 distinct viewport categories:
  /// 1. Compact Phone: 360 x 740, DPR 2.0
  /// 2. Reference Standard Phone: 392.7 x 800.7, DPR 2.75
  /// 3. Tablet: 768 x 1024, DPR 2.0
  Future<void> testMultiViewport({
    required WidgetTester tester,
    required Widget Function(BuildContext) widgetBuilder,
    required Future<void> Function(WidgetTester tester, String viewportName)
        verify,
  }) async {
    final viewports = <String, Map<String, dynamic>>{
      'Compact (360dp)': {'size': const Size(720, 1480), 'dpr': 2.0},
      'Standard (392dp)': {'size': const Size(1080, 2200), 'dpr': 2.75},
      'Tablet (768dp)': {'size': const Size(1536, 2048), 'dpr': 2.0},
    };

    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value['size'] as Size;
      final dpr = entry.value['dpr'] as double;

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = dpr;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392.72727272727275, 800.7272727272727),
          builder: (context, _) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AudioPlaybackCubit>.value(value: audioCubit),
                BlocProvider<TodayCubit>.value(value: todayCubit),
              ],
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: Builder(builder: widgetBuilder),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        tester.takeException(),
        isNull,
        reason: '$name threw an exception or overflowed',
      );

      await verify(tester, name);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  }

  group('Visual Parity & Layout Stability Tests (Task 9.01)', () {
    testWidgets(
        'AppBottomNav: 5 tabs render with RTL alignment across 360, 392, and tablet without overflow',
        (tester) async {
      int selectedTab = 0;
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => AppBottomNav(
          currentIndex: selectedTab,
          onTap: (index) => selectedTab = index,
        ),
        verify: (tester, viewport) async {
          expect(find.text(AppStrings.tr(AppStrings.navSurahs)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.navKhatma)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.navBookmarks)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.navStarred)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.navNotes)), findsOneWidget);
        },
      );
    });

    testWidgets(
        'KhatmaEmptyView (Ref 10): empty state card and action button render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => KhatmaEmptyView(
          onStartKhatma: () {},
        ),
        verify: (tester, viewport) async {
          expect(find.text(AppStrings.tr(AppStrings.khatmaTitle)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.startKhatmaBtn)), findsOneWidget);
        },
      );
    });

    testWidgets(
        'KhatmaTimePickerDialog (Ref 23): Eastern Arabic-Indic numerals & AM/PM render without overflow',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const KhatmaTimePickerDialog(
          initialTime: TimeOfDay(hour: 7, minute: 0),
        ),
        verify: (tester, viewport) async {
          expect(find.text('٠٧'), findsOneWidget);
          expect(find.text('٠٠'), findsOneWidget);
          expect(find.text('ص'), findsOneWidget);
          expect(find.text('م'), findsOneWidget);
          expect(find.text('إلغاء'), findsOneWidget);
          expect(find.text('حسنًا'), findsOneWidget);
        },
      );
    });

    testWidgets(
        'RecitationSettingsSheet (Ref 40): Range endpoints & repeat counters render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const RecitationSettingsSheet(
          metadataService: metadataService,
        ),
        verify: (tester, viewport) async {
          expect(find.text(AppStrings.tr(AppStrings.recitationSettings)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.repeatRange)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.repeatAyah)), findsOneWidget);
        },
      );
    });

    testWidgets(
        'AyahOptionsSheet (Refs 19 & 20): Action rows and header render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const AyahOptionsSheet(
          surahNumber: 1,
          verseNumber: 1,
          metadataService: metadataService,
        ),
        verify: (tester, viewport) async {
          expect(find.text('الفاتحة : ١'), findsOneWidget);
          expect(find.byType(AyahOptionsSheet), findsOneWidget);
        },
      );
    });

    testWidgets(
        'TodayAyahSheet (Ref 16): Hijri and Gregorian calendar cards render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => TodayAyahSheet(
          onShare: (_) {},
          onTafsir: (_) {},
          onAyahTap: (_) {},
        ),
        verify: (tester, viewport) async {
          expect(find.text(AppStrings.tr(AppStrings.todayTitle)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.todayAyah)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.tafsir)), findsOneWidget);
        },
      );
    });

    testWidgets(
        'BookmarkRowItem (Refs 11 & 27): Assigned and unassigned bookmarks render cleanly across viewports',
        (tester) async {
      const unassigned = BookmarkItem(
        id: 'yellow',
        name: 'أصفر',
        colorHex: '#FFEB3B',
      );
      final assigned = BookmarkItem(
        id: 'green',
        name: 'أخضر',
        colorHex: '#4CAF50',
        surahNumber: 2,
        verseNumber: 255,
        pageNumber: 42,
        updatedAt: DateTime(2023, 10, 30, 14, 30),
      );

      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => Column(
          children: [
            const BookmarkRowItem(
                item: unassigned, metadataService: metadataService),
            BookmarkRowItem(item: assigned, metadataService: metadataService),
          ],
        ),
        verify: (tester, viewport) async {
          expect(find.text('أصفر'), findsOneWidget);
          expect(find.text('أخضر'), findsOneWidget);
          expect(find.byType(BookmarkRowItem), findsNWidgets(2));
        },
      );
    });

    testWidgets(
        'HizbQuarterIndicator (Ref 04): Quarter progress indicators render cleanly without clipping',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HizbQuarterIndicator(type: HizbQuarterType.firstQuarter),
            SizedBox(width: 8),
            HizbQuarterIndicator(type: HizbQuarterType.half),
            SizedBox(width: 8),
            HizbQuarterIndicator(type: HizbQuarterType.threeQuarters),
            SizedBox(width: 8),
            HizbQuarterIndicator(type: HizbQuarterType.full),
          ],
        ),
        verify: (tester, viewport) async {
          expect(find.byType(HizbQuarterIndicator), findsNWidgets(4));
        },
      );
    });

    testWidgets(
        'PlayToSheet (Ref 22): Presets and boundary options render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const PlayToSheet(
          surahNumber: 1,
          verseNumber: 1,
          metadataService: metadataService,
        ),
        verify: (tester, viewport) async {
          expect(find.text('الفاتحة: ١'), findsWidgets);
          expect(find.text(AppStrings.tr(AppStrings.endOfSurah)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.endOfPage)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.continuousRecitation)), findsOneWidget);
        },
      );
    });

    testWidgets(
        'NewKhatmaMenuSheet (Ref 06): Suggested and custom options render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const NewKhatmaMenuSheet(),
        verify: (tester, viewport) async {
          expect(find.text(AppStrings.tr(AppStrings.newKhatma)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.suggestedKhatmaHeader)), findsOneWidget);
          expect(find.text(AppStrings.tr(AppStrings.otherCategory)), findsOneWidget);
        },
      );
    });

    testWidgets(
        'NoteEditorDialog (Ref 29): Quoted Ayah card and header render cleanly across viewports',
        (tester) async {
      await testMultiViewport(
        tester: tester,
        widgetBuilder: (context) => const NoteEditorDialog(
          surahNumber: 1,
          verseNumber: 1,
        ),
        verify: (tester, viewport) async {
          expect(find.text('الفاتحة: ١'), findsOneWidget);
          expect(find.byType(NoteEditorDialog), findsOneWidget);
        },
      );
    });
  });
}
