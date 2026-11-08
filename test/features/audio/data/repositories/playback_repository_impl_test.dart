import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/features/audio/data/repositories/playback_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/audio/data/services/audio_player_service.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_audio_player_service.dart';

class MockAudioRepository implements AudioRepository {
  Reciter? selectedReciter;
  Moshaf? selectedMoshaf;
  List<Reciter> reciters = [];
  Map<String, List<AyahTiming>> timingsMap = {};
  Map<String, String> audioUrisMap = {};
  bool shouldThrow = false;

  @override
  Future<Reciter?> getSelectedReciter() async => selectedReciter;

  @override
  Future<Moshaf?> getSelectedMoshaf() async => selectedMoshaf;

  @override
  Future<List<Reciter>> getReciters({bool forceRefresh = false}) async {
    if (shouldThrow) throw const ServerException('Network error', '500');
    return reciters;
  }

  @override
  Future<List<AyahTiming>> getAyahTiming({
    required int readId,
    required int surahNumber,
  }) async {
    final key = '$readId:$surahNumber';
    return timingsMap[key] ?? [];
  }

  @override
  Future<String> getPlayableAudioUri({
    required Moshaf moshaf,
    required int surahNumber,
  }) async {
    if (shouldThrow) throw const ServerException('Audio unreachable', '404');
    final key = '${moshaf.id}:$surahNumber';
    return audioUrisMap[key] ?? 'https://server.test/${surahNumber.toString().padLeft(3, '0')}.mp3';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAudioPlayerService fakePlayer;
  late MockAudioRepository mockAudioRepo;
  late PlaybackRepositoryImpl repository;

  const testMoshaf = Moshaf(
    id: 1,
    name: 'حفص عن عاصم',
    server: 'https://server.test/',
    surahTotal: 114,
    moshafType: 1,
    hasTiming: true,
    surahList: [1, 2, 3],
  );

  const testReciter = Reciter(
    id: 10,
    name: 'مشاري العفاسي',
    letter: 'م',
    moshafs: [testMoshaf],
  );

  final fatihaTimings = [
    const AyahTiming(ayah: 0, startTimeMs: 0, endTimeMs: 1000), // Basmala
    const AyahTiming(ayah: 1, startTimeMs: 1000, endTimeMs: 4000),
    const AyahTiming(ayah: 2, startTimeMs: 4000, endTimeMs: 7000),
    const AyahTiming(ayah: 3, startTimeMs: 7000, endTimeMs: 10000),
    const AyahTiming(ayah: 4, startTimeMs: 10000, endTimeMs: 13000),
    const AyahTiming(ayah: 5, startTimeMs: 13000, endTimeMs: 16000),
    const AyahTiming(ayah: 6, startTimeMs: 16000, endTimeMs: 19000),
    const AyahTiming(ayah: 7, startTimeMs: 19000, endTimeMs: 23000),
  ];

  setUp(() {
    fakePlayer = FakeAudioPlayerService();
    mockAudioRepo = MockAudioRepository()
      ..selectedReciter = testReciter
      ..selectedMoshaf = testMoshaf
      ..reciters = [testReciter]
      ..timingsMap['1:1'] = fatihaTimings;

    repository = PlaybackRepositoryImpl(
      playerService: fakePlayer,
      audioRepository: mockAudioRepo,
      metadataService: const QuranMetadataService(),
    );
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('PlaybackRepositoryImpl Core Playback Tests', () {
    test('initial state is idle with no active session', () {
      expect(repository.currentSession.status, PlaybackStatus.idle);
      expect(repository.currentSession.currentAyah, isNull);
    });

    test('playAyah loads audio, sets source, seeks start timestamp, and plays', () async {
      await repository.playAyah(surahNumber: 1, ayahNumber: 3);

      expect(fakePlayer.lastSourceUri, contains('001.mp3'));
      expect(fakePlayer.lastTitle, contains('سورة الفاتحة'));
      expect(fakePlayer.lastArtist, equals('مشاري العفاسي'));
      expect(fakePlayer.seekCalls, contains(const Duration(milliseconds: 7000)));
      expect(fakePlayer.playCalls, equals(1));

      expect(repository.currentSession.status, PlaybackStatus.playing);
      expect(repository.currentSession.surahNumber, 1);
      expect(repository.currentSession.currentAyah, 3);
      expect(repository.currentSession.hasTiming, isTrue);
    });

    test('position updates synchronize reciting ayah in real time (Ref 37)', () async {
      await repository.playSurah(surahNumber: 1);

      // In Basmala window (0-1000ms), ayah is null
      fakePlayer.simulatePosition(const Duration(milliseconds: 500));
      await pumpEventQueue();
      expect(repository.currentSession.currentAyah, isNull);

      // In Ayah 1 (1000-4000ms)
      fakePlayer.simulatePosition(const Duration(milliseconds: 2500));
      await pumpEventQueue();
      expect(repository.currentSession.currentAyah, equals(1));

      // Transition to Ayah 2 (4000-7000ms)
      fakePlayer.simulatePosition(const Duration(milliseconds: 4500));
      await pumpEventQueue();
      expect(repository.currentSession.currentAyah, equals(2));
    });

    test('ayah repetition rule seeks back to verse start (Ref 40)', () async {
      await repository.playAyah(
        surahNumber: 1,
        ayahNumber: 2,
        repeatSettings: const RepeatSettings(repeatAyah: 2),
      );

      expect(repository.currentSession.repeatSettings.currentAyahRepeat, 1);

      // Move position near end of Ayah 2 (which ends at 7000ms)
      fakePlayer.simulatePosition(const Duration(milliseconds: 6900));
      await pumpEventQueue();

      // Should seek back to 4000ms (start of Ayah 2) and increment repeat counter
      expect(fakePlayer.seekCalls, contains(const Duration(milliseconds: 4000)));
      expect(repository.currentSession.repeatSettings.currentAyahRepeat, 2);
    });

    test('range repetition rule loops designated range before completing (Ref 40)', () async {
      final range = PlaybackRange.custom(
        startSurah: 1,
        startAyah: 1,
        endSurah: 1,
        endAyah: 2,
      );

      await repository.playRange(
        range: range,
        repeatSettings: const RepeatSettings(repeatRange: 2),
      );

      expect(repository.currentSession.repeatSettings.currentRangeRepeat, 1);

      // Reach end of range (Ayah 2 ends at 7000ms)
      fakePlayer.simulatePosition(const Duration(milliseconds: 6900));
      await pumpEventQueue();

      // Should seek back to start of range (Ayah 1 at 1000ms) and increment range repeat
      expect(fakePlayer.seekCalls, contains(const Duration(milliseconds: 1000)));
      expect(repository.currentSession.repeatSettings.currentRangeRepeat, 2);

      // Finish second repeat
      fakePlayer.simulatePosition(const Duration(milliseconds: 6900));
      await pumpEventQueue();
      expect(repository.currentSession.status, PlaybackStatus.completed);
    });

    test('pause, resume, and stop transition states accurately', () async {
      await repository.playSurah(surahNumber: 1);
      expect(repository.currentSession.status, PlaybackStatus.playing);

      await repository.pause();
      expect(fakePlayer.pauseCalls, 1);
      expect(repository.currentSession.status, PlaybackStatus.paused);

      await repository.resume();
      expect(fakePlayer.playCalls, 2);
      expect(repository.currentSession.status, PlaybackStatus.playing);

      await repository.stop();
      expect(fakePlayer.stopCalls, 1);
      expect(repository.currentSession.status, PlaybackStatus.idle);
    });

    test('audio interruption pauses playback and resumes upon recovery', () async {
      await repository.playSurah(surahNumber: 1);
      expect(repository.currentSession.status, PlaybackStatus.playing);

      // Headphone unplug (becoming noisy)
      fakePlayer.simulateHeadphoneUnplug();
      await pumpEventQueue();
      expect(repository.currentSession.status, PlaybackStatus.paused);

      // Transient focus restoration (e.g. call end)
      fakePlayer.simulateInterruption(const AudioEngineInterruption(
        kind: AudioInterruptionKind.resume,
        isTransient: true,
      ));
      await pumpEventQueue();
      expect(repository.currentSession.status, PlaybackStatus.playing);
    });

    test('failure is cleanly emitted if audio repository throws error', () async {
      mockAudioRepo.shouldThrow = true;

      await repository.playSurah(surahNumber: 1);
      expect(repository.currentSession.status, PlaybackStatus.failure);
      expect(repository.currentSession.errorMessage, isNotNull);
    });

    test('updateRange dynamically updates active range without interrupting audio', () async {
      await repository.playAyah(surahNumber: 1, ayahNumber: 1);
      expect(repository.currentSession.status, PlaybackStatus.playing);
      expect(fakePlayer.playCalls, 1);

      const newRange = PlaybackRange(
        startSurah: 1,
        startAyah: 1,
        endSurah: 1,
        endAyah: 5,
      );

      await repository.updateRange(newRange);
      expect(repository.currentSession.range, equals(newRange));
      // Does not restart audio
      expect(fakePlayer.playCalls, 1);
      expect(repository.currentSession.status, PlaybackStatus.playing);
    });

    test('updateRange pauses and marks completed if current position is past new end', () async {
      await repository.playAyah(surahNumber: 1, ayahNumber: 1);
      // Simulate position reaching ayah 3 (7000-10000ms)
      fakePlayer.simulatePosition(const Duration(milliseconds: 7500));
      await pumpEventQueue();
      expect(repository.currentSession.currentAyah, equals(3));

      // Update range to end at ayah 2 (which is already past)
      const newRange = PlaybackRange(
        startSurah: 1,
        startAyah: 1,
        endSurah: 1,
        endAyah: 2,
      );

      await repository.updateRange(newRange);
      expect(fakePlayer.pauseCalls, 1);
      expect(repository.currentSession.status, PlaybackStatus.completed);
    });

    test('updateRange starts playback if session was idle', () async {
      expect(repository.currentSession.status, PlaybackStatus.idle);

      const range = PlaybackRange(
        startSurah: 1,
        startAyah: 1,
        endSurah: 1,
        endAyah: 7,
      );

      await repository.updateRange(range);
      expect(repository.currentSession.status, PlaybackStatus.playing);
      expect(fakePlayer.playCalls, 1);
      expect(repository.currentSession.range, equals(range));
    });
  });
}
