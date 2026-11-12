import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/views/notes_tab_view.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_editor_dialog.dart';
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

  Widget buildTestWidget(NotesCubit notesCubit) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider<NotesCubit>.value(
            value: notesCubit,
            child: const NotesTabView(),
          ),
        ),
      ),
    );
  }

  group('NotesTabView Widget Tests (Screens 13 & 30)', () {
    testWidgets('renders empty state matching screen 13 when no notes exist', (tester) async {
      await cubit.loadNotes();

      await tester.pumpWidget(buildTestWidget(cubit));
      await tester.pumpAndSettle();

      // Title in AppBar
      expect(find.text(AppStrings.tr(AppStrings.notesTitle)), findsOneWidget);

      // Empty state text
      expect(find.text(AppStrings.tr(AppStrings.emptyNotesTitle)), findsOneWidget);
    });

    testWidgets('renders populated list matching screen 30 with Surah header and note card', (tester) async {
      await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الايه الاقرب لقلبي',
      );

      await tester.pumpWidget(buildTestWidget(cubit));
      await tester.pumpAndSettle();

      // 1. Title in AppBar
      expect(find.text(AppStrings.tr(AppStrings.notesTitle)), findsOneWidget);

      // 2. Surah header: "البقرة"
      expect(find.text('البقرة'), findsOneWidget);

      // 3. Subline matching formatPageAyahLabel: "البقرة: ٤ - الصفحة ٢"
      final expectedSubline = formatPageAyahLabel(
        surahName: 'البقرة',
        ayahNumber: 4,
        pageNumber: 2,
      );
      expect(find.text(expectedSubline), findsOneWidget);

      // 4. Note text contains user reflection
      expect(find.textContaining('الايه الاقرب لقلبي'), findsOneWidget);
    });

    testWidgets('tapping note card opens NoteEditorDialog for that note', (tester) async {
      await cubit.addOrUpdateNote(
        surahNumber: 2,
        verseNumber: 4,
        pageNumber: 2,
        noteText: 'الايه الاقرب لقلبي',
      );

      await tester.pumpWidget(buildTestWidget(cubit));
      await tester.pumpAndSettle();

      // Tap the note card
      await tester.tap(find.textContaining('الايه الاقرب لقلبي'));
      await tester.pumpAndSettle();

      // NoteEditorDialog should now be visible
      expect(find.byType(NoteEditorDialog), findsOneWidget);
      expect(find.text('البقرة: ٤'), findsOneWidget);
      expect(find.text('الايه الاقرب لقلبي'), findsOneWidget);
    });
  });
}

