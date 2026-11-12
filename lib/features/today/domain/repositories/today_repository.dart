import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';

/// Domain contract for retrieving the deterministic Ayah of the Day
/// and its associated Hijri/Gregorian date representations.
///
/// Pure Dart — no Flutter framework dependencies.
abstract class TodayRepository {
  /// Retrieves the Ayah of the Day.
  ///
  /// If [forDate] is provided, computes the deterministic selection for that
  /// specific local civil date; otherwise, uses the current local date.
  Future<TodayAyah> getTodayAyah({DateTime? forDate});

  /// Returns the current manual Hijri calendar adjustment in days (-1, 0, +1).
  int getHijriOffset();

  /// Persists a new manual Hijri calendar adjustment in days (clamped between -1 and +1).
  Future<void> setHijriOffset(int offset);
}
