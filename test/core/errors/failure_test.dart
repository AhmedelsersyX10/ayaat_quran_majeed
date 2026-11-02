import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure Domain Contracts Tests', () {
    test('ServerFailure holds default and custom messages and codes', () {
      const defaultFailure = ServerFailure();
      expect(defaultFailure.message, equals('حدث خطأ في الاتصال بالخادم'));
      expect(defaultFailure.code, isNull);

      const customFailure = ServerFailure('خطأ مخصص', '500');
      expect(customFailure.message, equals('خطأ مخصص'));
      expect(customFailure.code, equals('500'));
      expect(customFailure.toString(), contains('ServerFailure'));
    });

    test('CacheFailure supports equality and hashCode comparison', () {
      const failure1 = CacheFailure('تعذر الحفظ', 'CACHE_ERR');
      const failure2 = CacheFailure('تعذر الحفظ', 'CACHE_ERR');
      const failure3 = CacheFailure('خطأ آخر', 'CACHE_ERR');

      expect(failure1, equals(failure2));
      expect(failure1.hashCode, equals(failure2.hashCode));
      expect(failure1, isNot(equals(failure3)));
    });

    test('GeneralFailure defaults and equality operate properly', () {
      const general1 = GeneralFailure();
      const general2 = GeneralFailure();
      expect(general1, equals(general2));
      expect(general1.message, equals('حدث خطأ غير متوقع'));
    });
  });

  group('Exceptions Data Layer Contracts Tests', () {
    test('ServerException holds message, code, and statusCode', () {
      const exception = ServerException('API down', 'TIMEOUT', 503);
      expect(exception.message, equals('API down'));
      expect(exception.code, equals('TIMEOUT'));
      expect(exception.statusCode, equals(503));
      expect(exception.toString(), contains('ServerException'));
    });

    test('CacheException and NetworkException string representations', () {
      const cacheEx = CacheException('Disk full');
      const networkEx = NetworkException('No connection');

      expect(cacheEx.toString(), contains('CacheException'));
      expect(networkEx.toString(), contains('NetworkException'));
    });
  });
}

