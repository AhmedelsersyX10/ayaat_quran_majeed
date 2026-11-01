part of 'quran_page_player_bloc.dart';

class QuranPagePlayerEvent {}

class PlayFromVerse extends QuranPagePlayerEvent {
  final int verse;
  final String reciterIdentifier;
  final int surahNumber;
  final String suraName;

  PlayFromVerse(this.verse, this.reciterIdentifier, this.surahNumber, this.suraName);
}

class PlayFullSurah extends QuranPagePlayerEvent {
  final String reciterIdentifier;
  final int surahNumber;
  final String suraName;

  PlayFullSurah(this.reciterIdentifier, this.surahNumber, this.suraName);
}

class PausePlaying extends QuranPagePlayerEvent {}

class StopPlaying extends QuranPagePlayerEvent {}

class KillPlayerEvent extends QuranPagePlayerEvent {}

/// Plays a range of ayahs from [startSurahNumber]:[startVerse] to
/// [endSurahNumber]:[endVerse] (inclusive), crossing surah boundaries.
/// Repeated [repeatCount] times (null = infinite loop).
class PlayRangeWithRepeat extends QuranPagePlayerEvent {
  /// Starting surah (1-based).
  final int startSurahNumber;

  /// Starting ayah within [startSurahNumber].
  final int startVerse;

  /// Ending surah (1-based). May equal [startSurahNumber].
  final int endSurahNumber;

  /// Ending ayah within [endSurahNumber].
  final int endVerse;

  /// Reciter identifier string.
  final String reciterIdentifier;

  /// Number of times to repeat the full range.
  /// Pass `null` for infinite looping until manually stopped.
  final int? repeatCount;

  PlayRangeWithRepeat({
    required this.startSurahNumber,
    required this.startVerse,
    required this.endSurahNumber,
    required this.endVerse,
    required this.reciterIdentifier,
    required this.repeatCount,
  });
}
