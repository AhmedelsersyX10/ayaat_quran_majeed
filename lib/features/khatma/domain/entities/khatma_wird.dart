import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';

/// Domain entity representing a single day's reading portion (Wird) in a Khatma.
///
/// Contains precise Quran verse and page boundaries, completion status,
/// and deterministic relative scheduling calculation.
/// Pure Dart — no Flutter framework dependencies.
class KhatmaWird {
  final int dayNumber;
  final DateTime scheduledDate;
  final int startSurahNumber;
  final int startAyahNumber;
  final int endSurahNumber;
  final int endAyahNumber;
  final int startPageNumber;
  final int endPageNumber;
  final String startSurahName;
  final String endSurahName;
  final String firstVerseText;
  final String lastVerseText;
  final String? customTitle;
  final String rangeText;
  final bool isCompleted;
  final DateTime? completedAt;

  const KhatmaWird({
    required this.dayNumber,
    required this.scheduledDate,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahNumber,
    required this.endAyahNumber,
    required this.startPageNumber,
    required this.endPageNumber,
    required this.startSurahName,
    required this.endSurahName,
    required this.firstVerseText,
    required this.lastVerseText,
    this.customTitle,
    required this.rangeText,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Computes the relative day label based on `scheduledDate - currentDate`.
  ///
  /// Conforms to reference screenshots 26 ("بعد يومين") and 31 ("اليوم"),
  /// as well as past/future relative Arabic expressions.
  String relativeDayLabel(DateTime currentDate) {
    final sDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final cDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final diff = sDate.difference(cDate).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'غداً';
    if (diff == 2) return 'بعد يومين';
    if (diff >= 3 && diff <= 10) return 'بعد ${toArabicDigits(diff)} أيام';
    if (diff > 10) return 'بعد ${toArabicDigits(diff)} يوماً';

    if (diff == -1) return 'أمس';
    if (diff == -2) return 'قبل يومين';
    if (diff <= -3 && diff >= -10) return 'قبل ${toArabicDigits(-diff)} أيام';
    return 'قبل ${toArabicDigits(-diff)} يوماً';
  }

  /// Title displayed in the Wird header (e.g. "ورد اليوم ١").
  String get dayTitle => 'ورد اليوم ${toArabicDigits(dayNumber)}';

  /// Primary display label for the wird in the list of all wirds.
  /// Uses [customTitle] (e.g. "المائدة", "الحجر و النحل") if available,
  /// otherwise uses [rangeText] (e.g. "من الفاتحة إلى البقرة: ١٤١").
  String get displayTitle => customTitle != null && customTitle!.isNotEmpty ? customTitle! : rangeText;

  KhatmaWird copyWith({
    int? dayNumber,
    DateTime? scheduledDate,
    int? startSurahNumber,
    int? startAyahNumber,
    int? endSurahNumber,
    int? endAyahNumber,
    int? startPageNumber,
    int? endPageNumber,
    String? startSurahName,
    String? endSurahName,
    String? firstVerseText,
    String? lastVerseText,
    String? customTitle,
    String? rangeText,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return KhatmaWird(
      dayNumber: dayNumber ?? this.dayNumber,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startSurahNumber: startSurahNumber ?? this.startSurahNumber,
      startAyahNumber: startAyahNumber ?? this.startAyahNumber,
      endSurahNumber: endSurahNumber ?? this.endSurahNumber,
      endAyahNumber: endAyahNumber ?? this.endAyahNumber,
      startPageNumber: startPageNumber ?? this.startPageNumber,
      endPageNumber: endPageNumber ?? this.endPageNumber,
      startSurahName: startSurahName ?? this.startSurahName,
      endSurahName: endSurahName ?? this.endSurahName,
      firstVerseText: firstVerseText ?? this.firstVerseText,
      lastVerseText: lastVerseText ?? this.lastVerseText,
      customTitle: customTitle ?? this.customTitle,
      rangeText: rangeText ?? this.rangeText,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhatmaWird &&
        other.dayNumber == dayNumber &&
        other.scheduledDate == scheduledDate &&
        other.startSurahNumber == startSurahNumber &&
        other.startAyahNumber == startAyahNumber &&
        other.endSurahNumber == endSurahNumber &&
        other.endAyahNumber == endAyahNumber &&
        other.startPageNumber == startPageNumber &&
        other.endPageNumber == endPageNumber &&
        other.customTitle == customTitle &&
        other.rangeText == rangeText &&
        other.isCompleted == isCompleted &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode => Object.hash(
        dayNumber,
        scheduledDate,
        startSurahNumber,
        startAyahNumber,
        endSurahNumber,
        endAyahNumber,
        startPageNumber,
        endPageNumber,
        customTitle,
        rangeText,
        isCompleted,
        completedAt,
      );

  @override
  String toString() => 'KhatmaWird(day: $dayNumber, title: $displayTitle, completed: $isCompleted)';
}
