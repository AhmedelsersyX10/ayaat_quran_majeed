import 'dart:convert';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Data Transfer Object for persisting user notes.
///
/// Keeps stored payload focused on user reflection text, surah/verse references,
/// and timestamps, resolving display text and page numbers through [QuranMetadataService].
class NoteModel {
  final String id;
  final int surahNumber;
  final int verseNumber;
  final int? pageNumber;
  final String noteText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.surahNumber,
    required this.verseNumber,
    this.pageNumber,
    required this.noteText,
    required this.createdAt,
    this.updatedAt,
  });

  String get ayahKey => '$surahNumber:$verseNumber';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      if (pageNumber != null) 'pageNumber': pageNumber,
      'noteText': noteText,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['id']?.toString() ?? '';
    final surah = (map['surahNumber'] ?? map['surah'] ?? map['surah_number'] ?? 0) as int;
    final verse = (map['verseNumber'] ?? map['ayah'] ?? map['verse'] ?? map['verse_number'] ?? 0) as int;
    final page = (map['pageNumber'] ?? map['page'] ?? map['page_number']) as int?;
    final text = (map['noteText'] ?? map['text'] ?? map['note'] ?? map['content'] ?? '').toString();

    DateTime created;
    final rawCreated = map['createdAt'] ?? map['created_at'];
    if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    DateTime? updated;
    final rawUpdated = map['updatedAt'] ?? map['updated_at'];
    if (rawUpdated is String) {
      updated = DateTime.tryParse(rawUpdated);
    }

    final id = rawId.isNotEmpty
        ? rawId
        : '${surah}_${verse}_${created.millisecondsSinceEpoch}';

    return NoteModel(
      id: id,
      surahNumber: surah,
      verseNumber: verse,
      pageNumber: page,
      noteText: text,
      createdAt: created,
      updatedAt: updated,
    );
  }

  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static NoteModel? tryParse(dynamic raw) {
    if (raw == null) return null;
    if (raw is NoteModel) return raw;

    if (raw is Map) {
      try {
        final map = Map<String, dynamic>.from(raw);
        final model = NoteModel.fromMap(map);
        if (model.surahNumber > 0 && model.verseNumber > 0) return model;
      } catch (_) {}
    }

    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map) {
            return NoteModel.fromMap(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      }
    }

    return null;
  }

  factory NoteModel.fromEntity(NoteItem entity) {
    return NoteModel(
      id: entity.id,
      surahNumber: entity.surahNumber,
      verseNumber: entity.verseNumber,
      pageNumber: entity.pageNumber,
      noteText: entity.noteText,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  NoteItem toEntity({QuranMetadataService? metadataService}) {
    final meta = metadataService ?? const QuranMetadataService();
    final surah = surahNumber.clamp(1, 114);
    final maxAyah = meta.getVerseCount(surah);
    final safeAyah = verseNumber.clamp(1, maxAyah > 0 ? maxAyah : 286);
    final resolvedPage = pageNumber ?? meta.getPageNumber(surah, safeAyah);

    return NoteItem(
      id: id,
      surahNumber: surah,
      verseNumber: safeAyah,
      pageNumber: resolvedPage,
      noteText: noteText,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber &&
          noteText == other.noteText;

  @override
  int get hashCode => Object.hash(id, surahNumber, verseNumber, noteText);
}

