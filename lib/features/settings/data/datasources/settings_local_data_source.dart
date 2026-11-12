import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';

/// Contract for local storage operations related to settings.
abstract class SettingsLocalDataSource {
  bool getKeepScreenAwake();
  Future<void> setKeepScreenAwake(bool value);
  int getHijriOffset();
  Future<void> setHijriOffset(int offset);
  double getMushafFontSize();
  Future<void> setMushafFontSize(double fontSize);
}

/// Implementation of [SettingsLocalDataSource] backed by [AppPreferences].
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final AppPreferences? _preferences;

  const SettingsLocalDataSourceImpl({AppPreferences? preferences})
    : _preferences = preferences;

  @override
  bool getKeepScreenAwake() => _preferences?.keepScreenAwake ?? true;

  @override
  Future<void> setKeepScreenAwake(bool value) async {
    await _preferences?.setKeepScreenAwake(value);
  }

  @override
  int getHijriOffset() => _preferences?.hijriOffset ?? 0;

  @override
  Future<void> setHijriOffset(int offset) async {
    await _preferences?.setHijriOffset(offset);
  }

  @override
  double getMushafFontSize() => _preferences?.mushafFontSize ?? 23.0;

  @override
  Future<void> setMushafFontSize(double fontSize) async {
    await _preferences?.setMushafFontSize(fontSize);
  }
}
