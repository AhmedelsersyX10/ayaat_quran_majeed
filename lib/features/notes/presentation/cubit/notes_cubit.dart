import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_surah_group.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/repositories/notes_repository.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_state.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _repository;
  final QuranMetadataService _metadataService;

  NotesCubit({
    required NotesRepository repository,
    QuranMetadataService? metadataService,
  })  : _repository = repository,
        _metadataService = metadataService ?? const QuranMetadataService(),
        super(NotesState.initial());

  /// Loads all stored notes and computes groups and index maps.
  Future<void> loadNotes() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final items = await _repository.getNotes();
      _emitUpdatedNotes(items);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Adds a new note or updates an existing note.
  ///
  /// If [noteText] is empty or whitespace:
  /// - If [id] exists, deletes the note.
  /// - Otherwise ignores the operation.
  Future<NoteItem?> addOrUpdateNote({
    String? id,
    required int surahNumber,
    required int verseNumber,
    int? pageNumber,
    required String noteText,
  }) async {
    final trimmed = noteText.trim();
    if (trimmed.isEmpty) {
      if (id != null && id.isNotEmpty) {
        await deleteNote(id);
      }
      return null;
    }

    final now = DateTime.now();
    final resolvedPage = pageNumber ??
        _metadataService.getPageNumber(surahNumber, verseNumber);

    NoteItem targetNote;
    if (id != null && id.isNotEmpty) {
      final existing = state.notes.firstWhere(
        (n) => n.id == id,
        orElse: () => NoteItem(
          id: id,
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: resolvedPage,
          noteText: trimmed,
          createdAt: now,
        ),
      );
      targetNote = existing.copyWith(
        noteText: trimmed,
        pageNumber: resolvedPage,
        updatedAt: now,
      );
    } else {
      final newId = '${surahNumber}_${verseNumber}_${now.microsecondsSinceEpoch}';
      targetNote = NoteItem(
        id: newId,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        pageNumber: resolvedPage,
        noteText: trimmed,
        createdAt: now,
      );
    }

    await _repository.saveNote(targetNote);

    final updatedNotes = List<NoteItem>.from(state.notes);
    final idx = updatedNotes.indexWhere((n) => n.id == targetNote.id);
    if (idx >= 0) {
      updatedNotes[idx] = targetNote;
    } else {
      updatedNotes.add(targetNote);
    }

    _emitUpdatedNotes(updatedNotes);
    return targetNote;
  }

  /// Deletes a note by its identifier.
  Future<void> deleteNote(String noteId) async {
    await _repository.deleteNote(noteId);
    final updatedNotes = state.notes.where((n) => n.id != noteId).toList();
    _emitUpdatedNotes(updatedNotes);
  }

  bool hasNotes(int surahNumber, int verseNumber) {
    return state.hasNotesForAyah(surahNumber, verseNumber);
  }

  void _emitUpdatedNotes(List<NoteItem> items) {
    final groups = NoteSurahGroup.groupNotes(
      items: items,
      surahNameResolver: _metadataService.getSurahNameArabic,
    );

    final Map<String, List<NoteItem>> notesByAyah = {};
    for (final note in items) {
      notesByAyah.putIfAbsent(note.ayahKey, () => <NoteItem>[]).add(note);
    }

    // Sort notes for each ayah descending by creation date (newest first)
    for (final key in notesByAyah.keys) {
      notesByAyah[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    emit(state.copyWith(
      isLoading: false,
      notes: List.unmodifiable(items),
      groups: List.unmodifiable(groups),
      notesByAyah: Map.unmodifiable(notesByAyah),
      errorMessage: null,
    ));
  }
}

