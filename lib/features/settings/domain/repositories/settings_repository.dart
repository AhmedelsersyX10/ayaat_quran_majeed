import 'package:ayaat_quran_majeed/features/settings/domain/entities/app_settings.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';

/// Contract governing persistent application preferences and source attributions.
abstract class SettingsRepository {
  /// Synchronously loads the current active [AppSettings].
  AppSettings getSettings();

  /// Persists the screen wake lock preference.
  Future<void> setKeepScreenAwake(bool value);

  /// Persists the manual Hijri calendar adjustment (-1, 0, or +1 day).
  Future<void> setHijriOffset(int offset);

  /// Persists the Mushaf font size setting.
  Future<void> setMushafFontSize(double fontSize);

  /// Returns the verified static list of Quran, Tafsir, Audio, and Library
  /// content sources and attributions.
  List<ContentSource> getSourcesAndAttributions();
}
