import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_surah_group.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Group card displaying notes under a Surah header.
/// Matches reference screenshot 30_notes_list_with_data.
class NoteSurahGroupCard extends StatelessWidget {
  final NoteSurahGroup group;
  final ValueChanged<NoteItem> onNoteTap;
  final ValueChanged<NoteItem>? onNoteDelete;
  final ValueChanged<NoteItem>? onNavigateToMushaf;

  const NoteSurahGroupCard({
    super.key,
    required this.group,
    required this.onNoteTap,
    this.onNoteDelete,
    this.onNavigateToMushaf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Surah Name Section Header (e.g. "البقرة")
        Padding(
          padding: EdgeInsets.only(
            bottom: 8.h,
            right: 4.w,
            left: 4.w,
          ),
          child: Text(
            group.surahName,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTypography.titleSmall.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),

        // 2. Column of Note cards
        ...List.generate(group.notes.length, (index) {
          final note = group.notes[index];
          final isLast = index == group.notes.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
            child: NoteCardItem(
              note: note,
              onTap: () => onNoteTap(note),
              onDelete: onNoteDelete != null ? () => onNoteDelete!(note) : null,
              onNavigateToMushaf: onNavigateToMushaf != null
                  ? () => onNavigateToMushaf!(note)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

