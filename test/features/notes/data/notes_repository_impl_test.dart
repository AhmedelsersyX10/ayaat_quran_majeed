import 'package:ayaat_quran_majeed/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/notes/data/models/note_model.dart';
import 'package:ayaat_quran_majeed/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotesLocalDataSource implements NotesLocalDataSource {
  List<NoteModel> storage = [];

  @override
  Future<List<NoteModel>> getNotes() async {
    return List.from(storage);
  }

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    storage = List.from(notes);
  }
}

void main() {
  late FakeNotesLocalDataSource fakeDataSource;
  late NotesRepositoryImpl repository;
  final testDate = DateTime(2026, 11, 12, 10, 0, 0);

  setUp(() {
    fakeDataSource = FakeNotesLocalDataSource();
    repository = NotesRepositoryImpl(localDataSource: fakeDataSource);
  });

  group('NotesRepositoryImpl Tests', () {
    test('getNotes returns empty list when local data source is empty', () async {
      final notes = await repository.getNotes();
      expect(notes, isEmpty);
    });

    test('saveNote inserts new note and updates existing note by id', () async {
      final note1 = NoteItem(
        id: 'n1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'ملاحظة أولى',
        createdAt: testDate,
      );

      await repository.saveNote(note1);

      var notes = await repository.getNotes();
      expect(notes.length, equals(1));
      expect(notes.first.noteText, equals('ملاحظة أولى'));

      // Update existing note
      final updatedNote1 = note1.copyWith(noteText: 'ملاحظة محدثة');
      await repository.saveNote(updatedNote1);

      notes = await repository.getNotes();
      expect(notes.length, equals(1));
      expect(notes.first.noteText, equals('ملاحظة محدثة'));
    });

    test('deleteNote removes note with matching id', () async {
      final note1 = NoteItem(
        id: 'n1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'ملاحظة 1',
        createdAt: testDate,
      );
      final note2 = NoteItem(
        id: 'n2',
        surahNumber: 2,
        verseNumber: 5,
        pageNumber: 2,
        noteText: 'ملاحظة 2',
        createdAt: testDate,
      );

      await repository.saveNote(note1);
      await repository.saveNote(note2);

      expect((await repository.getNotes()).length, equals(2));

      await repository.deleteNote('n1');

      final remaining = await repository.getNotes();
      expect(remaining.length, equals(1));
      expect(remaining.first.id, equals('n2'));
    });

    test('getNotesForAyah returns only notes matching target surah and verse', () async {
      final note1 = NoteItem(
        id: 'n1',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الملاحظة 1 على 2:4',
        createdAt: testDate,
      );
      final note2 = NoteItem(
        id: 'n2',
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الملاحظة 2 على 2:4',
        createdAt: testDate.add(const Duration(hours: 1)),
      );
      final note3 = NoteItem(
        id: 'n3',
        surahNumber: 3,
        verseNumber: 10,
        pageNumber: 51,
        noteText: 'ملاحظة على آل عمران',
        createdAt: testDate,
      );

      await repository.saveNote(note1);
      await repository.saveNote(note2);
      await repository.saveNote(note3);

      final ayahNotes = await repository.getNotesForAyah(2, 4);
      expect(ayahNotes.length, equals(2));
      expect(ayahNotes.any((n) => n.id == 'n1'), isTrue);
      expect(ayahNotes.any((n) => n.id == 'n2'), isTrue);
      expect(ayahNotes.any((n) => n.id == 'n3'), isFalse);
    });
  });
}

