import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_surah_group.dart';

class NotesState {
  final bool isLoading;
  final List<NoteItem> notes;
  final List<NoteSurahGroup> groups;
  final Map<String, List<NoteItem>> notesByAyah;
  final String? errorMessage;

  const NotesState({
    required this.isLoading,
    required this.notes,
    required this.groups,
    required this.notesByAyah,
    this.errorMessage,
  });

  factory NotesState.initial() => const NotesState(
        isLoading: false,
        notes: [],
        groups: [],
        notesByAyah: {},
      );

  bool get isEmpty => !isLoading && notes.isEmpty;
  bool get hasNotes => notes.isNotEmpty;

  bool hasNotesForAyah(int surahNumber, int verseNumber) {
    final key = '$surahNumber:$verseNumber';
    return notesByAyah.containsKey(key) && notesByAyah[key]!.isNotEmpty;
  }

  List<NoteItem> getNotesForAyah(int surahNumber, int verseNumber) {
    final key = '$surahNumber:$verseNumber';
    return notesByAyah[key] ?? const [];
  }

  NotesState copyWith({
    bool? isLoading,
    List<NoteItem>? notes,
    List<NoteSurahGroup>? groups,
    Map<String, List<NoteItem>>? notesByAyah,
    String? errorMessage,
  }) {
    return NotesState(
      isLoading: isLoading ?? this.isLoading,
      notes: notes ?? this.notes,
      groups: groups ?? this.groups,
      notesByAyah: notesByAyah ?? this.notesByAyah,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotesState) return false;
    if (isLoading != other.isLoading ||
        errorMessage != other.errorMessage ||
        notes.length != other.notes.length ||
        groups.length != other.groups.length) {
      return false;
    }
    for (int i = 0; i < notes.length; i++) {
      if (notes[i] != other.notes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        errorMessage,
        Object.hashAll(notes),
        Object.hashAll(groups),
      );
}

