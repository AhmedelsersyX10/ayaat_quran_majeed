import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Centralized loader for the bundled Quran JSON assets.
///
/// The app references `assets/json/surahs.json` and `assets/json/quarters.json`
/// in several places (e.g. `QuranDetailsPage` and `SurahListPage`). Because those
/// consumers expect the decoded data to be available synchronously, the assets are
/// decoded once during app startup (see `main()`) and cached here as static state.
class JsonAssetService {
  JsonAssetService._();

  static List<dynamic> _surahsData = const [];
  static List<dynamic> _quartersData = const [];
  static bool _initialized = false;

  /// Decoded list of surahs from `assets/json/surahs.json`.
  ///
  /// Each entry exposes keys such as `number`, `name`, `englishName`,
  /// `englishNameTranslation`, `numberOfAyahs` and `revelationType`.
  static List<dynamic> get surahsData => _surahsData;

  /// Decoded list of quarters from `assets/json/quarters.json`.
  ///
  /// Each entry exposes the `surah` and `ayah` keys that mark a quarter start.
  static List<dynamic> get quartersData => _quartersData;

  /// Whether [init] has finished loading the bundled assets.
  static bool get isInitialized => _initialized;

  /// Loads (and caches) the bundled JSON assets. Safe to call multiple times;
  /// subsequent calls are no-ops once initialized.
  static Future<void> init() async {
    if (_initialized) return;

    final results = await Future.wait([
      rootBundle.loadString('assets/json/surahs.json'),
      rootBundle.loadString('assets/json/quarters.json'),
    ]);

    _surahsData = json.decode(results[0]) as List<dynamic>;
    _quartersData = json.decode(results[1]) as List<dynamic>;
    _initialized = true;
  }
}
