import 'package:ayaat_quran_majeed/core/network/cancellation_token.dart';
import 'package:ayaat_quran_majeed/core/network/cancellation_token_dio_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppCancellationToken Tests', () {
    test('initial state has isCancelled false and null reason', () {
      final token = AppCancellationToken();
      expect(token.isCancelled, isFalse);
      expect(token.reason, isNull);
    });

    test('cancel marks token as cancelled and stores reason', () {
      final token = AppCancellationToken();
      token.cancel('User aborted');

      expect(token.isCancelled, isTrue);
      expect(token.reason, equals('User aborted'));
    });

    test('cancel is idempotent and preserves first reason', () {
      final token = AppCancellationToken();
      token.cancel('First reason');
      token.cancel('Second reason');

      expect(token.isCancelled, isTrue);
      expect(token.reason, equals('First reason'));
    });

    test('onCancel triggers listeners when cancelled', () {
      final token = AppCancellationToken();
      String? receivedReason;
      token.onCancel((reason) {
        receivedReason = reason;
      });

      expect(receivedReason, isNull);
      token.cancel('Operation stopped');
      expect(receivedReason, equals('Operation stopped'));
    });

    test('onCancel triggers immediately if already cancelled', () {
      final token = AppCancellationToken();
      token.cancel('Already done');

      String? receivedReason;
      token.onCancel((reason) {
        receivedReason = reason;
      });

      expect(receivedReason, equals('Already done'));
    });
  });

  group('AppCancellationTokenDioX Tests', () {
    test('toDioCancelToken returns null when token is null', () {
      const AppCancellationToken? token = null;
      expect(token.toDioCancelToken(), isNull);
    });

    test(
      'toDioCancelToken returns already-cancelled Dio token if AppCancellationToken is already cancelled',
      () {
        final token = AppCancellationToken()..cancel('Immediate');
        final dioToken = token.toDioCancelToken();

        expect(dioToken, isNotNull);
        expect(dioToken!.isCancelled, isTrue);
      },
    );

    test(
      'toDioCancelToken cancels Dio token when AppCancellationToken is cancelled subsequently',
      () {
        final token = AppCancellationToken();
        final dioToken = token.toDioCancelToken();

        expect(dioToken, isNotNull);
        expect(dioToken!.isCancelled, isFalse);

        token.cancel('Later');
        expect(dioToken.isCancelled, isTrue);
      },
    );
  });
}
