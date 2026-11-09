/// Base class for domain-level failures across the application.
/// Pure Dart — no Flutter framework dependencies.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, code);

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Represents failures originating from remote network operations or APIs.
class ServerFailure extends Failure {
  const ServerFailure([String message = 'حدث خطأ في الاتصال بالخادم', String? code])
      : super(message, code: code);
}

/// Represents failures originating from local storage/cache (e.g. Hive, SharedPreferences).
class CacheFailure extends Failure {
  const CacheFailure([String message = 'حدث خطأ أثناء الوصول للبيانات المخزنة', String? code])
      : super(message, code: code);
}

/// Represents general unexpected application failures.
class GeneralFailure extends Failure {
  const GeneralFailure([String message = 'حدث خطأ غير متوقع', String? code])
      : super(message, code: code);
}

/// Represents failure when a requested Tafsir book or verse is not found.
class TafsirNotFoundFailure extends Failure {
  const TafsirNotFoundFailure([
    String message = 'كتاب التفسير أو الآية المطلوبة غير متوفرة',
    String? code,
  ]) : super(message, code: code);
}

/// Represents failure when downloading a Tafsir dataset fails.
class TafsirDownloadFailure extends Failure {
  const TafsirDownloadFailure([
    String message = 'فشل تنزيل كتاب التفسير من الخادم',
    String? code,
  ]) : super(message, code: code);
}

/// Represents failure when Tafsir dataset is corrupted.
class TafsirCorruptedDataFailure extends Failure {
  const TafsirCorruptedDataFailure([
    String message = 'بيانات التفسير تالفة أو غير صالحة للقراءة',
    String? code,
  ]) : super(message, code: code);
}

