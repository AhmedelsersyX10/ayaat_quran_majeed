import 'dart:async';
import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/audio/data/services/audio_player_service.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Clean Architecture implementation of [PlaybackRepository].
///
/// Coordinates audio player hardware abstraction ([AudioPlayerService]), reciter/timing
/// data ([AudioRepository]), and Quran structure metadata ([QuranMetadataService]).
class PlaybackRepositoryImpl implements PlaybackRepository {
  final AudioPlayerService _playerService;
  final AudioRepository _audioRepository;
  final QuranMetadataService _metadataService;

  final StreamController<PlaybackSession> _sessionController =
      StreamController<PlaybackSession>.broadcast();

  PlaybackSession _session = PlaybackSession.initial();
  SurahTiming? _currentSurahTiming;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _bufferedSub;
  StreamSubscription<AudioEngineStatus>? _statusSub;
  StreamSubscription<AudioEngineInterruption>? _interruptionSub;
  StreamSubscription<void>? _completedSub;

  bool _isSeekingForRepeat = false;

  PlaybackRepositoryImpl({
    required AudioPlayerService playerService,
    required AudioRepository audioRepository,
    QuranMetadataService metadataService = const QuranMetadataService(),
  })  : _playerService = playerService,
        _audioRepository = audioRepository,
        _metadataService = metadataService {
    _initListeners();
  }

  void _initListeners() {
    _positionSub = _playerService.positionStream.listen(_onPositionChanged);
    _durationSub = _playerService.durationStream.listen(_onDurationChanged);
    _bufferedSub = _playerService.bufferedPositionStream.listen(_onBufferedChanged);
    _statusSub = _playerService.statusStream.listen(_onEngineStatusChanged);
    _interruptionSub =
        _playerService.interruptionStream.listen(_onInterruptionChanged);
    _completedSub = _playerService.completedStream.listen((_) => _onTrackCompleted());
  }

  @override
  Stream<PlaybackSession> get sessionStream => _sessionController.stream;

  @override
  PlaybackSession get currentSession => _session;

  void _emit(PlaybackSession session) {
    _session = session;
    if (!_sessionController.isClosed) {
      _sessionController.add(_session);
    }
  }

