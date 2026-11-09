import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiClient extends ApiClient {
  String? lastDownloadUrl;
  dynamic lastDownloadSavePath;
  Exception? downloadException;
  bool createFileOnDownload = true;

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

    if (onReceiveProgress != null) {
      onReceiveProgress(500, 1000);
      onReceiveProgress(1000, 1000);
    }

    if (createFileOnDownload && savePath is String) {
      final file = File(savePath);
      await file.writeAsString('[{"id": 1, "sura": 1, "aya": 1, "text": "test"}]');
    }

    return Response(
      statusCode: 200,
      requestOptions: RequestOptions(path: urlPath),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeApiClient fakeApiClient;
  late Directory tempDir;
  late TafsirRemoteDataSourceImpl remoteDataSource;

  setUp(() async {
    fakeApiClient = FakeApiClient();
    tempDir = await Directory.systemTemp.createTemp('tafsir_remote_test_');
    remoteDataSource = TafsirRemoteDataSourceImpl(
      apiClient: fakeApiClient,
      customTempDirectory: () async => tempDir,
    );
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('TafsirRemoteDataSource Tests', () {
    test('throws TafsirNotFoundException if bookId is not in catalog', () async {
      expect(
        () => remoteDataSource.downloadBookFile(
          bookId: 'unknown_book',
          url: 'https://example.com/unknown.json',
        ),
        throwsA(isA<TafsirNotFoundException>()),
      );
    });

    test('throws TafsirDownloadException if attempting to download bundled book', () async {
      expect(
        () => remoteDataSource.downloadBookFile(
          bookId: 'ar_muyassar',
          url: 'https://example.com/muyassar.json',
        ),
        throwsA(isA<TafsirDownloadException>()),
      );
    });

    test('successfully downloads book and reports progress callbacks', () async {
      final progressUpdates = <int>[];

      final tempPath = await remoteDataSource.downloadBookFile(
        bookId: 'sa3dy',
        url: 'https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/sa3dy.json',
        onProgress: (received, total) {
          progressUpdates.add(received);
        },
      );

      expect(tempPath, isNotEmpty);
      expect(File(tempPath).existsSync(), isTrue);
      expect(fakeApiClient.lastDownloadUrl, contains('sa3dy.json'));
      expect(progressUpdates, containsAllInOrder([500, 1000]));
    });

    test('throws TafsirDownloadException when download fails or file is empty', () async {
      fakeApiClient.createFileOnDownload = false; // simulates empty/missing downloaded file

      expect(
        () => remoteDataSource.downloadBookFile(
          bookId: 'katheer',
          url: 'https://example.com/katheer.json',
        ),
        throwsA(isA<TafsirDownloadException>()),
      );
    });

    test('handles DioException cancellation and sets DOWNLOAD_CANCELLED code', () async {
      fakeApiClient.downloadException = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: 'test'),
        message: 'Request cancelled',
      );

      expect(
        () => remoteDataSource.downloadBookFile(
          bookId: 'baghawy',
          url: 'https://example.com/baghawy.json',
        ),
        throwsA(
          isA<TafsirDownloadException>().having(
            (e) => e.code,
            'code',
            equals('DOWNLOAD_CANCELLED'),
          ),
        ),
      );
    });
  });
}

