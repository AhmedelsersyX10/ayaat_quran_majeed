import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockAudioRepository implements AudioRepository {
  Reciter? reciterToReturn;
  List<ReciterSurah> surahsToReturn = [];
  bool failDownload = false;
  bool downloadShouldCancel = false;
  int downloadCallCount = 0;
  int cancelCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<Reciter?> getReciterById(int reciterId) async => reciterToReturn;

  @override
  Future<List<Reciter>> getReciters({bool forceRefresh = false}) async =>
      reciterToReturn != null ? [reciterToReturn!] : [];

  @override
  Future<List<ReciterSurah>> getSurahsForMoshaf({
    required int reciterId,
    required Moshaf moshaf,
  }) async {
    return surahsToReturn;
  }

  @override
  Future<void> downloadSurah({
    required Moshaf moshaf,
    required int surahNumber,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    downloadCallCount++;
    if (failDownload) {
      throw const ServerFailure('Download server error', 'SERVER_ERROR');
    }
    if (downloadShouldCancel) {
      throw const GeneralFailure('Download cancelled');
    }
    onProgress?.call(500, 1000);
    onProgress?.call(1000, 1000);
  }

  @override
  Future<void> deleteDownloadedSurah({
    required int readId,
    required int surahNumber,
  }) async {
    deleteCallCount++;
  }

  @override
  Future<bool> isSurahDownloaded({
    required int readId,
    required int surahNumber,
  }) async {
    return false;
  }

  @override
  Future<String> getPlayableAudioUri({
    required Moshaf moshaf,
    required int surahNumber,
  }) async {
    return 'https://server.mp3quran.net/001.mp3';
  }

  @override
  Future<List<AyahTiming>> getAyahTiming({
    required int readId,
    required int surahNumber,
  }) async {
    return const [];
  }

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

void main() {
  late _MockAudioRepository mockRepo;
  late ReciterSurahsCubit cubit;

  const testMoshaf = Moshaf(
    id: 10,
    name: 'حفص عن عاصم',
    server: 'https://server.mp3quran.net/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2, 3],
    hasTiming: true,
  );

  const testReciter = Reciter(
    id: 1,
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
    mockRepo = _MockAudioRepository();
    mockRepo.reciterToReturn = testReciter;
    mockRepo.surahsToReturn = testSurahs;
    cubit = ReciterSurahsCubit(audioRepository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('ReciterSurahsCubit — Lifecycle and State Flow', () {
    test('initial state is ReciterSurahsInitial', () {
      expect(cubit.state, isA<ReciterSurahsInitial>());
    });

    test('loadSurahs emits Loading then Loaded with surahs grouped by starting Juz', () async {
      final states = <ReciterSurahsState>[];
      cubit.stream.listen((s) {
        states.add(s);
      });

      await cubit.loadSurahs(reciterId: 1);
      // Wait for any pending microtasks
      await Future<void>.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<ReciterSurahsLoading>());
      expect(states[1], isA<ReciterSurahsLoaded>());

      final loaded = states[1] as ReciterSurahsLoaded;
      expect(loaded.reciter.name, 'أحمد النفيس');
      expect(loaded.surahs.length, 3);
      // Grouped by Juz: Juz 1 (Fatiha, Baqarah), Juz 3 (Ali 'Imran)
      expect(loaded.juzGroups.length, 2);
      expect(loaded.juzGroups[0].juzNumber, 1);
      expect(loaded.juzGroups[0].surahs.length, 2);
      expect(loaded.juzGroups[1].juzNumber, 3);
      expect(loaded.juzGroups[1].surahs.length, 1);

      // Verify download statuses
      expect(loaded.downloadStatuses[1], SurahDownloadStatus.notDownloaded);
      expect(loaded.downloadStatuses[2], SurahDownloadStatus.notDownloaded);
      expect(loaded.downloadStatuses[3], SurahDownloadStatus.downloaded);
    });

    test('loadSurahs emits Failure when reciter is not found', () async {
      mockRepo.reciterToReturn = null;
      final states = <ReciterSurahsState>[];
      cubit.stream.listen((s) {
        states.add(s);
      });

      await cubit.loadSurahs(reciterId: 999);
      await Future<void>.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<ReciterSurahsLoading>());
      expect(states[1], isA<ReciterSurahsFailure>());
    });

    test('downloadSurah updates progress and completes with downloaded status', () async {
      await cubit.loadSurahs(reciterId: 1);

      final states = <ReciterSurahsState>[];
      cubit.stream.listen(states.add);

      await cubit.downloadSurah(1);

      expect(mockRepo.downloadCallCount, 1);
      final finalState = cubit.state as ReciterSurahsLoaded;
      expect(finalState.downloadStatuses[1], SurahDownloadStatus.downloaded);
      expect(finalState.downloadProgresses[1], 1.0);
      expect(finalState.surahs.firstWhere((s) => s.surahNumber == 1).isDownloaded, isTrue);
    });

    test('downloadSurah handles failure and sets failed status', () async {
      mockRepo.failDownload = true;
      await cubit.loadSurahs(reciterId: 1);

      await cubit.downloadSurah(1);

      final state = cubit.state as ReciterSurahsLoaded;
      expect(state.downloadStatuses[1], SurahDownloadStatus.failed);
      expect(state.errorMessages[1], 'Download server error');
    });

    test('cancelDownload stops download and resets status to notDownloaded', () async {
      await cubit.loadSurahs(reciterId: 1);

      cubit.cancelDownload(1);

      final state = cubit.state as ReciterSurahsLoaded;
      expect(state.downloadStatuses[1], SurahDownloadStatus.notDownloaded);
      expect(state.downloadProgresses[1], isNull);
    });

    test('deleteDownloadedSurah removes local download and resets status', () async {
      await cubit.loadSurahs(reciterId: 1);
      final initialLoaded = cubit.state as ReciterSurahsLoaded;
      expect(initialLoaded.downloadStatuses[3], SurahDownloadStatus.downloaded);

      await cubit.deleteDownloadedSurah(3);

      expect(mockRepo.deleteCallCount, 1);
      final finalState = cubit.state as ReciterSurahsLoaded;
      expect(finalState.downloadStatuses[3], SurahDownloadStatus.notDownloaded);
      expect(finalState.surahs.firstWhere((s) => s.surahNumber == 3).isDownloaded, isFalse);
    });
  });
}
