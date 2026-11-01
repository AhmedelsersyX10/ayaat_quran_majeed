import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:ayaat_quran_majeed/cubit/bloc/player_bar_bloc.dart';
import 'package:ayaat_quran_majeed/cubit/models/reciter.dart';
import 'package:ayaat_quran_majeed/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:quran/quran.dart';

part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

final playerbarBloc = PlayerBarBloc();

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  PlayerBlocBloc() : super(PlayerBlocInitial()) {
    on<PlayerBlocEvent>((event, emit) async {
      if (event is StartPlaying) {
        audioPlayer.stop();
        int nextMediaId = 0;
        List<String> surahNumbers = event.moshaf.surahList.split(',');

        // 🧱 دالة لتجهيز مجلد التطبيق الآمن
        Future<Directory> getAppDirectory() async {
          final dir = await getExternalStorageDirectory();
          final appDir = Directory('${dir!.path}/ayaat');
          if (!(await appDir.exists())) {
            await appDir.create(recursive: true);
          }
          return appDir;
        }

        final appDir = await getAppDirectory();
        print('✅ Using app directory, no permissions required');

        // إعداد روابط التشغيل
        List reciterLinks = surahNumbers.map((e) {
          final localPath =
              '${appDir.path}/${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(e))}.mp3';
          if (File(localPath).existsSync()) {
            return {
              'link': Uri.file(localPath),
              'suraNumber': e,
            };
          } else {
            return {
              'link': Uri.parse("${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3")
                  .replace(scheme: 'https'),
              'suraNumber': e,
            };
          }
        }).toList();
        var playList = reciterLinks.map((e) {
          return AudioSource.uri(
            e['link'],
            tag: MediaItem(
              id: '${nextMediaId++}',
              album: event.reciter.name,
              title: event.jsonData
                  .firstWhere((element) => element['id'].toString() == e['suraNumber'].toString(),
                      orElse: () => {'name': 'غير معروف'})['name']
                  .toString(),
              artUri: Uri.parse(
                  'https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
            ),
          );
        }).toList();

        String currentSuraNumber = '';
        if (event.suraNumber == -1) {
          currentSuraNumber = surahNumbers[0];
        }

        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());

        audioPlayer.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });

        audioPlayer.setLoopMode(LoopMode.off);

        try {
          await audioPlayer.setAudioSource(
            ConcatenatingAudioSource(children: playList),
            initialIndex: event.initialIndex,
          );
        } catch (e) {
          print('Error loading playlist: $e');
        }

        audioPlayer.play();

        playerbarBloc.add(ShowBarEvent());
        emit(PlayerBlocPlaying(
          moshaf: event.moshaf,
          reciter: event.reciter,
          suraNumber: event.suraNumber == -1 ? int.parse(currentSuraNumber) : event.suraNumber,
          jsonData: event.jsonData,
          audioPlayer: audioPlayer,
          surahNumbers: surahNumbers,
          playList: playList,
        ));
      }

      // 🎵 تحميل سورة واحدة
      else if (event is DownloadSurah) {
        final dio = Dio();

        final appDir = await getExternalStorageDirectory();
        final safeDir = Directory('${appDir!.path}/ayaat');
        if (!(await safeDir.exists())) {
          await safeDir.create(recursive: true);
        }


        final fullSuraFilePath =
            '${safeDir.path}/${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(event.suraNumber))}.mp3';

        if (File(fullSuraFilePath).existsSync()) {
          print('✅ Full sura already exists: $fullSuraFilePath');
        } else {
          try {
            print('⬇️ Starting download to: $fullSuraFilePath');
            await dio.download(event.url, fullSuraFilePath);
            print('✅ Download completed: $fullSuraFilePath');
          } catch (e) {
            print('❌ Download failed: $e');
          }
        }
      }

      // 📥 تحميل جميع السور
      else if (event is DownloadAllSurahs) {
        final dio = Dio();
        final appDir = await getExternalStorageDirectory();
        final safeDir = Directory('${appDir!.path}/ayaat');
        if (!(await safeDir.exists())) {
          await safeDir.create(recursive: true);
        }

        print('✅ Using app directory, no permissions required');

        List<String> surahNumbers = event.moshaf.surahList.split(',');

        for (var e in surahNumbers) {
          final fullPath =
              '${safeDir.path}/${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(e))}.mp3';

          if (File(fullPath).existsSync()) {
            print('✅ Already exists: $fullPath');
          } else {
            try {
              final url = "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3";
              print('⬇️ Downloading $url');
              await dio.download(url, fullPath);
              print('✅ Downloaded $fullPath');
            } catch (e) {
              print('❌ Error downloading $e');
            }
          }
        }
      }
      // 🎧 إغلاق المشغّل
      else if (event is ClosePlayerEvent) {
        audioPlayer.dispose();
        emit(PlayerBlocInitial());
      }

      // ⏸️ إيقاف مؤقت
      else if (event is PausePlayer) {
        try {
          if (audioPlayer.playing) {
            await audioPlayer.pause();
            print("⏸️ Playback paused");
            emit(PlayerBlocPaused());
          } else {
            await audioPlayer.play();
            print("▶️ Playback resumed");

            // تأكد إن الحالة الحالية فيها بيانات التشغيل
            if (state is PlayerBlocPlaying) {
              final current = state as PlayerBlocPlaying;
              emit(PlayerBlocPlaying(
                moshaf: current.moshaf,
                reciter: current.reciter,
                suraNumber: current.suraNumber,
                jsonData: current.jsonData,
                audioPlayer: audioPlayer,
                surahNumbers: current.surahNumbers,
                playList: current.playList,
              ));
            }
          }
        } catch (e) {
          print("⚠️ Error while pausing/resuming: $e");
        }
      }
    });
  }
}
