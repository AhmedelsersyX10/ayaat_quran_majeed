import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// Centralized Dio API client for remote networking.
/// Configures unified timeouts, headers, and consistent error mapping.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// Performs GET request with mapped error handling.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Downloads file from [urlPath] to [savePath] with mapped error handling.
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          'فشل الاتصال بالشبكة أو انتهت المهلة: ${error.message}',
          error.type.name,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ServerException(
          'استجابة غير صالحة من الخادم ($statusCode)',
          error.type.name,
          statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('تم إلغاء الطلب', 'REQUEST_CANCELLED');
      case DioExceptionType.badCertificate:
        return const NetworkException('شهادة أمان غير صالحة', 'BAD_CERTIFICATE');
      case DioExceptionType.unknown:
      default:
        return ServerException(
          error.message ?? 'حدث خطأ غير معروف في الاتصال',
          'UNKNOWN_NETWORK_ERROR',
        );
    }
  }
}

