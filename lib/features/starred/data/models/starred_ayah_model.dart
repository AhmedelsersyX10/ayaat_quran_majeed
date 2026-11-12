import 'dart:convert';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Data transfer object for storing and serializing starred Quran verses.
///
/// Keeps stored payload minimal (surah and ayah identifiers + timestamp),
/// resolving display text, surah name, and page number through [QuranMetadataService].
class StarredAyahModel {
  final int surahNumber;
  final int verseNumber;
  final DateTime? createdAt;

  const StarredAyahModel({
    required this.surahNumber,
    required this.verseNumber,
    this.createdAt,
  });

  String get key => '$surahNumber:$verseNumber';

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory StarredAyahModel.fromMap(Map<String, dynamic> map) {
    final surah = (map['surahNumber'] ?? map['surah'] ?? map['surah_number'] ?? 0) as int;
    final verse = (map['verseNumber'] ?? map['ayah'] ?? map['verse'] ?? map['verse_number'] ?? 0) as int;
    final rawDate = map['createdAt'] ?? map['created_at'];
    DateTime? date;
    if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    }
    return StarredAyahModel(
      surahNumber: surah,
      verseNumber: verse,
      createdAt: date,
    );
  }

  factory StarredAyahModel.fromJson(String source) =>
      StarredAyahModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Robust parser for diverse raw storage shapes (strings like "2:255" or "2-255", maps, etc.).
  static StarredAyahModel? tryParse(dynamic raw) {
    if (raw == null) return null;

    if (raw is StarredAyahModel) return raw;

    if (raw is Map) {
      try {
        final map = Map<String, dynamic>.from(raw);
        final model = StarredAyahModel.fromMap(map);
        if (model.surahNumber > 0 && model.verseNumber > 0) return model;
      } catch (_) {}
    }

    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;

      // Try JSON object first
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map) {
            return StarredAyahModel.fromMap(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      }

      // Legacy string formats: "surah:verse" or "surah-verse"
      String separator = '';
      if (trimmed.contains(':')) {
        separator = ':';
      } else if (trimmed.contains('-')) {
        separator = '-';
      }

      if (separator.isNotEmpty) {
        final parts = trimmed.split(separator);
        if (parts.length >= 2) {
          final surah = int.tryParse(parts[0].trim());
          final verse = int.tryParse(parts[1].trim());
          if (surah != null && verse != null && surah > 0 && verse > 0) {
            return StarredAyahModel(
              surahNumber: surah,
              verseNumber: verse,
            );
          }
        }
      }
    }

    return null;
  }

  factory StarredAyahModel.fromEntity(StarredAyahItem entity) {
    return StarredAyahModel(
      surahNumber: entity.surahNumber,
      verseNumber: entity.verseNumber,
      createdAt: entity.createdAt,
    );
  }

  StarredAyahItem toEntity({QuranMetadataService? metadataService}) {
    final meta = metadataService ?? const QuranMetadataService();
    final surah = surahNumber.clamp(1, 114);
    final maxAyah = meta.getVerseCount(surah);
    final safeAyah = verseNumber.clamp(1, maxAyah > 0 ? maxAyah : 286);

    return StarredAyahItem(
      surahNumber: surah,
      verseNumber: safeAyah,
      pageNumber: meta.getPageNumber(surah, safeAyah),
      ayahText: meta.getVerse(surah, safeAyah),
      surahName: meta.getSurahNameArabic(surah),
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StarredAyahModel &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode => Object.hash(surahNumber, verseNumber);
}

