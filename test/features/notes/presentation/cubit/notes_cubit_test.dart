import 'package:ayaat_quran_majeed/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/notes_repository_impl_test.dart';

void main() {
  late FakeNotesLocalDataSource fakeDataSource;
  late NotesRepositoryImpl repository;
  late NotesCubit cubit;

  setUp(() {
    fakeDataSource = FakeNotesLocalDataSource();
    repository = NotesRepositoryImpl(localDataSource: fakeDataSource);
    cubit = NotesCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('NotesCubit State & Logic Tests', () {
    test('initial state has correct defaults', () {
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.notes, isEmpty);
      expect(cubit.state.groups, isEmpty);
      expect(cubit.state.notesByAyah, isEmpty);
      expect(cubit.state.isEmpty, isTrue);
    });

    test('loadNotes fetches stored notes and updates groups', () async {
      await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        noteText: 'الايه الاقرب لقلبي',
      );

      expect(cubit.state.notes.length, equals(1));
      expect(cubit.state.groups.length, equals(1));
      expect(cubit.state.hasNotes, isTrue);
      expect(cubit.hasNotes(2, 4), isTrue);
      expect(cubit.hasNotes(2, 5), isFalse);
    });

    test('adding multiple notes to same ayah creates separate entries ordered newest first', () async {
      // First note on 2:4
      final note1 = await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        noteText: 'ملاحظة أولى',
      );

      // Brief delay to ensure distinct timestamp
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // Second note on 2:4 via plus-circle logic
      final note2 = await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        noteText: 'ملاحظة ثانية لنفس الآية',
      );

      expect(note1, isNotNull);
      expect(note2, isNotNull);
      expect(cubit.state.notes.length, equals(2));

      final ayahNotes = cubit.state.getNotesForAyah(2, 4);
      expect(ayahNotes.length, equals(2));
      // First in the list should be the newest note (note2)
      expect(ayahNotes[0].id, equals(note2!.id));
      expect(ayahNotes[1].id, equals(note1!.id));
    });

    test('addOrUpdateNote with empty text and existing ID deletes the note', () async {
      final note = await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        noteText: 'ستحذف قريبا',
      );
      expect(cubit.state.notes.length, equals(1));

      // Update with empty text
      final res = await cubit.addOrUpdateNote(
        id: note!.id,
        surahNumber: 2,
        verseNumber: 4,
        noteText: '   ',
      );

      expect(res, isNull);
      expect(cubit.state.notes, isEmpty);
      expect(cubit.hasNotes(2, 4), isFalse);
    });

    test('addOrUpdateNote with empty text and no ID is ignored', () async {
      final res = await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        noteText: '   ',
      );

      expect(res, isNull);
      expect(cubit.state.notes, isEmpty);
    });

    test('deleteNote removes note and clears lookup map', () async {
      final note = await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        noteText: 'ملاحظة للحذف',
      );
      expect(cubit.state.notes.length, equals(1));

      await cubit.deleteNote(note!.id);
      expect(cubit.state.notes, isEmpty);
      expect(cubit.state.hasNotes, isFalse);
      expect(cubit.hasNotes(2, 4), isFalse);
    });
  });
}

