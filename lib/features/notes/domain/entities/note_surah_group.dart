import 'note_item.dart';

/// Domain entity representing notes grouped under a specific Surah header.
/// Matches reference screenshot 30.
class NoteSurahGroup {
  final int surahNumber;
  final String surahName;
  final List<NoteItem> notes;

  const NoteSurahGroup({
    required this.surahNumber,
    required this.surahName,
    required this.notes,
  });

  /// Groups a flat list of [NoteItem]s deterministically:
  /// 1. Grouped by [surahNumber].
  /// 2. Surahs sorted in Quranic order (surahNumber ascending: 1 -> 114).
  /// 3. Within each surah, verses sorted in verse order (verseNumber ascending: 1 -> N).
  /// 4. When multiple notes exist on the same verse, sorted by [createdAt] descending (newest first).
  static List<NoteSurahGroup> groupNotes({
    required List<NoteItem> items,
    required String Function(int surahNumber) surahNameResolver,
  }) {
    if (items.isEmpty) return const [];

    final Map<int, List<NoteItem>> map = {};
    for (final item in items) {
      map.putIfAbsent(item.surahNumber, () => <NoteItem>[]).add(item);
    }

    final sortedSurahNumbers = map.keys.toList()..sort();
    final List<NoteSurahGroup> result = [];

    for (final surahNumber in sortedSurahNumbers) {
      final surahNotes = map[surahNumber]!;
      surahNotes.sort((a, b) {
        final verseComparison = a.verseNumber.compareTo(b.verseNumber);
        if (verseComparison != 0) return verseComparison;
        // Same verse: newest note first
        return b.createdAt.compareTo(a.createdAt);
      });

      final surahName = surahNameResolver(surahNumber);
      result.add(
        NoteSurahGroup(
          surahNumber: surahNumber,
          surahName: surahName,
          notes: List.unmodifiable(surahNotes),
        ),
      );
    }

    return List.unmodifiable(result);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteSurahGroup) return false;
    if (surahNumber != other.surahNumber || surahName != other.surahName) {
      return false;
    }
    if (notes.length != other.notes.length) return false;
    for (int i = 0; i < notes.length; i++) {
      if (notes[i] != other.notes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        surahNumber,
        surahName,
        Object.hashAll(notes),
      );

  @override
  String toString() =>
      'NoteSurahGroup(surah: $surahName (#$surahNumber), count: ${notes.length})';
}

