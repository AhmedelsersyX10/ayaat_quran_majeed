import 'package:dio/dio.dart';

import '../models/reciter.dart';

abstract class AudioPlayerRemoteDataSource {
  Future<List<ReciterModel>> getReciters(String locale);
  Future<List<dynamic>> getSurahs(String locale);
  Future<void> downloadSurah(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  });
}

class AudioPlayerRemoteDataSourceImpl implements AudioPlayerRemoteDataSource {
  final Dio dio;

  AudioPlayerRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReciterModel>> getReciters(String locale) async {
    final response = await dio.get('https://www.mp3quran.net/api/v3/reciters?language=$locale');
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> recitersData = response.data['reciters'];
      return recitersData.map((json) => ReciterModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reciters');
    }
  }

  @override
  Future<List<dynamic>> getSurahs(String locale) async {
    final response = await dio.get('https://www.mp3quran.net/api/v3/suwar?language=$locale');
    if (response.statusCode == 200 && response.data != null) {
      return response.data['suwar'] as List<dynamic>;
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  @override
  Future<void> downloadSurah(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    await dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
