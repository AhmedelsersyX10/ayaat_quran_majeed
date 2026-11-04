import 'package:flutter/foundation.dart';

/// Lightweight, transient presentation controller managing Quran reader chrome visibility.
///
/// Owned and disposed by `QuranDetailsPageState`. Uses [ValueNotifier] to establish
/// narrow rebuild boundaries via `ValueListenableBuilder` so that toggling chrome
/// does not trigger expensive rebuilds of the Mushaf content.
class ReaderChromeController extends ValueNotifier<bool> {
  ReaderChromeController({bool initialVisibility = true})
    : super(initialVisibility);

  /// Whether reader chrome (toolbar and slider) is currently visible.
  bool get isVisible => value;

  /// Shows the chrome idempotently.
  void show() {
    if (!value) {
      value = true;
    }
  }

  /// Hides the chrome idempotently.
  void hide() {
    if (value) {
      value = false;
    }
  }

  /// Toggles chrome visibility.
  void toggle() {
    value = !value;
  }
}
