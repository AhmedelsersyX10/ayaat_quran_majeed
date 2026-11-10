import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';

/// Single day entry in the canonical 29-day Khatma schedule.
///
/// Encapsulates verse boundaries and exact Arabic presentation titles
/// matching Reference Screenshots 24, 25, 33, 35 and AGENTS.md Section 14.
/// Pure Dart entity with zero Flutter dependencies.
class Khatma29DayEntry {
  final int dayNumber;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final String? customTitle;
  final String rangeText;

  const Khatma29DayEntry({
    required this.dayNumber,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    this.customTitle,
    required this.rangeText,
  });

  /// Header title for the day with Arabic-Indic digits (e.g. "ورد اليوم ١").
  String get dayTitle => 'ورد اليوم ${toArabicDigits(dayNumber)}';

  /// Primary subtitle/label for the day in the all-wirds list.
  /// Uses [customTitle] when available, otherwise falls back to [rangeText].
  String get displayTitle =>
      (customTitle != null && customTitle!.isNotEmpty) ? customTitle! : rangeText;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Khatma29DayEntry &&
        other.dayNumber == dayNumber &&
        other.startSurah == startSurah &&
        other.startAyah == startAyah &&
        other.endSurah == endSurah &&
        other.endAyah == endAyah &&
        other.customTitle == customTitle &&
        other.rangeText == rangeText;
  }

  @override
  int get hashCode => Object.hash(
        dayNumber,
        startSurah,
        startAyah,
        endSurah,
        endAyah,
        customTitle,
        rangeText,
      );

  @override
  String toString() =>
      'Khatma29DayEntry(day: $dayNumber, title: $displayTitle, range: $startSurah:$startAyah -> $endSurah:$endAyah)';
}

/// Canonical, immutable 29-day Khatma schedule table.
///
/// Transcribed directly from AGENTS.md lines 230–232 and verified against
/// reference screenshots 24, 25, 33, and 35.
/// Guarantees zero gaps and complete coverage from 1:1 to 114:6.
abstract final class Khatma29DayTable {
  /// Total number of days in the canonical meaning-based schedule.
  static const int totalDays = 29;

