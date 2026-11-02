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

