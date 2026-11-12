import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base state for the Today feature.
sealed class TodayState {
  const TodayState();
}

/// Initial state before data loading commences.
class TodayInitial extends TodayState {
  const TodayInitial();
}

/// State emitted while fetching today's Ayah and date conversions.
class TodayLoading extends TodayState {
  const TodayLoading();
}

/// State emitted when today's Ayah has been successfully computed and resolved.
class TodaySuccess extends TodayState {
  final TodayAyah ayah;

  const TodaySuccess(this.ayah);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodaySuccess && other.ayah == ayah;
  }

  @override
  int get hashCode => ayah.hashCode;
}

/// State emitted when an error occurs during today's Ayah resolution.
/// Always carries a safe, localized error message — never raw `Exception.toString()`.
class TodayFailure extends TodayState {
  final String message;

  const TodayFailure(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodayFailure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Cubit managing state for the Today (Ayah of the Day) feature.
class TodayCubit extends Cubit<TodayState> {
  final TodayRepository _repository;

  TodayCubit(this._repository) : super(const TodayInitial());

  /// Returns the currently active manual Hijri adjustment in days (-1, 0, +1).
  int get currentHijriOffset => _repository.getHijriOffset();

  /// Loads the Ayah of the day.
  ///
  /// Optionally accepts [forDate] to facilitate testing deterministic selections.
  Future<void> loadTodayAyah({DateTime? forDate}) async {
    emit(const TodayLoading());
    try {
      final ayah = await _repository.getTodayAyah(forDate: forDate);
      emit(TodaySuccess(ayah));
    } on Failure catch (failure) {
      final message = failure.message.isNotEmpty
          ? AppStrings.tr(failure.message)
          : AppStrings.tr(AppStrings.todayLoadFailed);
      emit(TodayFailure(message));
    } catch (_) {
      emit(TodayFailure(AppStrings.tr(AppStrings.todayLoadFailed)));
    }
  }

  /// Updates the manual Hijri calendar adjustment (-1, 0, +1) and reloads
  /// the Ayah of the day with the updated calendar conversion.
  Future<void> updateHijriOffset(int offset) async {
    await _repository.setHijriOffset(offset);
    final currentDate = state is TodaySuccess
        ? (state as TodaySuccess).ayah.localDate
        : null;
    await loadTodayAyah(forDate: currentDate);
  }
}