  /// The immutable 29 daily wird entries.
  static const List<Khatma29DayEntry> days = [
    // 1: Al-Fatihah 1:1 -> Al-Baqarah 2:141 (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 1,
      startSurah: 1,
      startAyah: 1,
      endSurah: 2,
      endAyah: 141,
      rangeText: 'من الفاتحة إلى البقرة: ١٤١',
    ),
    // 2: Al-Baqarah 2:142 -> 2:252 (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 2,
      startSurah: 2,
      startAyah: 142,
      endSurah: 2,
      endAyah: 252,
      rangeText: 'من البقرة: ١٤٢ إلى البقرة: ٢٥٢',
    ),
    // 3: Al-Baqarah 2:253 -> Aal-Imran 3:92 (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 3,
      startSurah: 2,
      startAyah: 253,
      endSurah: 3,
      endAyah: 92,
      rangeText: 'من البقرة: ٢٥٣ إلى آل عمران: ٩٢',
    ),
    // 4: Aal-Imran 3:93 -> An-Nisa 4:35 (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 4,
      startSurah: 3,
      startAyah: 93,
      endSurah: 4,
      endAyah: 35,
      rangeText: 'من آل عمران: ٩٣ إلى النساء: ٣٥',
    ),
    // 5: An-Nisa 4:36 -> An-Nisa 4:176 (end of An-Nisa) (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 5,
      startSurah: 4,
      startAyah: 36,
      endSurah: 4,
      endAyah: 176,
      rangeText: 'من النساء: ٣٦ إلى نهاية النساء',
    ),
    // 6: Al-Ma'idah 5:1 -> 5:120 (complete Surah) (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 6,
      startSurah: 5,
      startAyah: 1,
      endSurah: 5,
      endAyah: 120,
      customTitle: 'المائدة',
      rangeText: 'المائدة',
    ),
    // 7: Al-An'am 6:1 -> 6:165 (complete Surah) (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 7,
      startSurah: 6,
      startAyah: 1,
      endSurah: 6,
      endAyah: 165,
      customTitle: 'الأنعام',
      rangeText: 'الأنعام',
    ),
    // 8: Al-A'raf 7:1 -> 7:206 (complete Surah) (Screenshots 24, 35)
    Khatma29DayEntry(
      dayNumber: 8,
      startSurah: 7,
      startAyah: 1,
      endSurah: 7,
      endAyah: 206,
      customTitle: 'الأعراف',
      rangeText: 'الأعراف',
    ),
    // 9: Al-Anfal 8:1 -> At-Tawbah 9:72 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 9,
      startSurah: 8,
      startAyah: 1,
      endSurah: 9,
      endAyah: 72,
      rangeText: 'من الأنفال إلى التوبة: ٧٢',
    ),
    // 10: At-Tawbah 9:73 -> Yunus 10:109 (end of Yunus) (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 10,
      startSurah: 9,
      startAyah: 73,
      endSurah: 10,
      endAyah: 109,
      rangeText: 'من التوبة: ٧٣ إلى نهاية يونس',
    ),
    // 11: Hud 11:1 -> Yusuf 12:57 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 11,
      startSurah: 11,
      startAyah: 1,
      endSurah: 12,
      endAyah: 57,
      rangeText: 'من هود إلى يوسف: ٥٧',
    ),
    // 12: Yusuf 12:58 -> Ibrahim 14:52 (end of Ibrahim) (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 12,
      startSurah: 12,
      startAyah: 58,
      endSurah: 14,
      endAyah: 52,
      rangeText: 'من يوسف: ٥٨ إلى نهاية إبراهيم',
    ),
    // 13: Al-Hijr 15:1 -> An-Nahl 16:128 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 13,
      startSurah: 15,
      startAyah: 1,
      endSurah: 16,
      endAyah: 128,
      customTitle: 'الحجر و النحل',
      rangeText: 'الحجر و النحل',
    ),
    // 14: Al-Isra 17:1 -> Al-Kahf 18:110 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 14,
      startSurah: 17,
      startAyah: 1,
      endSurah: 18,
      endAyah: 110,
      customTitle: 'الإسراء و الكهف',
      rangeText: 'الإسراء و الكهف',
    ),
    // 15: Maryam 19:1 -> Ta-Ha 20:135 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 15,
      startSurah: 19,
      startAyah: 1,
      endSurah: 20,
      endAyah: 135,
      customTitle: 'مريم و طه',
      rangeText: 'مريم و طه',
    ),
    // 16: Al-Anbiya 21:1 -> Al-Hajj 22:78 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 16,
      startSurah: 21,
      startAyah: 1,
      endSurah: 22,
      endAyah: 78,
      customTitle: 'الأنبياء و الحج',
      rangeText: 'الأنبياء و الحج',
    ),
    // 17: Al-Mu'minun 23:1 -> An-Nur 24:64 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 17,
      startSurah: 23,
      startAyah: 1,
      endSurah: 24,
      endAyah: 64,
      customTitle: 'المؤمنون و النور',
      rangeText: 'المؤمنون و النور',
    ),
    // 18: Al-Furqan 25:1 -> Ash-Shu'ara 26:227 (Screenshot 35)
    Khatma29DayEntry(
      dayNumber: 18,
      startSurah: 25,
      startAyah: 1,
      endSurah: 26,
      endAyah: 227,
      customTitle: 'الفرقان و الشعراء',
      rangeText: 'الفرقان و الشعراء',
    ),
    // 19: An-Naml 27:1 -> Al-Qasas 28:88 (Screenshot 33)
    Khatma29DayEntry(
      dayNumber: 19,
      startSurah: 27,
      startAyah: 1,
      endSurah: 28,
      endAyah: 88,
      customTitle: 'النمل و القصص',
      rangeText: 'النمل و القصص',
    ),
    // 20: Al-Ankabut 29:1 -> As-Sajdah 32:30 (Screenshot 33)
    Khatma29DayEntry(
      dayNumber: 20,
      startSurah: 29,
      startAyah: 1,
      endSurah: 32,
      endAyah: 30,
      customTitle: 'العنكبوت و الروم و لقمان و السجدة',
      rangeText: 'العنكبوت و الروم و لقمان و السجدة',
    ),
    // 21: Al-Ahzab 33:1 -> Fatir 35:45 (Screenshot 33)
    Khatma29DayEntry(
      dayNumber: 21,
      startSurah: 33,
      startAyah: 1,
      endSurah: 35,
      endAyah: 45,
      customTitle: 'الأحزاب و سبأ و فاطر',
      rangeText: 'الأحزاب و سبأ و فاطر',
    ),
    // 22: Ya-Sin 36:1 -> Sad 38:88 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 22,
      startSurah: 36,
      startAyah: 1,
      endSurah: 38,
      endAyah: 88,
      customTitle: 'يس و الصافات و ص',
      rangeText: 'يس و الصافات و ص',
    ),
    // 23: Az-Zumar 39:1 -> Ghafir 40:85 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 23,
      startSurah: 39,
      startAyah: 1,
      endSurah: 40,
      endAyah: 85,
      customTitle: 'الزمر و غافر',
      rangeText: 'الزمر و غافر',
    ),
    // 24: Fussilat 41:1 -> Ad-Dukhan 44:59 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 24,
      startSurah: 41,
      startAyah: 1,
      endSurah: 44,
      endAyah: 59,
      customTitle: 'فصلت و الشورى و الزخرف و الدخان',
      rangeText: 'فصلت و الشورى و الزخرف و الدخان',
    ),
    // 25: Al-Jathiyah 45:1 -> Al-Hujurat 49:18 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 25,
      startSurah: 45,
      startAyah: 1,
      endSurah: 49,
      endAyah: 18,
      customTitle: 'الجاثية و الأحقاف و محمد و الفتح و الحجرات',
      rangeText: 'الجاثية و الأحقاف و محمد و الفتح و الحجرات',
    ),
    // 26: Qaf 50:1 -> Al-Hadid 57:29 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 26,
      startSurah: 50,
      startAyah: 1,
      endSurah: 57,
      endAyah: 29,
      rangeText: 'من ق إلى الحديد',
    ),
    // 27: Al-Mujadila 58:1 -> At-Tahrim 66:12 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 27,
      startSurah: 58,
      startAyah: 1,
      endSurah: 66,
      endAyah: 12,
      rangeText: 'من المجادلة إلى التحريم',
    ),
    // 28: Al-Mulk 67:1 -> Al-Mursalat 77:50 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 28,
      startSurah: 67,
      startAyah: 1,
      endSurah: 77,
      endAyah: 50,
      rangeText: 'من الملك إلى المرسلات',
    ),
    // 29: An-Naba 78:1 -> An-Nas 114:6 (Screenshots 25, 33)
    Khatma29DayEntry(
      dayNumber: 29,
      startSurah: 78,
      startAyah: 1,
      endSurah: 114,
      endAyah: 6,
      rangeText: 'من النبأ إلى الناس',
    ),
  ];

  /// Retrieves the 1-based day entry from the table.
  ///
  /// Throws [ArgumentError] if [dayNumber] is not between 1 and 29.
  static Khatma29DayEntry getDay(int dayNumber) {
    if (dayNumber < 1 || dayNumber > totalDays) {
      throw ArgumentError.value(
        dayNumber,
        'dayNumber',
        'Day number must be between 1 and $totalDays',
      );
    }
    return days[dayNumber - 1];
  }

  /// Finds the 1-based day number containing the specified [surahNumber] and [ayahNumber].
  ///
  /// Throws [ArgumentError] if the verse position is outside valid ranges.
  static int findDayNumberForAyah(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      throw ArgumentError(
        'Invalid Quran verse position: Surah $surahNumber, Ayah $ayahNumber',
      );
    }

    for (final entry in days) {
      final afterStart = _compareVerses(
            surahNumber,
            ayahNumber,
            entry.startSurah,
            entry.startAyah,
          ) >=
          0;
      final beforeEnd = _compareVerses(
            surahNumber,
            ayahNumber,
            entry.endSurah,
            entry.endAyah,
          ) <=
          0;
      if (afterStart && beforeEnd) {
        return entry.dayNumber;
      }
    }

    return 1;
  }

  static int _compareVerses(int s1, int a1, int s2, int a2) {
    if (s1 != s2) return s1.compareTo(s2);
    return a1.compareTo(a2);
  }
}

