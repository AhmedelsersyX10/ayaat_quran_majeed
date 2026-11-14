import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:ayaat_quran_majeed/core/network/cancellation_token.dart';
import 'package:ayaat_quran_majeed/core/network/cancellation_token_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/tafsir_catalog.dart';

/// Contract for downloading remote Tafsir datasets from verified endpoints.
abstract class TafsirRemoteDataSource {
  /// Downloads the book's JSON dataset from [url] into a temporary file.
  ///
  /// Reports download progress via [onProgress].
  /// Supports cancellation via [cancelToken].
  /// Returns the absolute path of the downloaded temporary file.
  Future<String> downloadBookFile({
    required String bookId,
    required String url,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  });
}

/// Implementation of [TafsirRemoteDataSource] using centralized [ApiClient].
class TafsirRemoteDataSourceImpl implements TafsirRemoteDataSource {
  final ApiClient _apiClient;
  final Future<Directory> Function()? _customTempDirectory;

  const TafsirRemoteDataSourceImpl({
    required ApiClient apiClient,
    Future<Directory> Function()? customTempDirectory,
  }) : _apiClient = apiClient,
       _customTempDirectory = customTempDirectory;

  @override
  Future<String> downloadBookFile({
    required String bookId,
    required String url,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    final bookModel = TafsirCatalog.findById(bookId);
    if (bookModel == null) {
      throw TafsirNotFoundException('Book $bookId not found in catalog');
    }

    if (bookModel.isBundled) {
      throw const TafsirDownloadException(
        'Bundled books do not require remote downloading',
      );
    }

    final tempDir = _customTempDirectory != null
        ? await _customTempDirectory()
        : await getTemporaryDirectory();

    final tempFilePath =
        '${tempDir.path}/tafsir_download_${bookId}_${DateTime.now().millisecondsSinceEpoch}.tmp';

    try {
      CancelToken? dioCancelToken;
      if (cancelToken is AppCancellationToken) {
        dioCancelToken = cancelToken.toDioCancelToken();
      } else if (cancelToken is CancelToken) {
        dioCancelToken = cancelToken;
      }

      await _apiClient.download(
        url,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null) {
            onProgress(received, total);
          }
        },
        cancelToken: dioCancelToken,
      );

      final downloadedFile = File(tempFilePath);
      if (!await downloadedFile.exists() ||
          await downloadedFile.length() == 0) {
        throw const TafsirDownloadException(
          'Downloaded file is empty or missing',
        );
      }

      return tempFilePath;
    } on DioException catch (e) {
      // Clean up orphaned temp file if download aborted
      try {
        final orphaned = File(tempFilePath);
        if (await orphaned.exists()) {
          await orphaned.delete();
        }
      } catch (_) {}

      if (CancelToken.isCancel(e)) {
        throw const TafsirDownloadException(
          'Download cancelled by user',
          'DOWNLOAD_CANCELLED',
        );
      }
      throw TafsirDownloadException(
        'Network download failed: ${e.message}',
        e.type.name,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw TafsirDownloadException('Unexpected download error: $e');
    }
  }
}
