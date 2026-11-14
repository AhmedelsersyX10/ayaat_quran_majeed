import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/repositories/settings_repository.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit managing application settings and source attributions.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit({required SettingsRepository repository})
    : _repository = repository,
      super(const SettingsInitial());

  /// Loads current settings and sources synchronously and emits [SettingsLoaded].
  void loadSettings() {
    try {
      final settings = _repository.getSettings();
      final sources = _repository.getSourcesAndAttributions();
      emit(SettingsLoaded(settings: settings, sources: sources));
    } on Failure catch (e) {
      emit(SettingsFailure(e.message));
    } catch (_) {
      emit(const SettingsFailure('تعذر تحميل الإعدادات'));
    }
  }

  /// Toggles the screen wake lock setting and updates persistence.
  Future<void> toggleKeepScreenAwake(bool value) async {
    try {
      await _repository.setKeepScreenAwake(value);
      final current = state;
      if (current is SettingsLoaded) {
        emit(
          SettingsLoaded(
            settings: current.settings.copyWith(keepScreenAwake: value),
            sources: current.sources,
          ),
        );
      } else {
        loadSettings();
      }
    } on Failure catch (e) {
      emit(SettingsFailure(e.message));
    } catch (_) {
      emit(const SettingsFailure('تعذر حفظ إعداد إبقاء الشاشة مفعلة'));
    }
  }

  /// Updates the Hijri calendar adjustment offset (-1, 0, +1).
  Future<void> updateHijriOffset(int offset) async {
    try {
      await _repository.setHijriOffset(offset);
      final current = state;
      if (current is SettingsLoaded) {
        emit(
          SettingsLoaded(
            settings: current.settings.copyWith(hijriOffset: offset),
            sources: current.sources,
          ),
        );
      } else {
        loadSettings();
      }
    } on Failure catch (e) {
      emit(SettingsFailure(e.message));
    } catch (_) {
      emit(const SettingsFailure('تعذر تعديل التاريخ الهجري'));
    }
  }

  /// Updates the Mushaf font size setting.
  Future<void> updateMushafFontSize(double fontSize) async {
    try {
      await _repository.setMushafFontSize(fontSize);
      final current = state;
      if (current is SettingsLoaded) {
        emit(
          SettingsLoaded(
            settings: current.settings.copyWith(mushafFontSize: fontSize),
            sources: current.sources,
          ),
        );
      } else {
        loadSettings();
      }
    } on Failure catch (e) {
      emit(SettingsFailure(e.message));
    } catch (_) {
      emit(const SettingsFailure('تعذر تعديل حجم الخط'));
    }
  }
}
