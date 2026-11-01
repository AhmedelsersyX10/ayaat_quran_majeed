// ignore_for_file: unnecessary_null_comparison, avoid_print
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:ayaat_quran_majeed/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart';
import 'package:quran/reciters.dart';
part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';

class QuranPagePlayerBloc extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  QuranPagePlayerBloc() : super(QuranPagePlayerInitial()) {
    on<QuranPagePlayerEvent>((event, emit) async {
      if (event is PlayFromVerse) {
        final player = audioPlayer;

        try {
          // 🔹 Verify reciter
          final reciterMatch = reciters.firstWhere(
            (element) => element["identifier"] == event.reciterIdentifier,
            orElse: () => null,
          );
          if (reciterMatch == null) {
            Fluttertoast.showToast(msg: "Reciter not found");
            return;
          }

          // 🔹 Get audio URL for specific verse
          final verseUrl = getAudioURLByVerse(
            event.surahNumber,
            event.verse,
            event.reciterIdentifier,
          );

          print('🎧 Playing verse from URL: $verseUrl');

          // 🔹 Configure audio session
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());

          // 🔹 Handle playback
          player.playbackEventStream.listen(
            (event) {},
            onError: (Object e, StackTrace stackTrace) {
              print('❌ Playback error: $e');
              Fluttertoast.showToast(msg: "Playback error: $e");
            },
          );

          // 🔹 Load and play the verse audio directly from URL
          await player.setAudioSource(
            AudioSource.uri(
              Uri.parse(verseUrl),
              tag: MediaItem(
                id: event.suraName,
                album: reciterMatch["englishName"],
                title: "${getSurahNameArabic(event.surahNumber)} - Verse ${event.verse}",
                artUri: Uri.parse(
                  "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg",
                ),
              ),
            ),
          );

          await player.play();
          print("▶️ Now playing verse from URL");

          Fluttertoast.showToast(
            msg: "▶️ Playing ${event.suraName} - Verse ${event.verse}",
            toastLength: Toast.LENGTH_SHORT,
          );

          emit(QuranPagePlayerPlaying(
            player: player,
            audioPlayerStream: player.positionStream,
            suraNumber: event.surahNumber,
            reciter: reciterMatch,
            durations: [],
          ));
        } catch (e) {
          print("🔥 Error in PlayFromVerse: $e");
          Fluttertoast.showToast(msg: "Error: $e");
        }
      }

      // 🔹 Play full surah
      else if (event is PlayFullSurah) {
        final player = audioPlayer;

        try {
          // 🔹 Verify reciter
          final reciterMatch = reciters.firstWhere(
            (element) => element["identifier"] == event.reciterIdentifier,
            orElse: () => null,
          );
          if (reciterMatch == null) {
            Fluttertoast.showToast(msg: "Reciter not found");
            return;
          }

          // 🔹 Create playlist from all verses in the surah
          final verseCount = getVerseCount(event.surahNumber);
          List<AudioSource> playList = [];

          for (int verseNumber = 1; verseNumber <= verseCount; verseNumber++) {
            final verseUrl = getAudioURLByVerse(
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
                  title: "${getSurahNameArabic(event.surahNumber)} - Verse $verseNumber",
                  artUri: Uri.parse(
                    "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg",
                  ),
                ),
              ),
            );
          }

          print('🎧 Playing full surah from playlist with ${playList.length} verses');

          // 🔹 Configure audio session
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());

          // 🔹 Handle playback
          player.playbackEventStream.listen(
            (event) {},
            onError: (Object e, StackTrace stackTrace) {
              print('❌ Playback error: $e');
              Fluttertoast.showToast(msg: "Playback error: $e");
            },
          );

          // 🔹 Load and play the surah as a playlist
          await player.setAudioSource(
            ConcatenatingAudioSource(children: playList),
          );

          await player.play();
          print("▶️ Now playing full surah from playlist");

          Fluttertoast.showToast(
            msg: "▶️ Playing ${event.suraName}",
            toastLength: Toast.LENGTH_SHORT,
          );

          emit(QuranPagePlayerPlaying(
            player: player,
            audioPlayerStream: player.positionStream,
            suraNumber: event.surahNumber,
            reciter: reciterMatch,
            durations: [],
          ));
        } catch (e) {
          print("🔥 Error in PlayFullSurah: $e");
          Fluttertoast.showToast(msg: "Error: $e");
        }
      }

      // 🔹 Stop
      else if (event is StopPlaying) {
        if (audioPlayer != null) {
          await audioPlayer.stop();
          Fluttertoast.showToast(msg: "⏹ Playback stopped");
        }
        emit(QuranPagePlayerInitial());
      }

      // 🔹 Kill player
      else if (event is KillPlayerEvent) {
        if (audioPlayer != null) {
          await audioPlayer.stop();
          Fluttertoast.showToast(msg: "🛑 Player killed");
        }
        emit(QuranPagePlayerInitial());
      }
    });
  }
}
