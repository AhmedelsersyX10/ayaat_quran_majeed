import 'package:flutter/material.dart';

/// Centralized configuration for app localization and internationalization.
///
/// In V1, the application is Arabic only and operates strictly in RTL mode.
abstract class LocalizationConfig {
  /// Default and only supported language code for V1.
  static const String arabicLanguageCode = 'ar';

  /// Default and primary locale for the application.
  static const Locale defaultLocale = Locale(arabicLanguageCode);

  /// Initial startup locale for EasyLocalization.
  static const Locale startLocale = Locale(arabicLanguageCode);

  /// Fallback locale when translations or locale detection fails.
  static const Locale fallbackLocale = Locale(arabicLanguageCode);

  /// List of supported locales (Arabic only in V1).
  static const List<Locale> supportedLocales = [
    Locale(arabicLanguageCode),
  ];

  /// Path to translation JSON assets in pubspec.
  static const String translationsPath = 'assets/translations';

  /// Standard text direction for the application.
  static const TextDirection defaultDirection = TextDirection.rtl;
}

