import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Serializable data model for a single daily reading portion [KhatmaWird].
///
/// Stores only lightweight boundary identifiers and state, enriching with live
/// Quran metadata upon conversion to domain entity.
class KhatmaWirdModel {
  final int dayNumber;
  final DateTime scheduledDate;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final String? customTitle;
  final String rangeText;
  final bool isCompleted;
  final DateTime? completedAt;

  const KhatmaWirdModel({
    required this.dayNumber,
    required this.scheduledDate,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    this.customTitle,
    required this.rangeText,
    this.isCompleted = false,
    this.completedAt,
  });

  factory KhatmaWirdModel.fromEntity(KhatmaWird entity) {
    return KhatmaWirdModel(
      dayNumber: entity.dayNumber,
      scheduledDate: entity.scheduledDate,
      startSurah: entity.startSurahNumber,
      startAyah: entity.startAyahNumber,
      endSurah: entity.endSurahNumber,
      endAyah: entity.endAyahNumber,
      customTitle: entity.customTitle,
      rangeText: entity.rangeText,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
    );
  }

  factory KhatmaWirdModel.fromMap(Map<dynamic, dynamic> map) {
    return KhatmaWirdModel(
      dayNumber: map['dayNumber'] as int,
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
      startSurah: map['startSurah'] as int,
      startAyah: map['startAyah'] as int,
      endSurah: map['endSurah'] as int,
      endAyah: map['endAyah'] as int,
      customTitle: map['customTitle'] as String?,
      rangeText: (map['rangeText'] ?? '') as String,
      isCompleted: (map['isCompleted'] ?? false) as bool,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'scheduledDate': scheduledDate.toIso8601String(),
      'startSurah': startSurah,
      'startAyah': startAyah,
      'endSurah': endSurah,
      'endAyah': endAyah,
      'customTitle': customTitle,
      'rangeText': rangeText,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  KhatmaWird toEntity(QuranMetadataService metadataService) {
    final startSurahName = metadataService.getSurahNameArabic(startSurah);
    final endSurahName = metadataService.getSurahNameArabic(endSurah);
    final startPage = metadataService.getPageNumber(startSurah, startAyah);
    final endPage = metadataService.getPageNumber(endSurah, endAyah);
    final firstVerse = metadataService.getVerse(startSurah, startAyah);
    final lastVerse = metadataService.getVerse(endSurah, endAyah);

    return KhatmaWird(
      dayNumber: dayNumber,
      scheduledDate: scheduledDate,
      startSurahNumber: startSurah,
      startAyahNumber: startAyah,
      endSurahNumber: endSurah,
      endAyahNumber: endAyah,
      startPageNumber: startPage,
      endPageNumber: endPage,
      startSurahName: startSurahName,
      endSurahName: endSurahName,
      firstVerseText: firstVerse,
      lastVerseText: lastVerse,
      customTitle: customTitle,
      rangeText: rangeText,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }
}

