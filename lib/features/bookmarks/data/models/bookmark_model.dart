import 'dart:convert';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';

/// Data model representing a Quran bookmark in local storage.
///
/// Fully backwards-compatible with legacy stored maps:
/// `{"name": "...", "suraNumber": 2, "verseNumber": 6, "color": "..."}`
class BookmarkModel {
  final String id;
  final String name;
  final String colorHex;
  final int? surahNumber;
  final int? verseNumber;
  final int? pageNumber;
  final DateTime? updatedAt;
  final bool isDefault;

  BookmarkModel({
    String? id,
    required this.name,
    String? colorHex,
    String? color,
    int? surahNumber,
    int? suraNumber,
    this.verseNumber,
    this.pageNumber,
    this.updatedAt,
    this.isDefault = false,
  }) : id =
           id ??
           (suraNumber != null ? 'slot_${suraNumber}_$verseNumber' : 'red'),
       colorHex = _normalizeColor(colorHex, color),
       surahNumber = surahNumber ?? suraNumber;

  static String _normalizeColor(String? colorHex, String? color) {
    if (colorHex != null && colorHex.isNotEmpty) {
      return colorHex.startsWith('#') ? colorHex : '#$colorHex';
    }
    if (color != null && color.isNotEmpty) {
      return color.startsWith('#') ? color : '#$color';
    }
    return '#C9484A';
  }

  /// Backward-compatibility getter for legacy code.
  int get suraNumber => surahNumber ?? 0;

  /// Backward-compatibility getter for legacy color string without `#`.
  /// Ensures 8 hex characters by prepending 'FF' when length is 6,
  /// so legacy callers doing `Color(int.parse("0x${bookmark.color}"))`
  /// have a non-zero (opaque) alpha channel.
  String get color {
    final clean = colorHex.replaceFirst('#', '');
    return clean.length == 6 ? 'FF$clean' : clean;
  }

  /// Converts this model to a domain [BookmarkItem].
  BookmarkItem toEntity() {
    return BookmarkItem(
      id: id,
      name: name,
      colorHex: colorHex,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      pageNumber: pageNumber,
      updatedAt: updatedAt,
      isDefault: isDefault,
    );
  }

  /// Creates a model from a domain [BookmarkItem].
  factory BookmarkModel.fromEntity(BookmarkItem item) {
    return BookmarkModel(
      id: item.id,
      name: item.name,
      colorHex: item.colorHex,
      surahNumber: item.surahNumber,
      verseNumber: item.verseNumber,
      pageNumber: item.pageNumber,
      updatedAt: item.updatedAt,
      isDefault: item.isDefault,
    );
  }

  /// Serializes to a Map preserving both modern and legacy keys.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'color': color,
      'surahNumber': surahNumber,
      'suraNumber': suraNumber,
      'verseNumber': verseNumber,
      'pageNumber': pageNumber,
      'updatedAt': updatedAt?.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  /// Deserializes from a Map, handling both new schema and legacy schema.
  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    final rawSurah = map['surahNumber'] ?? map['suraNumber'];
    final surah = rawSurah is int
        ? rawSurah
        : (int.tryParse(rawSurah?.toString() ?? ''));
    final rawVerse = map['verseNumber'];
    final verse = rawVerse is int
        ? rawVerse
        : (int.tryParse(rawVerse?.toString() ?? ''));
    final rawPage = map['pageNumber'];
    final page = rawPage is int
        ? rawPage
        : (int.tryParse(rawPage?.toString() ?? ''));

    final rawUpdated = map['updatedAt'];
    DateTime? updated;
    if (rawUpdated is String) {
      updated = DateTime.tryParse(rawUpdated);
    }

    final id =
        map['id']?.toString() ??
        (surah != null && verse != null ? 'slot_${surah}_$verse' : 'default');

    final name = map['name']?.toString() ?? '';
    final colorHex =
        map['colorHex']?.toString() ?? map['color']?.toString() ?? '#C9484A';
    final isDefault = map['isDefault'] as bool? ?? false;

    return BookmarkModel(
      id: id,
      name: name,
      colorHex: colorHex,
      surahNumber: surah,
      verseNumber: verse,
      pageNumber: page,
      updatedAt: updated,
      isDefault: isDefault,
    );
  }

  factory BookmarkModel.fromJson(String source) =>
      BookmarkModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookmarkModel) return false;

    if (id.isNotEmpty && other.id.isNotEmpty && id == other.id) {
      return name == other.name &&
          colorHex == other.colorHex &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber &&
          pageNumber == other.pageNumber;
    }

    return other.suraNumber == suraNumber &&
        other.verseNumber == verseNumber &&
        other.name == name;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorHex, surahNumber, verseNumber, pageNumber);
}
