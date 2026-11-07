import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:dio/dio.dart';

import '../models/ayah_timing_model.dart';
import '../models/reciter_model.dart';
import '../models/timing_read_model.dart';

/// Contract for remote audio, reciters, and timing operations from mp3quran.net API v3.
abstract class AudioRemoteDataSource {
  /// Fetches all reciters and their moshaf editions.
  Future<List<ReciterModel>> getReciters({String language = 'ar'});

  /// Fetches the list of moshafs with verified ayah-level timing.
  Future<List<TimingReadModel>> getTimingReads();

  /// Fetches the list of surah numbers (1 to 114) that have timing data for [readId].
  Future<List<int>> getTimingSurahListForRead(int readId);

  /// Fetches ayah-level timing entries for [surahNumber] in moshaf [readId].
  Future<List<AyahTimingModel>> getAyahTiming({
    required int surahNumber,
    required int readId,
  });

  /// Downloads a surah audio file from [url] to local [savePath].
  Future<void> downloadSurahFile({
    required String url,
    required String savePath,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  });
}

/// Implementation of [AudioRemoteDataSource] using centralized [ApiClient].
class AudioRemoteDataSourceImpl implements AudioRemoteDataSource {
  static const String _baseUrl = 'https://www.mp3quran.net/api/v3';

  final ApiClient _apiClient;

  const AudioRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ReciterModel>> getReciters({String language = 'ar'}) async {
    final response = await _apiClient.get(
      '$_baseUrl/reciters',
      queryParameters: {'language': language},
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['reciters'] is List) {
      final list = data['reciters'] as List<dynamic>;
      return list
          .map((item) => ReciterModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw const ServerException(
      'Invalid reciters response format',
      'INVALID_RESPONSE_FORMAT',
    );
  }

  @override
  Future<List<TimingReadModel>> getTimingReads() async {
    final response = await _apiClient.get('$_baseUrl/ayat_timing/reads');

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => TimingReadModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw const ServerException(
      'Invalid timing reads response format',
      'INVALID_RESPONSE_FORMAT',
    );
  }

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async {
    final response = await _apiClient.get(
      '$_baseUrl/ayat_timing/soar',
      queryParameters: {'read': readId},
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) {
            if (item is Map<String, dynamic>) {
              final id = item['id'];
              if (id is int) return id;
              if (id is String) return int.tryParse(id);
            }
            return null;
          })
          .whereType<int>()
          .toList();
    }

    throw const ServerException(
      'Invalid timing soar response format',
      'INVALID_RESPONSE_FORMAT',
    );
  }

  @override
  Future<List<AyahTimingModel>> getAyahTiming({
    required int surahNumber,
    required int readId,
  }) async {
    final response = await _apiClient.get(
      '$_baseUrl/ayat_timing',
      queryParameters: {
        'surah': surahNumber,
        'read': readId,
      },
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => AyahTimingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return const [];
  }

  @override
  Future<void> downloadSurahFile({
    required String url,
    required String savePath,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    await _apiClient.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}
