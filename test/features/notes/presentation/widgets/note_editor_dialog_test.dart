import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_editor_dialog.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  tearDown(() async {
    await cubit.close();
  });

  Widget buildTestWidget({
    required int surahNumber,
    required int verseNumber,
    int? pageNumber,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: Scaffold(
              body: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      NoteEditorDialog.show(
                        context: ctx,
                        surahNumber: surahNumber,
                        verseNumber: verseNumber,
                        pageNumber: pageNumber,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('NoteEditorDialog Widget Tests (Reference 29)', () {
    testWidgets('renders header with Surah name and Arabic numeral (البقرة: ٤)', (tester) async {
      await tester.pumpWidget(buildTestWidget(surahNumber: 2, verseNumber: 4));
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify header text
      expect(find.text('البقرة: ٤'), findsOneWidget);

      // Verify action icons: Close, Share, Add note (+)
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

      // Verify quoted Ayah is rendered inside dialog
      const meta = QuranMetadataService();
      final verseText = meta.getVerse(2, 4);
      expect(find.text('{$verseText}'), findsOneWidget);
    });

    testWidgets('plus-circle saves current note and starts fresh note session on same Ayah', (tester) async {
      await tester.pumpWidget(buildTestWidget(surahNumber: 2, verseNumber: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter first note text
      await tester.enterText(find.byType(TextField), 'الملاحظة الأولى');
      await tester.pump();

      // Tap add another note (+)
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Verify first note was saved in Cubit
      expect(cubit.state.notes.length, equals(1));
      expect(cubit.state.notes.first.noteText, equals('الملاحظة الأولى'));

      // Verify text field was cleared and remains open for the new note
      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);

      // Enter second note
      await tester.enterText(find.byType(TextField), 'الملاحظة الثانية لنفس الآية');
      await tester.pump();

      // Tap close icon to save second note and pop
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Both notes should now be persisted in Cubit
      expect(cubit.state.notes.length, equals(2));
      final notes = cubit.state.getNotesForAyah(2, 4);
      expect(notes.length, equals(2));
    });

    testWidgets('closing dialog saves valid entered note', (tester) async {
      await tester.pumpWidget(buildTestWidget(surahNumber: 2, verseNumber: 4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'تدبر خاص');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(cubit.state.notes.length, equals(1));
      expect(cubit.state.notes.first.noteText, equals('تدبر خاص'));
    });
  });
}
