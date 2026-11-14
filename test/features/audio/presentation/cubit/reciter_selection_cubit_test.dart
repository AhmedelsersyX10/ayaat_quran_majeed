import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAudioRepository implements AudioRepository {
  List<Reciter> recitersResponse = [];
  Reciter? selectedReciterResponse;
  Moshaf? selectedMoshafResponse;
  Failure? failureToThrow;

  int? lastSavedReciterId;
  int? lastSavedMoshafId;

  @override
  Future<List<Reciter>> getReciters({bool forceRefresh = false}) async {
    if (failureToThrow != null) throw failureToThrow!;
    return recitersResponse;
  }

  @override
  Future<Reciter?> getSelectedReciter() async {
    if (failureToThrow != null) throw failureToThrow!;
    return selectedReciterResponse;
  }

  @override
  Future<Moshaf?> getSelectedMoshaf() async {
    if (failureToThrow != null) throw failureToThrow!;
    return selectedMoshafResponse;
  }

  @override
  Future<void> setSelectedReciterAndMoshaf({
    required int reciterId,
    required int moshafId,
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    lastSavedReciterId = reciterId;
    lastSavedMoshafId = moshafId;
  }

  @override
  Future<Reciter?> getReciterById(int reciterId) async => null;

  @override
  Future<List<int>> getTimingSupportedMoshafIds({
    bool forceRefresh = false,
  }) async => [];

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async => [];

  @override
  Future<List<AyahTiming>> getAyahTiming({
    required int readId,
    required int surahNumber,
  }) async => [];

  @override
  Future<List<ReciterSurah>> getSurahsForMoshaf({
    required int reciterId,
    required Moshaf moshaf,
  }) async => [];

  @override
  Future<bool> isSurahDownloaded({
    required int readId,
    required int surahNumber,
  }) async => false;

  @override
  Future<String> getPlayableAudioUri({
    required Moshaf moshaf,
    required int surahNumber,
  }) async => '';

  @override
  Future<void> downloadSurah({
    required Moshaf moshaf,
    required int surahNumber,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {}

  @override
  Future<void> deleteDownloadedSurah({
    required int readId,
    required int surahNumber,
  }) async {}

  @override
  Future<int> cleanOrphanedTempFiles() async => 0;

  @override
  Future<int> getAudioStorageUsageBytes() async => 0;
}

void main() {
  late FakeAudioRepository repository;
  late ReciterSelectionCubit cubit;

  const moshafTiming1 = Moshaf(
    id: 118,
    name: 'حفص مرتل',
    server: 'https://server.com/118/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2],
    hasTiming: true,
  );

  const moshafNoTiming = Moshaf(
    id: 999,
    name: 'رواية نادرة',
    server: 'https://server.com/999/',
    surahTotal: 114,
    moshafType: 2,
    surahList: [1, 2],
    hasTiming: false,
  );

  const reciterHosary = Reciter(
    id: 1,
    name: 'محمود خليل الحصري',
    letter: 'م',
    moshafs: [moshafTiming1],
  );

  const reciterGhamadi = Reciter(
    id: 2,
    name: 'سعد الغامدي',
    letter: 'س',
    moshafs: [
      Moshaf(
        id: 30,
        name: 'حفص',
        server: 'https://server.com/30/',
        surahTotal: 114,
        moshafType: 1,
        surahList: [1, 2],
        hasTiming: true,
      ),
    ],
  );

  const reciterNoTiming = Reciter(
    id: 3,
    name: 'قارئ بدون توقيت',
    letter: 'ق',
    moshafs: [moshafNoTiming],
  );

  setUp(() {
    repository = FakeAudioRepository();
    cubit = ReciterSelectionCubit(audioRepository: repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('ReciterSelectionCubit Tests', () {
    test('initial state is ReciterSelectionInitial', () {
      expect(cubit.state, equals(const ReciterSelectionInitial()));
    });

    test(
      'loadReciters emits [Loading, Success] filtering only qualified reciters (timing policy)',
      () async {
        repository.recitersResponse = [
          reciterNoTiming,
          reciterHosary,
          reciterGhamadi,
        ];
        repository.selectedReciterResponse = reciterHosary;
        repository.selectedMoshafResponse = moshafTiming1;

        final states = <ReciterSelectionState>[];
        cubit.stream.listen(states.add);

        await cubit.loadReciters();
        await pumpEventQueue();

        expect(states.length, equals(2));
        expect(states[0], isA<ReciterSelectionLoading>());
        expect(states[1], isA<ReciterSelectionSuccess>());

        final success = states[1] as ReciterSelectionSuccess;
        // Qualified reciters must NOT contain reciterNoTiming
        expect(success.reciters.contains(reciterNoTiming), isFalse);
        expect(success.reciters.length, equals(2));
        // Must be sorted alphabetically: 'سعد الغامدي' before 'محمود خليل الحصري'
        expect(success.reciters[0].name, equals('سعد الغامدي'));
        expect(success.reciters[1].name, equals('محمود خليل الحصري'));
        expect(success.selectedReciter, equals(reciterHosary));
        expect(success.selectedMoshaf, equals(moshafTiming1));
      },
    );

    test(
      'loadReciters emits [Loading, Empty] when no reciters meet timing policy',
      () async {
        repository.recitersResponse = [reciterNoTiming];

        final states = <ReciterSelectionState>[];
        cubit.stream.listen(states.add);

        await cubit.loadReciters();
        await pumpEventQueue();

        expect(states.length, equals(2));
        expect(states[0], isA<ReciterSelectionLoading>());
        expect(states[1], isA<ReciterSelectionEmpty>());
      },
    );

    test(
      'loadReciters emits [Loading, Failure] when repository throws Failure',
      () async {
        repository.failureToThrow = const ServerFailure(
          'خطأ في الاتصال بالخادم',
        );

        final states = <ReciterSelectionState>[];
        cubit.stream.listen(states.add);

        await cubit.loadReciters();
        await pumpEventQueue();

        expect(states.length, equals(2));
        expect(states[0], isA<ReciterSelectionLoading>());
        expect(states[1], isA<ReciterSelectionFailure>());
        expect(
          (states[1] as ReciterSelectionFailure).message,
          contains('خطأ في الاتصال'),
        );
      },
    );

    test(
      'selectReciterAndMoshaf updates state and saves choice to repository',
      () async {
        repository.recitersResponse = [reciterHosary, reciterGhamadi];
        repository.selectedReciterResponse = reciterHosary;
        repository.selectedMoshafResponse = moshafTiming1;

        await cubit.loadReciters();

        final targetMoshaf = reciterGhamadi.moshafs.first;
        await cubit.selectReciterAndMoshaf(
          reciter: reciterGhamadi,
          moshaf: targetMoshaf,
        );

        expect(repository.lastSavedReciterId, equals(2));
        expect(repository.lastSavedMoshafId, equals(30));

        final state = cubit.state as ReciterSelectionSuccess;
        expect(state.selectedReciter, equals(reciterGhamadi));
        expect(state.selectedMoshaf, equals(targetMoshaf));
      },
    );
  });
}
