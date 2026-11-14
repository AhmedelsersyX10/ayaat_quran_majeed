/// Pure Dart cancellation token to decouple domain and presentation layers.
class AppCancellationToken {
  bool _isCancelled = false;
  String? _reason;
  final List<void Function(String? reason)> _listeners = [];

  bool get isCancelled => _isCancelled;
  String? get reason => _reason;

  /// Cancels the token and invokes registered listeners.
  void cancel([String? reason]) {
    if (_isCancelled) return;
    _isCancelled = true;
    _reason = reason;
    for (final listener in List.of(_listeners)) {
      listener(reason);
    }
    _listeners.clear();
  }

  /// Registers a callback to be called when cancelled.
  /// If already cancelled, the callback is invoked immediately.
  void onCancel(void Function(String? reason) callback) {
    if (_isCancelled) {
      callback(_reason);
    } else {
      _listeners.add(callback);
    }
  }
}