  @override
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    RepeatSettings? repeatSettings,
  }) async {
    final totalAyat = _metadataService.getVerseCount(surahNumber);
    final range = PlaybackRange(
      startSurah: surahNumber,
      startAyah: ayahNumber,
      endSurah: surahNumber,
      endAyah: totalAyat > 0 ? totalAyat : ayahNumber,
    );

    await playRange(range: range, repeatSettings: repeatSettings);
  }

  @override
  Future<void> playSurah({
    required int surahNumber,
    int startAyah = 1,
    RepeatSettings? repeatSettings,
  }) async {
    final totalAyat = _metadataService.getVerseCount(surahNumber);
    final range = PlaybackRange(
      startSurah: surahNumber,
      startAyah: startAyah,
      endSurah: surahNumber,
      endAyah: totalAyat > 0 ? totalAyat : startAyah,
    );

    await playRange(range: range, repeatSettings: repeatSettings);
  }

  @override
  Future<void> playRange({
    required PlaybackRange range,
    RepeatSettings? repeatSettings,
  }) async {
    final effectiveRepeat = repeatSettings ?? const RepeatSettings();
    _emit(_session.copyWith(
      status: PlaybackStatus.loading,
      range: range,
      repeatSettings: effectiveRepeat,
      currentAyah: () => range.startAyah,
      errorMessage: () => null,
    ));

    await _loadAndPlaySurah(
      surahNumber: range.startSurah,
      startAyah: range.startAyah,
      range: range,
      repeatSettings: effectiveRepeat,
    );
  }

  @override
  Future<void> updateRange(PlaybackRange range) async {
    // If playback session is actively running or paused
    if (_session.isActive) {
      final currentSurah = _session.surahNumber;
      final currentAyah = _session.currentAyah ?? 1;

      // If current position is past the new range end, stop/pause and complete
      if (range.isPastEnd(currentSurah, currentAyah)) {
        await _playerService.pause();
        _emit(_session.copyWith(
          range: range,
          status: PlaybackStatus.completed,
        ));
        return;
      }

      // If current position is before the new range start, re-initialize at range start
      if (range.isBeforeStart(currentSurah, currentAyah)) {
        await playRange(range: range, repeatSettings: _session.repeatSettings);
        return;
      }

      // Otherwise, position is within the new range:
      // Update the boundary dynamically without interrupting ongoing playback
      _emit(_session.copyWith(range: range));
    } else {
      // Not active: start playing from range start
      await playRange(range: range, repeatSettings: _session.repeatSettings);
    }
  }

  Future<void> _loadAndPlaySurah({
    required int surahNumber,
    required int startAyah,
    required PlaybackRange range,
    required RepeatSettings repeatSettings,
  }) async {
    try {
      // 1. Resolve selected Reciter and Moshaf
      var reciter = await _audioRepository.getSelectedReciter();
      var moshaf = await _audioRepository.getSelectedMoshaf();

      if (reciter == null || moshaf == null) {
        final all = await _audioRepository.getReciters();
        final qualified = all.where((r) => r.hasAnyTimingSupport).toList();
        if (qualified.isNotEmpty) {
          reciter = qualified.first;
          moshaf = reciter.defaultMoshaf ?? reciter.moshafs.first;
        } else if (all.isNotEmpty) {
          reciter = all.first;
          moshaf = reciter.defaultMoshaf ?? reciter.moshafs.first;
        }
      }

      if (reciter == null || moshaf == null) {
        _emit(_session.copyWith(
          status: PlaybackStatus.failure,
          errorMessage: () => 'No reciter configured for playback',
        ));
        return;
      }

      // 2. Fetch timing intervals for surahNumber
      List<AyahTiming> timingList = const [];
      if (moshaf.hasTiming) {
        try {
          timingList = await _audioRepository.getAyahTiming(
            readId: moshaf.id,
            surahNumber: surahNumber,
          );
        } catch (_) {
          timingList = const [];
        }
      }

      _currentSurahTiming = SurahTiming(
        surahNumber: surahNumber,
        readId: moshaf.id,
        ayahTimings: timingList,
      );

      // 3. Resolve playable audio URI (offline file or remote streaming URL)
      final audioUri = await _audioRepository.getPlayableAudioUri(
        moshaf: moshaf,
        surahNumber: surahNumber,
      );

      final surahName = _metadataService.getSurahNameArabic(surahNumber);

      // 4. Set source on AudioPlayerService
      await _playerService.setSource(
        audioUri,
        title: 'سورة $surahName',
        artist: reciter.name,
      );

      // 5. Determine initial seek offset if starting at startAyah > 1
      Duration initialSeek = Duration.zero;
      if (startAyah > 1 && timingList.isNotEmpty) {
        final matching = timingList.where((t) => t.ayah == startAyah).toList();
        if (matching.isNotEmpty) {
          initialSeek = Duration(milliseconds: matching.first.startTimeMs);
        }
      }

      if (initialSeek > Duration.zero) {
        await _playerService.seek(initialSeek);
      }

      // 6. Update session snapshot
      _emit(_session.copyWith(
        status: PlaybackStatus.playing,
        surahNumber: surahNumber,
        currentAyah: () => startAyah,
        position: initialSeek,
        reciter: reciter,
        moshaf: moshaf,
        range: range,
        repeatSettings: repeatSettings,
        hasTiming: timingList.isNotEmpty,
        errorMessage: () => null,
      ));

      await _playerService.play();
    } on AppException catch (e) {
      _emit(_session.copyWith(
        status: PlaybackStatus.failure,
        errorMessage: () => e.message,
      ));
    } on Failure catch (e) {
      _emit(_session.copyWith(
        status: PlaybackStatus.failure,
        errorMessage: () => e.message,
      ));
    } catch (e) {
      _emit(_session.copyWith(
        status: PlaybackStatus.failure,
        errorMessage: () => 'Failed to initialize audio: $e',
      ));
    }
  }

  void _onPositionChanged(Duration position) {
    if (_isSeekingForRepeat) return;

    if (_session.status != PlaybackStatus.playing &&
        _session.status != PlaybackStatus.paused &&
        _session.status != PlaybackStatus.loading) {
      return;
    }

    final posMs = position.inMilliseconds;
    final detectedAyah = _currentSurahTiming?.findAyahAt(posMs);
    final int? activeAyah;
    if (_currentSurahTiming != null && _currentSurahTiming!.hasTiming) {
      activeAyah = detectedAyah;
    } else {
      activeAyah = _session.currentAyah;
    }

    // Repetition and boundary checks
    if (_currentSurahTiming != null &&
        _currentSurahTiming!.hasTiming &&
        activeAyah != null) {
      final timing = _currentSurahTiming!.ayahTimings
          .where((t) => t.ayah == activeAyah)
          .firstOrNull;

      if (timing != null) {
        // 1. Ayah repetition rule (Reference 40)
        final repeatAyah = _session.repeatSettings.repeatAyah;
        final currentAyahRep = _session.repeatSettings.currentAyahRepeat;

        if (repeatAyah > 1 && posMs >= (timing.endTimeMs - 150)) {
          if (currentAyahRep < repeatAyah) {
            _isSeekingForRepeat = true;
            _emit(_session.copyWith(
              repeatSettings: _session.repeatSettings.copyWith(
                currentAyahRepeat: currentAyahRep + 1,
              ),
            ));
            _playerService
                .seek(Duration(milliseconds: timing.startTimeMs))
                .whenComplete(() {
              _isSeekingForRepeat = false;
            });
            return;
          }
        }

        // 2. Range boundary rule: if this is the last ayah in the range
        if (_session.range.isLastAyah(_session.surahNumber, activeAyah) &&
            posMs >= (timing.endTimeMs - 150)) {
          final repeatRange = _session.repeatSettings.repeatRange;
          final currentRangeRep = _session.repeatSettings.currentRangeRepeat;

          if (currentRangeRep < repeatRange) {
            // Repeat range
            _isSeekingForRepeat = true;
            _emit(_session.copyWith(
              repeatSettings: _session.repeatSettings.copyWith(
                currentRangeRepeat: currentRangeRep + 1,
                currentAyahRepeat: 1,
              ),
            ));

            if (_session.range.isSingleSurah) {
              final startTiming = _currentSurahTiming!.ayahTimings
                  .where((t) => t.ayah == _session.range.startAyah)
                  .firstOrNull;
              final startPos = startTiming != null
                  ? Duration(milliseconds: startTiming.startTimeMs)
                  : Duration.zero;
              _playerService.seek(startPos).whenComplete(() {
                _isSeekingForRepeat = false;
              });
            } else {
              _loadAndPlaySurah(
                surahNumber: _session.range.startSurah,
                startAyah: _session.range.startAyah,
                range: _session.range,
                repeatSettings: _session.repeatSettings,
              ).whenComplete(() {
                _isSeekingForRepeat = false;
              });
            }
            return;
          } else {
            // Range completed!
            _playerService.pause();
            _emit(_session.copyWith(status: PlaybackStatus.completed));
            return;
          }
        }
      }
    }

    // Reset currentAyahRepeat if we transitioned to a new verse naturally
    RepeatSettings updatedRepeat = _session.repeatSettings;
    if (detectedAyah != null &&
        detectedAyah != _session.currentAyah &&
        updatedRepeat.currentAyahRepeat > 1) {
      updatedRepeat = updatedRepeat.copyWith(currentAyahRepeat: 1);
    }

    _emit(_session.copyWith(
      position: position,
      currentAyah: () => activeAyah,
      repeatSettings: updatedRepeat,
    ));
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null) {
      _emit(_session.copyWith(duration: duration));
    }
  }

  void _onBufferedChanged(Duration buffered) {
    _emit(_session.copyWith(bufferedPosition: buffered));
  }

  void _onEngineStatusChanged(AudioEngineStatus engineStatus) {
    switch (engineStatus) {
      case AudioEngineStatus.buffering:
        _emit(_session.copyWith(isBuffering: true));
        break;
      case AudioEngineStatus.loading:
        _emit(_session.copyWith(
          status: PlaybackStatus.loading,
          isBuffering: true,
        ));
        break;
      case AudioEngineStatus.playing:
        _emit(_session.copyWith(
          status: PlaybackStatus.playing,
          isBuffering: false,
        ));
        break;
      case AudioEngineStatus.paused:
        // Do not overwrite completed or failure with paused
        if (_session.status != PlaybackStatus.completed &&
            _session.status != PlaybackStatus.failure) {
          _emit(_session.copyWith(
            status: PlaybackStatus.paused,
            isBuffering: false,
          ));
        }
        break;
      case AudioEngineStatus.completed:
        _onTrackCompleted();
        break;
      case AudioEngineStatus.idle:
      case AudioEngineStatus.ready:
        _emit(_session.copyWith(isBuffering: false));
        break;
    }
  }

  void _onInterruptionChanged(AudioEngineInterruption interruption) {
    switch (interruption.kind) {
      case AudioInterruptionKind.pause:
        pause();
        break;
      case AudioInterruptionKind.duck:
        break;
      case AudioInterruptionKind.resume:
        if (_session.status == PlaybackStatus.paused) {
          resume();
        }
        break;
    }
  }

  void _onTrackCompleted() {
    // If range spans into subsequent surahs
    if (_session.surahNumber < _session.range.endSurah) {
      final nextSurah = _session.surahNumber + 1;
      _loadAndPlaySurah(
        surahNumber: nextSurah,
        startAyah: 1,
        range: _session.range,
        repeatSettings: _session.repeatSettings,
      );
      return;
    }

    // Range completed check
    final repeatRange = _session.repeatSettings.repeatRange;
    final currentRangeRep = _session.repeatSettings.currentRangeRepeat;

    if (currentRangeRep < repeatRange) {
      _emit(_session.copyWith(
        repeatSettings: _session.repeatSettings.copyWith(
          currentRangeRepeat: currentRangeRep + 1,
          currentAyahRepeat: 1,
        ),
      ));
      _loadAndPlaySurah(
        surahNumber: _session.range.startSurah,
        startAyah: _session.range.startAyah,
        range: _session.range,
        repeatSettings: _session.repeatSettings,
      );
    } else {
      _emit(_session.copyWith(status: PlaybackStatus.completed));
    }
  }

  @override
  Future<void> pause() async {
    await _playerService.pause();
    _emit(_session.copyWith(status: PlaybackStatus.paused));
  }

  @override
  Future<void> resume() async {
    if (_session.status == PlaybackStatus.completed) {
      await playRange(
        range: _session.range,
        repeatSettings: _session.repeatSettings.copyWith(
          currentAyahRepeat: 1,
          currentRangeRepeat: 1,
        ),
      );
      return;
    }

    await _playerService.play();
    _emit(_session.copyWith(status: PlaybackStatus.playing));
  }

  @override
  Future<void> stop() async {
    await _playerService.stop();
    _emit(PlaybackSession.initial(
      reciter: _session.reciter,
      moshaf: _session.moshaf,
    ));
  }

  @override
  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
    _emit(_session.copyWith(position: position));
  }

  @override
  Future<void> seekToAyah(int ayahNumber) async {
    if (_currentSurahTiming != null && _currentSurahTiming!.hasTiming) {
      final timing = _currentSurahTiming!.ayahTimings
          .where((t) => t.ayah == ayahNumber)
          .firstOrNull;
      if (timing != null) {
        await seek(Duration(milliseconds: timing.startTimeMs));
        _emit(_session.copyWith(
          currentAyah: () => ayahNumber,
          repeatSettings: _session.repeatSettings.copyWith(currentAyahRepeat: 1),
        ));
      }
    }
  }

  @override
  Future<void> setRepeatSettings(RepeatSettings settings) async {
    _emit(_session.copyWith(repeatSettings: settings));
  }

  @override
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _bufferedSub?.cancel();
    await _statusSub?.cancel();
    await _interruptionSub?.cancel();
    await _completedSub?.cancel();
    await _sessionController.close();
    await _playerService.dispose();
  }
}

extension _IterableFirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
