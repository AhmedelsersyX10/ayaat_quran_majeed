import 'package:ayaat_quran_majeed/features/settings/domain/entities/app_settings.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';

/// Base state for [SettingsCubit].
sealed class SettingsState {
  const SettingsState();
}

/// Initial uninitialized state.
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Settings are currently being loaded or updated.
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Settings and sources are successfully loaded.
class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  final List<ContentSource> sources;

  const SettingsLoaded({required this.settings, required this.sources});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsLoaded &&
          runtimeType == other.runtimeType &&
          settings == other.settings;

  @override
  int get hashCode => settings.hashCode;
}

/// An error occurred while retrieving or persisting settings.
class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
