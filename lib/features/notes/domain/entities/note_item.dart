/// Domain entity representing a user reflection or note linked to a specific Quran verse.
/// Pure Dart — no Flutter framework dependencies.
class NoteItem {
  final String id;
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final String noteText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NoteItem({
    required this.id,
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.noteText,
    required this.createdAt,
    this.updatedAt,
  });

  /// Canonical verse key identifier (e.g. "2:4").
  String get ayahKey => '$surahNumber:$verseNumber';

  NoteItem copyWith({
    String? id,
    int? surahNumber,
    int? verseNumber,
    int? pageNumber,
    String? noteText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteItem(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          surahNumber == other.surahNumber &&
          verseNumber == other.verseNumber &&
          pageNumber == other.pageNumber &&
          noteText == other.noteText;

  @override
  int get hashCode => Object.hash(id, surahNumber, verseNumber, pageNumber, noteText);

  @override
  String toString() =>
      'NoteItem(id: $id, $surahNumber:$verseNumber, page $pageNumber, text: ${noteText.length > 20 ? "${noteText.substring(0, 20)}..." : noteText})';
}

