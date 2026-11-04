import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:hijri/hijri_calendar.dart';

/// Value object carrying formatted Hijri date details.
class HijriDateInfo {
  final int day;
  final int month;
  final int year;
  final String dayArabic;
  final String monthArabic;

  const HijriDateInfo({
    required this.day,
    required this.month,
    required this.year,
    required this.dayArabic,
    required this.monthArabic,
  });
}

/// Value object carrying formatted Gregorian date details.
class GregorianDateInfo {
  final int day;
  final int month;
  final int year;
  final String dayArabic;
  final String monthArabic;

  const GregorianDateInfo({
    required this.day,
    required this.month,
    required this.year,
    required this.dayArabic,
    required this.monthArabic,
  });
}

/// Service providing Umm al-Qura calendar conversion and date formatting in Arabic.
///
/// Wraps `hijri: 3.0.1` and isolates date calculations from the rest of the application.
class UmmAlQuraDateService {
  const UmmAlQuraDateService();

  /// Arabic names for the 12 Islamic Hijri months matching standard usage and reference 16.
  static const List<String> hijriMonthNamesArabic = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  /// Converts [localCivilDate] to Hijri date, applying [hijriOffset] (-1, 0, +1)
  /// to the civil date before Umm al-Qura conversion.
  HijriDateInfo getHijriDate(DateTime localCivilDate, {int hijriOffset = 0}) {
    final targetDate = localCivilDate.add(Duration(days: hijriOffset));
    final hijri = HijriCalendar.fromDate(targetDate);

    final monthIndex = (hijri.hMonth - 1).clamp(0, 11);
    final monthName = hijriMonthNamesArabic[monthIndex];
    final dayArabic = toArabicDigits(hijri.hDay);

    return HijriDateInfo(
      day: hijri.hDay,
      month: hijri.hMonth,
      year: hijri.hYear,
      dayArabic: dayArabic,
      monthArabic: monthName,
    );
  }

  /// Extracts formatted Gregorian date info for [localCivilDate].
  GregorianDateInfo getGregorianDate(DateTime localCivilDate) {
    final monthIndex = (localCivilDate.month - 1).clamp(0, 11);
    final monthName = ArabicNumbers.arabicMonths[monthIndex];
    final dayArabic = toArabicDigits(localCivilDate.day);

    return GregorianDateInfo(
      day: localCivilDate.day,
      month: localCivilDate.month,
      year: localCivilDate.year,
      dayArabic: dayArabic,
      monthArabic: monthName,
    );
  }
}
