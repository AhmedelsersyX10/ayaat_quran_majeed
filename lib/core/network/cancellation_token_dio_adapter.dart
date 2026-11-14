import 'package:dio/dio.dart';
import 'cancellation_token.dart';

/// Extension to adapt pure [AppCancellationToken] to Dio's [CancelToken].
/// Used strictly in the data / network layer.
extension AppCancellationTokenDioX on AppCancellationToken? {
  CancelToken? toDioCancelToken() {
    if (this == null) return null;
    final dioToken = CancelToken();
    if (this!.isCancelled) {
      dioToken.cancel(this!.reason);
    } else {
      this!.onCancel((reason) {
        if (!dioToken.isCancelled) {
          dioToken.cancel(reason);
        }
      });
    }
    return dioToken;
  }
}
