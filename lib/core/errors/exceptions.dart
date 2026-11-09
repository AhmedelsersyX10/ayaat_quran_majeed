/// Base interface for data-layer exceptions.
/// Pure Dart — no Flutter framework dependencies.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Thrown when remote API request fails or returns non-2xx status.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException([
    String message = 'Server communication error',
    String? code,
    this.statusCode,
  ]) : super(message, code: code);
}

/// Thrown when local cache read/write operation fails.
class CacheException extends AppException {
  const CacheException([
    String message = 'Local storage cache error',
    String? code,
  ]) : super(message, code: code);
}

/// Thrown when a network connection is unavailable or times out.
class NetworkException extends AppException {
  const NetworkException([
    String message = 'Network connection unavailable or timed out',
    String? code,
  ]) : super(message, code: code);
}

/// Thrown when a requested Tafsir or translation book/verse is not found.
class TafsirNotFoundException extends AppException {
  const TafsirNotFoundException([
    String message = 'Tafsir book or verse not found',
    String? code,
  ]) : super(message, code: code);
}

/// Thrown when downloading a Tafsir dataset fails.
class TafsirDownloadException extends AppException {
  const TafsirDownloadException([
    String message = 'Failed to download Tafsir dataset',
    String? code,
  ]) : super(message, code: code);
}

/// Thrown when Tafsir JSON or binary data is malformed or corrupted.
class TafsirCorruptedDataException extends AppException {
  const TafsirCorruptedDataException([
    String message = 'Tafsir dataset is corrupted or unreadable',
    String? code,
  ]) : super(message, code: code);
}

