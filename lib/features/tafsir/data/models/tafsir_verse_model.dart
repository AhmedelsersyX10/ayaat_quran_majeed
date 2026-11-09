import '../../domain/entities/tafsir_verse.dart';

/// Data model representing a verse Tafsir or translation record.
class TafsirVerseModel {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String text;

  const TafsirVerseModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  /// Factory constructor parsing from JSON map with defensive type conversions.
  factory TafsirVerseModel.fromJson(Map<String, dynamic> json) {
    final rawText = json['text'] as String? ?? '';
    final cleanedText = _cleanHtmlText(rawText);

    return TafsirVerseModel(
      id: _parseNumber(json['id']),
      surahNumber: _parseNumber(json['sura']),
      ayahNumber: _parseNumber(json['aya']),
      text: cleanedText,
    );
  }

  /// Converts this model to pure domain entity [TafsirVerse].
  TafsirVerse toEntity({required String bookId}) {
    return TafsirVerse(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: text,
      bookId: bookId,
    );
  }

  /// Serializes to JSON map matching external dataset schema.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sura': surahNumber,
      'aya': ayahNumber,
      'text': text,
    };
  }

  static int _parseNumber(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static final RegExp _htmlTagPattern = RegExp(r'<[^>]*>', multiLine: true);
  static final RegExp _brPattern = RegExp(r'<br\s*/?>', caseSensitive: false);

  /// Strips layout HTML tags while preserving textual and religious content verbatim.
  static String _cleanHtmlText(String input) {
    if (input.isEmpty) return '';
    // Replace <br> with standard newlines
    var result = input.replaceAll(_brPattern, '\n');
    // Remove structural HTML tags like <p>, </p>, <span>
    result = result.replaceAll(_htmlTagPattern, '');
    return result.trim();
  }
}

