// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:ayaat_quran_majeed/main.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';

class QuranPagePlayerBloc
    extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  final QuranMetadataService _metadataService;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;

  QuranPagePlayerBloc({
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) : _metadataService = metadataService,
       super(QuranPagePlayerInitial()) {
    on<QuranPagePlayerEvent>((event, emit) async {
      if (event is PlayFromVerse) {
        final player = audioPlayer;

        try {
          // 🔹 Verify reciter
          final reciterMatch = _metadataService.getReciter(
            event.reciterIdentifier,
          );
          if (reciterMatch == null) {
            print("❌ Reciter not found: ${event.reciterIdentifier}");
            return;
          }

          // 🔹 Get audio URL for specific verse
          final verseUrl = _metadataService.getAudioURLByVerse(
            event.surahNumber,
            event.verse,
            event.reciterIdentifier,
          );

          print('🎧 Playing verse from URL: $verseUrl');

          // 🔹 Configure audio session
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());

          // 🔹 Handle playback
          await _playbackEventSubscription?.cancel();
          _playbackEventSubscription = player.playbackEventStream.listen(
            (event) {},
            onError: (Object e, StackTrace stackTrace) {
              print('❌ Playback error: $e');
            },
          );

          // 🔹 Load and play the verse audio directly from URL
          await player.setAudioSource(
            AudioSource.uri(
              Uri.parse(verseUrl),
              tag: MediaItem(
                id: event.suraName,
                album: reciterMatch["englishName"],
                title:
                    "${_metadataService.getSurahNameArabic(event.surahNumber)} - Verse ${event.verse}",
                artUri: Uri.parse(
                  "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg",
                ),
              ),
            ),
          );

          await player.play();
          print("▶️ Now playing verse from URL");

          emit(
            QuranPagePlayerPlaying(
              player: player,
              audioPlayerStream: player.positionStream,
              suraNumber: event.surahNumber,
              reciter: reciterMatch,
              durations: [],
            ),
          );
        } catch (e) {
          print("🔥 Error in PlayFromVerse: $e");
        }
      }
      // 🔹 Play full surah
      else if (event is PlayFullSurah) {
        final player = audioPlayer;

        try {
          // 🔹 Verify reciter
          final reciterMatch = _metadataService.getReciter(
            event.reciterIdentifier,
          );
          if (reciterMatch == null) {
            print("❌ Reciter not found: ${event.reciterIdentifier}");
            return;
          }

          // 🔹 Create playlist from all verses in the surah
          final verseCount = _metadataService.getVerseCount(event.surahNumber);
          List<AudioSource> playList = [];

          for (int verseNumber = 1; verseNumber <= verseCount; verseNumber++) {
            final verseUrl = _metadataService.getAudioURLByVerse(
              event.surahNumber,
              verseNumber,
              event.reciterIdentifier,
            );

            playList.add(
              AudioSource.uri(
                Uri.parse(verseUrl),
                tag: MediaItem(
                  id: '${event.surahNumber}-$verseNumber',
                  album: reciterMatch["englishName"],
                  title:
                      "${_metadataService.getSurahNameArabic(event.surahNumber)} - Verse $verseNumber",
                  artUri: Uri.parse(
                    "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg",
                  ),
                ),
              ),
            );
          }

          print(
            '🎧 Playing full surah from playlist with ${playList.length} verses',
          );

          // 🔹 Configure audio session
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());

          // 🔹 Handle playback
          await _playbackEventSubscription?.cancel();
          _playbackEventSubscription = player.playbackEventStream.listen(
            (event) {},
            onError: (Object e, StackTrace stackTrace) {
              print('❌ Playback error: $e');
            },
          );

          // 🔹 Load and play the surah as a playlist
          await player.setAudioSource(
            ConcatenatingAudioSource(children: playList),
          );

          await player.play();
          print("▶️ Now playing full surah from playlist");

          emit(
            QuranPagePlayerPlaying(
              player: player,
              audioPlayerStream: player.positionStream,
              suraNumber: event.surahNumber,
              reciter: reciterMatch,
              durations: [],
            ),
          );
        } catch (e) {
          print("🔥 Error in PlayFullSurah: $e");
        }
      }
      // 🔹 Stop
      else if (event is StopPlaying) {
        if (audioPlayer != null) {
          await audioPlayer.stop();
          print("⏹ Playback stopped");
        }
        emit(QuranPagePlayerInitial());
      }
      // 🔹 Kill player
      else if (event is KillPlayerEvent) {
        if (audioPlayer != null) {
          await audioPlayer.stop();
          print("🛑 Player killed");
        }
        emit(QuranPagePlayerInitial());
      }
      // 🔹 Play a cross-surah range of ayahs with optional repeat
      else if (event is PlayRangeWithRepeat) {
        final player = audioPlayer;

        try {
          // Verify reciter
          final reciterMatch = _metadataService.getReciter(
            event.reciterIdentifier,
          );
          if (reciterMatch == null) {
            print("❌ Reciter not found: ${event.reciterIdentifier}");
            return;
          }

          // ── Build the single-pass track list across surah boundaries ──────────
          List<AudioSource> rangeList = [];

          for (int s = event.startSurahNumber; s <= event.endSurahNumber; s++) {
            final firstVerse = (s == event.startSurahNumber)
                ? event.startVerse
                : 1;
            final lastVerse = (s == event.endSurahNumber)
                ? event.endVerse
                : _metadataService.getVerseCount(s);

            for (int v = firstVerse; v <= lastVerse; v++) {
              final url = _metadataService.getAudioURLByVerse(
                s,
                v,
                event.reciterIdentifier,
              );
              rangeList.add(
                AudioSource.uri(
                  Uri.parse(url),
                  tag: MediaItem(
                    id: '$s-$v',
                    album: reciterMatch["englishName"],
                    title:
                        "${_metadataService.getSurahNameArabic(s)} - Verse $v",
                    artUri: Uri.parse(
                      "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg",
                    ),
                  ),
                ),
              );
            }
          }

          // ── Build the full playlist with repeat logic ──────────────────────────
          final bool isInfinite = event.repeatCount == null;
          List<AudioSource> fullPlaylist;

          if (isInfinite) {
            fullPlaylist = rangeList;
          } else {
            fullPlaylist = [];
            final times = event.repeatCount!;
            for (int rep = 0; rep < times; rep++) {
              for (
                int s = event.startSurahNumber;
                s <= event.endSurahNumber;
                s++
              ) {
                final firstVerse = (s == event.startSurahNumber)
                    ? event.startVerse
                    : 1;
                final lastVerse = (s == event.endSurahNumber)
                    ? event.endVerse
                    : _metadataService.getVerseCount(s);

                for (int v = firstVerse; v <= lastVerse; v++) {
                  final url = _metadataService.getAudioURLByVerse(
                    s,
                    v,
                    event.reciterIdentifier,
                  );
                  fullPlaylist.add(
                    AudioSource.uri(
                      Uri.parse(url),
                      tag: MediaItem(
                        id: '$s-$v-rep$rep',
                        album: reciterMatch["englishName"],
                        title:
                            "${_metadataService.getSurahNameArabic(s)} - Verse $v",
                        artUri: Uri.parse(
                          "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg",
                        ),
                      ),
                    ),
                  );
                }
              }
            }
          }

          print(
            '🔁 PlayRangeWithRepeat: '
            '${event.startSurahNumber}:${event.startVerse} → '
            '${event.endSurahNumber}:${event.endVerse}, '
            'repeat=${event.repeatCount ?? "∞"}, tracks=${fullPlaylist.length}',
          );

          // Configure audio session
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());

          // Error listener
          await _playbackEventSubscription?.cancel();
          _playbackEventSubscription = player.playbackEventStream.listen(
            (event) {},
            onError: (Object e, StackTrace stackTrace) {
              print('❌ Playback error: $e');
            },
          );

          // Set loop mode
          await player.setLoopMode(isInfinite ? LoopMode.all : LoopMode.off);

          // Load and play
          await player.setAudioSource(
            ConcatenatingAudioSource(children: fullPlaylist),
          );
          await player.play();

          print("▶️ Now playing cross-surah range with repeat");

          emit(
            QuranPagePlayerPlaying(
              player: player,
              audioPlayerStream: player.positionStream,
              suraNumber: event.startSurahNumber,
              reciter: reciterMatch,
              durations: [],
            ),
          );
        } catch (e) {
          print("🔥 Error in PlayRangeWithRepeat: $e");
        }
      }
    });
  }

  @override
  Future<void> close() async {
    await _playbackEventSubscription?.cancel();
    _playbackEventSubscription = null;
    return super.close();
  }
}
