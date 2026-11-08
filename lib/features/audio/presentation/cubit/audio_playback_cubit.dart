import 'dart:async';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_session.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_playback_state.dart';

/// Cubit managing Quran audio recitation playback lifecycle, timing synchronization,
/// repetition rules, and UI player states (References 05, 22, 37, 40).
class AudioPlaybackCubit extends Cubit<AudioPlaybackState> {
  final PlaybackRepository _playbackRepository;
  StreamSubscription<PlaybackSession>? _sessionSubscription;

  AudioPlaybackCubit({
    required PlaybackRepository playbackRepository,
  })  : _playbackRepository = playbackRepository,
        super(AudioPlaybackIdle(playbackRepository.currentSession)) {
    _sessionSubscription = _playbackRepository.sessionStream.listen(_onSessionEmitted);
  }

  void _onSessionEmitted(PlaybackSession session) {
    switch (session.status) {
      case PlaybackStatus.idle:
        emit(AudioPlaybackIdle(session));
        break;
      case PlaybackStatus.loading:
        emit(AudioPlaybackLoading(session));
        break;
      case PlaybackStatus.playing:
        emit(AudioPlaybackPlaying(session));
        break;
      case PlaybackStatus.paused:
        emit(AudioPlaybackPaused(session));
        break;
      case PlaybackStatus.completed:
        emit(AudioPlaybackCompleted(session));
        break;
      case PlaybackStatus.failure:
        emit(AudioPlaybackFailure(
          session,
          session.errorMessage ?? 'Audio playback encountered an error',
        ));
        break;
    }
  }

  /// Starts playback of a specific ayah.
  Future<void> playAyah(
    int surahNumber,
    int ayahNumber, {
    RepeatSettings? repeatSettings,
  }) async {
    await _playbackRepository.playAyah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      repeatSettings: repeatSettings,
    );
  }

  /// Starts playback of a surah from [startAyah] to the end.
  Future<void> playSurah(
    int surahNumber, {
    int startAyah = 1,
    RepeatSettings? repeatSettings,
  }) async {
    await _playbackRepository.playSurah(
      surahNumber: surahNumber,
      startAyah: startAyah,
      repeatSettings: repeatSettings,
    );
  }

  /// Starts playback over an explicit [range] (Reference 22).
  Future<void> playRange(
    PlaybackRange range, {
    RepeatSettings? repeatSettings,
  }) async {
    await _playbackRepository.playRange(
      range: range,
      repeatSettings: repeatSettings,
    );
  }

  /// Updates the active playback range endpoint dynamically (Reference 22).
  Future<void> updateRange(PlaybackRange range) async {
    await _playbackRepository.updateRange(range);
  }

  /// Sets or starts playback ending at [endSurah]:[endAyah].
  Future<void> playToAyah({
    required int startSurah,
    required int startAyah,
    required int endSurah,
    required int endAyah,
    RepeatSettings? repeatSettings,
  }) async {
    final range = PlaybackRange(
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: endSurah,
      endAyah: endAyah,
    );

    if (state.isActive && state.surahNumber == startSurah) {
      await updateRange(range);
    } else {
      await playRange(range, repeatSettings: repeatSettings);
    }
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _playbackRepository.pause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    await _playbackRepository.resume();
  }

  /// Stops recitation and resets player to idle.
  Future<void> stop() async {
    await _playbackRepository.stop();
  }

  /// Seeks to a specific [position] within the current track.
  Future<void> seek(Duration position) async {
    await _playbackRepository.seek(position);
  }

  /// Seeks directly to the start timestamp of [ayahNumber].
  Future<void> seekToAyah(int ayahNumber) async {
    await _playbackRepository.seekToAyah(ayahNumber);
  }

  /// Skips to the next ayah in recitation.
  Future<void> skipNextAyah() async {
    final curr = state.currentAyah;
    if (curr != null) {
      await _playbackRepository.seekToAyah(curr + 1);
    }
  }

  /// Skips to the previous ayah in recitation.
  Future<void> skipPreviousAyah() async {
    final curr = state.currentAyah;
    if (curr != null && curr > 1) {
      await _playbackRepository.seekToAyah(curr - 1);
    } else if (curr != null) {
      await _playbackRepository.seekToAyah(1);
    }
  }

  /// Updates repeat settings dynamically (Reference 40).
  Future<void> setRepeatSettings(RepeatSettings settings) async {
    await _playbackRepository.setRepeatSettings(settings);
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}

