import 'package:ayaat_quran_majeed/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/notes/data/models/note_model.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/repositories/notes_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource _localDataSource;
  final QuranMetadataService _metadataService;

  NotesRepositoryImpl({
    required NotesLocalDataSource localDataSource,
    QuranMetadataService? metadataService,
  })  : _localDataSource = localDataSource,
        _metadataService = metadataService ?? const QuranMetadataService();

  @override
  Future<List<NoteItem>> getNotes() async {
    final models = await _localDataSource.getNotes();
    return models
        .map((m) => m.toEntity(metadataService: _metadataService))
        .toList(growable: false);
  }

  @override
  Future<void> saveNote(NoteItem note) async {
    final models = (await _localDataSource.getNotes()).toList();
    final newModel = NoteModel.fromEntity(note);

    final existingIndex = models.indexWhere((m) => m.id == note.id);
    if (existingIndex >= 0) {
      models[existingIndex] = newModel;
    } else {
      models.add(newModel);
    }

    await _localDataSource.saveNotes(models);
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final models = (await _localDataSource.getNotes()).toList();
    models.removeWhere((m) => m.id == noteId);
    await _localDataSource.saveNotes(models);
  }

  @override
  Future<List<NoteItem>> getNotesForAyah(int surahNumber, int verseNumber) async {
    final all = await getNotes();
    return all
        .where((n) => n.surahNumber == surahNumber && n.verseNumber == verseNumber)
        .toList(growable: false);
  }
}

