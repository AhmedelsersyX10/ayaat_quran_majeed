/// Pure Dart utility for bidirectional Arabic-Indic numeral conversion
/// and semantic label/date/time formatting.
///
/// Contains no heavy Flutter dependencies and guarantees crash-free parsing
/// for mixed strings containing punctuation or non-digit characters.
abstract class ArabicNumbers {
  static const Map<String, String> _westernToArabicMap = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static const Map<String, String> _arabicToWesternMap = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// Arabic names for Gregorian calendar months (Mashriq/standard).
  static const List<String> arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// Arabic names for days of the week starting from Monday (DateTime.monday = 1).
  static const List<String> arabicWeekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  /// Arabic ordinal names for the 30 Juz parts.
  static const Map<int, String> juzOrdinalNames = {
    1: 'الأول',
    2: 'الثاني',
    3: 'الثالث',
    4: 'الرابع',
    5: 'الخامس',
    6: 'السادس',
    7: 'السابع',
    8: 'الثامن',
    9: 'التاسع',
    10: 'العاشر',
    11: 'الحادي عشر',
    12: 'الثاني عشر',
    13: 'الثالث عشر',
    14: 'الرابع عشر',
    15: 'الخامس عشر',
    16: 'السادس عشر',
    17: 'السابع عشر',
    18: 'الثامن عشر',
    19: 'التاسع عشر',
    20: 'العشرون',
    21: 'الحادي والعشرون',
    22: 'الثاني والعشرون',
    23: 'الثالث والعشرون',
    24: 'الرابع والعشرون',
    25: 'الخامس والعشرون',
    26: 'السادس والعشرون',
    27: 'السابع والعشرون',
    28: 'الثامن والعشرون',
    29: 'التاسع والعشرون',
    30: 'الثلاثون',
  };
}

/// Converts ASCII digits (0-9) inside [value] into Eastern Arabic-Indic numerals (٠-٩).
///
/// Preserves any non-digit punctuation (`:`, `-`, `/`, spaces, letters) intact.
/// Accepts [int], [num], or [String]. Returns empty string if value is null.
String toArabicDigits(dynamic value) {
  if (value == null) return '';
  final str = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < str.length; i++) {
    final char = str[i];
    final mapped = ArabicNumbers._westernToArabicMap[char];
    buffer.write(mapped ?? char);
  }

  return buffer.toString();
}

/// Converts Eastern Arabic-Indic numerals (٠-٩) inside [value] into ASCII digits (0-9).
///
/// Preserves all non-digit characters intact.
String toWesternDigits(String value) {
  final buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    final char = value[i];
    final mapped = ArabicNumbers._arabicToWesternMap[char];
    buffer.write(mapped ?? char);
  }

  return buffer.toString();
}

/// Parses an Arabic-Indic or mixed numeral string into an [int].
/// Returns null if the string cannot be parsed.
int? parseArabicInt(String value) {
  final western = toWesternDigits(value.trim());
  return int.tryParse(western);
}

/// Formats a 12-hour or 24-hour time string in Arabic numerals with Arabic AM/PM markers.
///
/// Output matches screens 23 and 27:
/// e.g. `٠٧:٣٠ ص` or `٠٩:٣٢ م`
String formatArabicTime({
  required int hour,
  required int minute,
  bool is24Hour = false,
}) {
  final clampedMinute = minute.clamp(0, 59);
  final minuteStr = clampedMinute.toString().padLeft(2, '0');

  if (is24Hour) {
    final clampedHour = hour.clamp(0, 23);
    final hourStr = clampedHour.toString().padLeft(2, '0');
    return '${toArabicDigits(hourStr)}:${toArabicDigits(minuteStr)}';
  }

  final isPm = hour >= 12;
  int hour12 = hour % 12;
  if (hour12 == 0) hour12 = 12;

  final period = isPm ? 'م' : 'ص';
  final hourStr = hour12.toString();

  return '${toArabicDigits(hourStr)}:${toArabicDigits(minuteStr)} $period';
}

/// Formats a Gregorian [date] in Arabic with Arabic month names and numerals.
///
/// Output matches screen 16:
/// e.g. `٣٠ أكتوبر ٢٠٢٣` or `السبت ٣٠ أكتوبر ٢٠٢٣`
String formatArabicDate(
  DateTime date, {
  bool includeDayName = false,
  bool includeYear = true,
}) {
  final day = toArabicDigits(date.day);
  final monthIndex = (date.month - 1).clamp(0, 11);
  final monthName = ArabicNumbers.arabicMonths[monthIndex];
  final year = toArabicDigits(date.year);

  final datePart = includeYear ? '$day $monthName $year' : '$day $monthName';

  if (includeDayName) {
    final weekdayIndex = (date.weekday - 1).clamp(0, 6);
    final weekdayName = ArabicNumbers.arabicWeekdays[weekdayIndex];
    return '$weekdayName $datePart';
  }

  return datePart;
}

/// Formats an Ayah reference label (e.g. `الفاتحة: ٥`).
String formatAyahLabel(String surahName, int ayahNumber) {
  return '$surahName: ${toArabicDigits(ayahNumber)}';
}

/// Formats a combined Page and Ayah label (e.g. `البقرة: ٦ - الصفحة ٣`).
/// Matches reference screens 27 and 30.
String formatPageAyahLabel({
  required String surahName,
  required int ayahNumber,
  required int pageNumber,
}) {
  return '$surahName: ${toArabicDigits(ayahNumber)} - الصفحة ${toArabicDigits(pageNumber)}';
}

/// Formats a Surah row header (e.g. `الصفحة ٢ - آياتها ٢٨٦ - مدنية`).
/// Matches reference screen 03.
String formatSurahHeader({
  required int pageNumber,
  required int versesCount,
  required bool isMakki,
}) {
  final pageStr = toArabicDigits(pageNumber);
  final countStr = toArabicDigits(versesCount);
  final classification = isMakki ? 'مكية' : 'مدنية';
  return 'الصفحة $pageStr - آياتها $countStr - $classification';
}

/// Formats the ordinal name for a Juz (1 to 30), e.g. `الجزء الأول`.
/// Matches reference screen 03.
String formatJuzOrdinal(int juzNumber) {
  final ordinal = ArabicNumbers.juzOrdinalNames[juzNumber] ?? toArabicDigits(juzNumber);
  return 'الجزء $ordinal';
}

/// Formats a Hizb quarter label (e.g. `الحزب ١`, `ربع الحزب ١`).
/// Matches reference screen 04.
String formatHizbQuarter({
  required int hizbNumber,
  required int quarterIndex,
}) {
  final hizbStr = toArabicDigits(hizbNumber);
  switch (quarterIndex % 4) {
    case 0:
      return 'الحزب $hizbStr';
    case 1:
      return 'ربع الحزب $hizbStr';
    case 2:
      return 'نصف الحزب $hizbStr';
    case 3:
      return 'ثلاثة أرباع الحزب $hizbStr';
    default:
      return 'الحزب $hizbStr';
  }
}

/// Formats Khatma duration days (e.g. `٣٠ يوما`, `٣ أيام`).
/// Matches reference screen 14.
String formatKhatmaDays(int days) {
  final daysStr = toArabicDigits(days);
  if (days >= 3 && days <= 10) {
    return '$daysStr أيام';
  }
  return '$daysStr يوما';
}

