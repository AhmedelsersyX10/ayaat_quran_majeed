import 'dart:async';

import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/views/reciter_surahs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAudioRepository implements AudioRepository {
  Reciter? reciter;
  List<ReciterSurah> surahs = [];
  int downloadCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Reciter?> getReciterById(int reciterId) async => reciter;

  @override
  Future<List<Reciter>> getReciters({bool forceRefresh = false}) async =>
      reciter != null ? [reciter!] : [];

  @override
  Future<List<ReciterSurah>> getSurahsForMoshaf({
    required int reciterId,
    required Moshaf moshaf,
  }) async {
    return surahs;
  }

  @override
  Future<void> downloadSurah({
    required Moshaf moshaf,
    required int surahNumber,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    downloadCalls++;
  }

  @override
  Future<void> deleteDownloadedSurah({
    required int readId,
    required int surahNumber,
  }) async {
    deleteCalls++;
  }

  @override
  Future<bool> isSurahDownloaded({required int readId, required int surahNumber}) async =>
      false;

  @override
  Future<String> getPlayableAudioUri({required Moshaf moshaf, required int surahNumber}) async =>
      'https://server.mp3quran.net/001.mp3';

  @override
  Future<List<AyahTiming>> getAyahTiming({required int readId, required int surahNumber}) async =>
      const [];

  @override
  Future<Moshaf?> getSelectedMoshaf() async => null;

  @override
  Future<Reciter?> getSelectedReciter() async => null;

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async => const [];

  @override
  Future<List<int>> getTimingSupportedMoshafIds({bool forceRefresh = false}) async =>
      const [];

  @override
  Future<void> setSelectedReciterAndMoshaf({
    required int reciterId,
    required int moshafId,
  }) async {}
}

class _FakePlaybackRepository implements PlaybackRepository {
  final StreamController<PlaybackSession> _controller =
      StreamController<PlaybackSession>.broadcast();
  int playSurahCalls = 0;
  int? lastPlayedSurah;

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => const PlaybackSession(status: PlaybackStatus.idle);

  @override
  Future<void> playSurah({
    required int surahNumber,
    int startAyah = 1,
    RepeatSettings? repeatSettings,
  }) async {
    playSurahCalls++;
    lastPlayedSurah = surahNumber;
  }

  @override
  Future<void> playAyah({required int surahNumber, required int ayahNumber, RepeatSettings? repeatSettings}) async {}

  @override
  Future<void> playRange({required PlaybackRange range, RepeatSettings? repeatSettings}) async {}

  @override
  Future<void> updateRange(PlaybackRange range) async {}

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
  Future<void> setRepeatSettings(RepeatSettings settings) async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late _FakeAudioRepository fakeAudioRepo;
  late _FakePlaybackRepository fakePlaybackRepo;
  late ReciterSurahsCubit reciterSurahsCubit;
  late AudioPlaybackCubit audioPlaybackCubit;

  const testMoshaf = Moshaf(
    id: 1,
    name: 'حفص عن عاصم',
    server: 'https://server.mp3quran.net/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2, 3],
    hasTiming: true,
  );

  const testReciter = Reciter(
    id: 10,
    name: 'أحمد النفيس',
    letter: 'أ',
    moshafs: [testMoshaf],
  );

  final testSurahs = [
    const ReciterSurah(
      surahNumber: 1,
      surahName: 'الفاتحة',
      juzNumber: 1,
      verseCount: 7,
      audioUrl: 'https://server/001.mp3',
      isDownloaded: false,
    ),
    const ReciterSurah(
      surahNumber: 2,
      surahName: 'البقرة',
      juzNumber: 1,
      verseCount: 286,
      audioUrl: 'https://server/002.mp3',
      isDownloaded: false,
    ),
    const ReciterSurah(
      surahNumber: 3,
      surahName: 'آل عمران',
      juzNumber: 3,
      verseCount: 200,
      audioUrl: 'https://server/003.mp3',
      isDownloaded: true,
    ),
  ];

  setUp(() {
    fakeAudioRepo = _FakeAudioRepository();
    fakeAudioRepo.reciter = testReciter;
    fakeAudioRepo.surahs = testSurahs;

    fakePlaybackRepo = _FakePlaybackRepository();

    reciterSurahsCubit = ReciterSurahsCubit(audioRepository: fakeAudioRepo);
    audioPlaybackCubit = AudioPlaybackCubit(playbackRepository: fakePlaybackRepo);
  });

  tearDown(() async {
    await reciterSurahsCubit.close();
    await audioPlaybackCubit.close();
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ReciterSurahsCubit>.value(value: reciterSurahsCubit),
            BlocProvider<AudioPlaybackCubit>.value(value: audioPlaybackCubit),
          ],
          child: const ReciterSurahsPage(reciterId: 10),
        ),
      ),
    );
  }

  group('ReciterSurahsPage Widget Tests (Reference 36)', () {
    testWidgets('renders top bar with reciter name and green back arrow', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await reciterSurahsCubit.loadSurahs(reciterId: 10);
      await tester.pumpAndSettle();

      // Top bar reciter name
      expect(find.text('أحمد النفيس'), findsOneWidget);

      // Back arrow icon
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders Juz headers ("الجزء ١", "الجزء ٣") and surah rows', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await reciterSurahsCubit.loadSurahs(reciterId: 10);
      await tester.pumpAndSettle();

      // Juz 1 and Juz 3 headers in Arabic-Indic numerals
      expect(find.textContaining('١'), findsWidgets);
      expect(find.textContaining('٣'), findsWidgets);

      // Surah names
      expect(find.text('الفاتحة'), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);
      expect(find.text('آل عمران'), findsOneWidget);
    });

    testWidgets('renders cloud icon for un-downloaded and green checkmark for downloaded surah', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await reciterSurahsCubit.loadSurahs(reciterId: 10);
      await tester.pumpAndSettle();

      // Surah 1 & 2 are not downloaded -> cloud download outline icon
      expect(find.byIcon(Icons.cloud_download_outlined), findsNWidgets(2));

      // Surah 3 is downloaded -> green checkmark ("وعلامة خضراء للمكتمل")
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('tapping cloud icon calls downloadSurah on cubit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await reciterSurahsCubit.loadSurahs(reciterId: 10);
      await tester.pumpAndSettle();

      final firstCloudIcon = find.byIcon(Icons.cloud_download_outlined).first;
      await tester.tap(firstCloudIcon);
      await tester.pump();

      expect(fakeAudioRepo.downloadCalls, 1);
    });

    testWidgets('tapping surah row initiates audio playback for that surah', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await reciterSurahsCubit.loadSurahs(reciterId: 10);
      await tester.pumpAndSettle();

      await tester.tap(find.text('البقرة'));
      await tester.pump();

      expect(fakePlaybackRepo.playSurahCalls, 1);
      expect(fakePlaybackRepo.lastPlayedSurah, 2);
    });
  });
}
