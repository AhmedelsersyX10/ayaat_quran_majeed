import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiClient extends ApiClient {
  dynamic getResponseData;
  Exception? getException;
  String? lastGetPath;
  Map<String, dynamic>? lastQueryParams;

  String? lastDownloadUrl;
  dynamic lastDownloadSavePath;
  Exception? downloadException;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastGetPath = path;
    lastQueryParams = queryParameters;

    if (getException != null) {
      throw getException!;
    }

    return Response<T>(
      data: getResponseData as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    lastDownloadUrl = urlPath;
    lastDownloadSavePath = savePath;

    if (downloadException != null) {
      throw downloadException!;
    }

    return Response(
      statusCode: 200,
      requestOptions: RequestOptions(path: urlPath),
    );
  }
}

void main() {
  late FakeApiClient fakeApiClient;
  late AudioRemoteDataSource remoteDataSource;

  setUp(() {
    fakeApiClient = FakeApiClient();
    remoteDataSource = AudioRemoteDataSourceImpl(apiClient: fakeApiClient);
  });

  group('AudioRemoteDataSource Tests', () {
    test('getReciters succeeds with valid payload', () async {
      fakeApiClient.getResponseData = {
        'reciters': [
          {
            'id': 1,
            'name': 'المنشاوي',
            'letter': 'م',
            'moshaf': [
              {
                'id': 112,
                'name': 'مرتل',
                'server': 'https://server.com/',
                'surah_total': 114,
                'moshaf_type': 1,
                'surah_list': '1,2,3',
              }
            ]
          }
        ]
      };

      final result = await remoteDataSource.getReciters(language: 'ar');

      expect(fakeApiClient.lastGetPath, equals('https://www.mp3quran.net/api/v3/reciters'));
      expect(fakeApiClient.lastQueryParams, equals({'language': 'ar'}));
      expect(result.length, equals(1));
      expect(result.first.name, equals('المنشاوي'));
      expect(result.first.moshafs.first.id, equals(112));
    });

    test('getReciters throws ServerException on malformed data', () async {
      fakeApiClient.getResponseData = {'invalid_key': []};

      expect(
        () => remoteDataSource.getReciters(),
        throwsA(isA<ServerException>()),
      );
    });

    test('getTimingReads succeeds with valid array payload', () async {
      fakeApiClient.getResponseData = [
        {
          'id': 1,
          'name': 'إبراهيم الأخضر',
          'rewaya': 'حفص',
          'folder_url': 'https://server.com/',
          'soar_count': 114,
        }
      ];

      final result = await remoteDataSource.getTimingReads();

      expect(fakeApiClient.lastGetPath, equals('https://www.mp3quran.net/api/v3/ayat_timing/reads'));
      expect(result.length, equals(1));
      expect(result.first.id, equals(1));
    });

    test('getTimingSurahListForRead parses surah IDs list correctly', () async {
      fakeApiClient.getResponseData = [
        {'id': 1, 'name': 'الفاتحة'},
        {'id': 2, 'name': 'البقرة'},
        {'id': '3', 'name': 'آل عمران'},
      ];

      final result = await remoteDataSource.getTimingSurahListForRead(1);

      expect(fakeApiClient.lastGetPath, equals('https://www.mp3quran.net/api/v3/ayat_timing/soar'));
      expect(fakeApiClient.lastQueryParams, equals({'read': 1}));
      expect(result, equals([1, 2, 3]));
    });

    test('getAyahTiming parses timing items array', () async {
      fakeApiClient.getResponseData = [
        {'ayah': 1, 'start_time': 0, 'end_time': 5000},
        {'ayah': 2, 'start_time': 5000, 'end_time': 12000},
      ];

      final result = await remoteDataSource.getAyahTiming(surahNumber: 1, readId: 1);

      expect(fakeApiClient.lastGetPath, equals('https://www.mp3quran.net/api/v3/ayat_timing'));
      expect(fakeApiClient.lastQueryParams, equals({'surah': 1, 'read': 1}));
      expect(result.length, equals(2));
      expect(result.first.ayah, equals(1));
      expect(result.first.endTime, equals(5000));
    });

    test('getAyahTiming returns empty list when response is not a list', () async {
      fakeApiClient.getResponseData = {'error': 'not found'};

      final result = await remoteDataSource.getAyahTiming(surahNumber: 999, readId: 1);
      expect(result, isEmpty);
    });

    test('downloadSurahFile delegates to ApiClient.download', () async {
      await remoteDataSource.downloadSurahFile(
        url: 'https://server.com/001.mp3',
        savePath: '/local/001.mp3',
      );

      expect(fakeApiClient.lastDownloadUrl, equals('https://server.com/001.mp3'));
      expect(fakeApiClient.lastDownloadSavePath, equals('/local/001.mp3'));
    });
  });
}
