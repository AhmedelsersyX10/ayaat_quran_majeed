import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_state.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_editor_dialog.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_surah_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Tab 4: Notes View ("الملاحظات").
/// Pixel-faithful implementation matching reference screenshots 13 (empty) & 30 (populated).
class NotesTabView extends StatefulWidget {
  const NotesTabView({super.key});

  @override
  State<NotesTabView> createState() => _NotesTabViewState();
}

class _NotesTabViewState extends State<NotesTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    try {
      context.read<NotesCubit>();
      return BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) => _buildView(context, state),
      );
    } catch (_) {
      if (sl.isRegistered<NotesCubit>()) {
        return BlocProvider.value(
          value: sl<NotesCubit>()..loadNotes(),
          child: BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) => _buildView(context, state),
          ),
        );
      }
      return _buildView(
        context,
        const NotesState(
          isLoading: false,
          notes: [],
          groups: [],
          notesByAyah: {},
        ),
      );
    }
  }

  Widget _buildView(BuildContext context, NotesState state) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          AppStrings.tr(AppStrings.notesTitle),
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.isEmpty
                ? _buildEmptyState(colors)
                : _buildPopulatedList(context, state),
      ),
    );
  }

  /// Empty state matching reference screenshot 13_notes_empty.
  Widget _buildEmptyState(dynamic colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          AppStrings.tr(AppStrings.emptyNotesTitle),
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Populated list matching reference screenshot 30_notes_list_with_data.
  Widget _buildPopulatedList(BuildContext context, NotesState state) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: state.groups.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final group = state.groups[index];
        return NoteSurahGroupCard(
          group: group,
          onNoteTap: (note) => _openNoteEditor(context, note),
          onNoteDelete: (note) => _confirmDeleteNote(context, note),
          onNavigateToMushaf: (note) => _navigateToAyah(context, note),
        );
      },
    );
  }

  void _openNoteEditor(BuildContext context, NoteItem note) {
    NoteEditorDialog.show(
      context: context,
      surahNumber: note.surahNumber,
      verseNumber: note.verseNumber,
      pageNumber: note.pageNumber,
      existingNote: note,
    );
  }

  void _confirmDeleteNote(BuildContext context, NoteItem note) {
    final cubit = context.read<NotesCubit>();
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.tr(AppStrings.notesTitle)),
        content: Text(AppStrings.tr(AppStrings.noteDeleted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.tr(AppStrings.cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              cubit.deleteNote(note.id);
            },
            child: Text(
              AppStrings.tr(AppStrings.delete),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAyah(BuildContext context, NoteItem note) {
    context.pushNamed(
      AppRoutes.readerName,
      queryParameters: {
        'page': note.pageNumber.toString(),
        'surah': note.surahNumber.toString(),
        'ayah': note.verseNumber.toString(),
      },
    );
  }
}
