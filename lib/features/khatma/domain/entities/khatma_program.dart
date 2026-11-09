/// Program category for Quran completion schedules.
///
/// Matches reference screenshots 06, 09, 14, 32.
/// Pure Dart — no Flutter framework dependencies.
enum KhatmaProgramCategory {
  /// Suggested primary program ("ختمة مقترحة" - Reference 06).
  suggested,

  /// Programs divided by contextual meaning ("ختمة مقسمة بالمعنى" - References 06, 09).
  meaning,

  /// Programs divided by Juz and Quarter divisions ("ختمة مقسمة بالأجزاء والأرباع" - References 06, 14, 32).
  partsAndQuarters,
}

/// Domain entity representing a Khatma duration program.
///
/// Defines the schedule parameters, daily reading expectations, and categorization.
/// Pure Dart — no Flutter framework dependencies.
class KhatmaProgram {
  final String id;
  final String title;
  final String subtitle;
  final int totalDays;
  final KhatmaProgramCategory category;
  final String? subCategory;

  const KhatmaProgram({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.totalDays,
    required this.category,
    this.subCategory,
  });

  /// Default suggested 29-day Khatma (References 06, 09, 24, 25, 26, 31, 33, 35).
  static const KhatmaProgram defaultProgram = KhatmaProgram(
    id: 'meaning_29',
    title: 'ختمة شهر (٢٩ يومًا)',
    subtitle: 'الورد اليومي: ٢١ صفحة تقريبًا',
    totalDays: 29,
    category: KhatmaProgramCategory.suggested,
  );

  /// Meaning-divided programs (Reference 09).
  static const List<KhatmaProgram> meaningPrograms = [
    KhatmaProgram(
      id: 'meaning_60',
      title: 'ختمة شهرين (٦٠ يومًا)',
      subtitle: 'الورد اليومي: ١٠ صفحات تقريبًا',
      totalDays: 60,
      category: KhatmaProgramCategory.meaning,
    ),
    KhatmaProgram(
      id: 'meaning_29',
      title: 'ختمة شهر (٢٩ يومًا)',
      subtitle: 'الورد اليومي: ٢١ صفحة تقريبًا',
      totalDays: 29,
      category: KhatmaProgramCategory.meaning,
    ),
    KhatmaProgram(
      id: 'meaning_7',
      title: 'ختمة أسبوع (٧ أيام)',
      subtitle: 'الورد اليومي: ٥ أجزاء تقريبًا',
      totalDays: 7,
      category: KhatmaProgramCategory.meaning,
    ),
  ];

  /// Parts and Quarters divided programs (References 14, 32).
  static const List<KhatmaProgram> partsAndQuartersPrograms = [
    KhatmaProgram(
      id: 'parts_30',
      title: 'ختمة ٣٠ يوما',
      subtitle: 'الورد اليومي: جزء',
      totalDays: 30,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'الأشهر',
    ),
    KhatmaProgram(
      id: 'quarters_240',
      title: 'ختمة ٢٤٠ يوما',
      subtitle: 'الورد اليومي: ربع',
      totalDays: 240,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'quarters_120',
      title: 'ختمة ١٢٠ يوما',
      subtitle: 'الورد اليومي: ربعان',
      totalDays: 120,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'quarters_80',
      title: 'ختمة ٨٠ يوما',
      subtitle: 'الورد اليومي: ٣ أرباع',
      totalDays: 80,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'quarters_60',
      title: 'ختمة ٦٠ يوما',
      subtitle: 'الورد اليومي: حزب',
      totalDays: 60,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'quarters_40',
      title: 'ختمة ٤٠ يوما',
      subtitle: 'الورد اليومي: حزب ونصف',
      totalDays: 40,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'parts_20',
      title: 'ختمة ٢٠ يوما',
      subtitle: 'الورد اليومي: جزء ونصف',
      totalDays: 20,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'parts_15',
      title: 'ختمة ١٥ يوما',
      subtitle: 'الورد اليومي: جزءان',
      totalDays: 15,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'parts_10',
      title: 'ختمة ١٠ أيام',
      subtitle: 'الورد اليومي: ٣ أجزاء',
      totalDays: 10,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'parts_6',
      title: 'ختمة ٦ أيام',
      subtitle: 'الورد اليومي: ٥ أجزاء',
      totalDays: 6,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
    KhatmaProgram(
      id: 'parts_3',
      title: 'ختمة ٣ أيام',
      subtitle: 'الورد اليومي: ١٠ أجزاء',
      totalDays: 3,
      category: KhatmaProgramCategory.partsAndQuarters,
      subCategory: 'أخرى',
    ),
  ];

  /// Finds a program by its unique [id], or returns null if not found.
  static KhatmaProgram? findById(String id) {
    if (id == defaultProgram.id) return defaultProgram;
    for (final p in meaningPrograms) {
      if (p.id == id) return p;
    }
    for (final p in partsAndQuartersPrograms) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhatmaProgram &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.totalDays == totalDays &&
        other.category == category &&
        other.subCategory == subCategory;
  }

  @override
  int get hashCode => Object.hash(id, title, subtitle, totalDays, category, subCategory);

  @override
  String toString() => 'KhatmaProgram(id: $id, title: $title, days: $totalDays)';
}

