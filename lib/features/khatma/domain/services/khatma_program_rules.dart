import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import '../entities/khatma_program.dart';

/// Domain service formulating the mathematical division rules, boundary constraints,
/// rounding validations, and Arabic grammar descriptions for Khatma programs.
///
/// Pure Dart — no Flutter framework dependencies.
/// Conforms to Reference Screenshots 09, 14, and 32.
abstract final class KhatmaProgramRules {
  /// Total number of quarters (أرباع) in the Holy Quran.
  static const int totalQuranQuarters = 240;

  /// Total number of Ahzab (أحزاب) in the Holy Quran.
  static const int totalQuranAhzab = 60;

  /// Total number of Ajza' (أجزاء) in the Holy Quran.
  static const int totalQuranAjza = 30;

  /// Total number of pages in the Madani Mushaf layout.
  static const int totalMushafPages = 604;

  /// Valid duration days for quarter-based division programs in exact descending order
  /// matching Reference Screenshot 32.
  static const List<int> partsAndQuartersDaysOrder = [
    240,
    120,
    80,
    60,
    40,
    30,
    20,
    15,
    10,
    6,
    3,
  ];

  /// Valid duration days for meaning-divided programs (Reference Screenshot 09).
  static const List<int> meaningDaysOrder = [
    60,
    29,
    7,
  ];

  /// Validates whether [totalDays] and [category] satisfy strict boundary and division rules.
  static bool isValid({
    required int totalDays,
    required KhatmaProgramCategory category,
  }) {
    switch (category) {
      case KhatmaProgramCategory.suggested:
        return totalDays == 29;
      case KhatmaProgramCategory.meaning:
        return meaningDaysOrder.contains(totalDays);
      case KhatmaProgramCategory.partsAndQuarters:
        if (totalDays < 3 || totalDays > 240) return false;
        if (totalQuranQuarters % totalDays != 0) return false;
        return partsAndQuartersDaysOrder.contains(totalDays);
    }
  }

  /// Calculates the exact number of quarters per day for a parts & quarters program.
  /// Throws [ArgumentError] if [totalDays] does not divide 240 evenly.
  static int calculateQuartersPerDay(int totalDays) {
    if (totalDays <= 0 || totalQuranQuarters % totalDays != 0) {
      throw ArgumentError(
        'Duration $totalDays must evenly divide $totalQuranQuarters quarters.',
      );
    }
    return totalQuranQuarters ~/ totalDays;
  }

  /// Calculates the approximate number of pages per day for a given duration.
  static int calculateApproxPagesPerDay(int totalDays) {
    if (totalDays <= 0) {
      throw ArgumentError('Duration must be positive, received $totalDays.');
    }
    return (totalMushafPages / totalDays).round();
  }

  /// Derives the Arabic title for a program based on its duration and category.
  static String deriveTitle({
    required int totalDays,
    required KhatmaProgramCategory category,
  }) {
    if (category == KhatmaProgramCategory.suggested ||
        (category == KhatmaProgramCategory.meaning && totalDays == 29)) {
      return 'ختمة شهر (٢٩ يومًا)';
    }

    if (category == KhatmaProgramCategory.meaning) {
      switch (totalDays) {
        case 60:
          return 'ختمة شهرين (٦٠ يومًا)';
        case 7:
          return 'ختمة أسبوع (٧ أيام)';
        default:
          final countStr = toArabicDigits(totalDays);
          final unit = (totalDays >= 3 && totalDays <= 10) ? 'أيام' : 'يومًا';
          return 'ختمة $countStr $unit';
      }
    }

    // partsAndQuarters division (References 14, 32)
    final countStr = toArabicDigits(totalDays);
    final unit = (totalDays >= 3 && totalDays <= 10) ? 'أيام' : 'يوما';
    return 'ختمة $countStr $unit';
  }

  /// Derives the Arabic daily portion subtitle (e.g. "الورد اليومي: ربع")
  /// derived deterministically from the division rules.
  static String deriveSubtitle({
    required int totalDays,
    required KhatmaProgramCategory category,
  }) {
    const prefix = 'الورد اليومي: ';

    if (category == KhatmaProgramCategory.suggested ||
        (category == KhatmaProgramCategory.meaning && totalDays == 29)) {
      final pages = calculateApproxPagesPerDay(29); // 21
      return '$prefix${toArabicDigits(pages)} صفحة تقريبًا';
    }

    if (category == KhatmaProgramCategory.meaning) {
      switch (totalDays) {
        case 60:
          final pages = calculateApproxPagesPerDay(60); // 10
          return '$prefix${toArabicDigits(pages)} صفحات تقريبًا';
        case 7:
          return '$prefix${toArabicDigits(5)} أجزاء تقريبًا';
        default:
          final pages = calculateApproxPagesPerDay(totalDays);
          return '$prefix${toArabicDigits(pages)} صفحة تقريبًا';
      }
    }

    // partsAndQuarters: derived from quartersPerDay
    final quarters = calculateQuartersPerDay(totalDays);
    final unitText = _deriveQuartersPortionText(quarters);
    return '$prefix$unitText';
  }

  /// Maps a specific quarters-per-day count to its correct Arabic textual term.
  static String _deriveQuartersPortionText(int quarters) {
    switch (quarters) {
      case 1:
        return 'ربع';
      case 2:
        return 'ربعان';
      case 3:
        return '٣ أرباع';
      case 4:
        return 'حزب';
      case 6:
        return 'حزب ونصف';
      case 8:
        return 'جزء';
      case 12:
        return 'جزء ونصف';
      case 16:
        return 'جزءان';
      case 24:
        return '٣ أجزاء';
      case 40:
        return '٥ أجزاء';
      case 80:
        return '١٠ أجزاء';
      default:
        return '${toArabicDigits(quarters)} ربع';
    }
  }
}

