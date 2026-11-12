import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';

/// Contract boundary for notes persistence and retrieval.
/// Pure Dart — no Flutter framework dependencies.
abstract class NotesRepository {
  /// Loads all user notes.
  Future<List<NoteItem>> getNotes();

  /// Creates or updates a note.
  Future<void> saveNote(NoteItem note);

  /// Deletes a specific note by its unique identifier.
  Future<void> deleteNote(String noteId);

  /// Retrieves all notes associated with a given verse.
  Future<List<NoteItem>> getNotesForAyah(int surahNumber, int verseNumber);
}

