import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single note item card matching reference screenshot 30_notes_list_with_data.
class NoteCardItem extends StatelessWidget {
  final NoteItem note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onNavigateToMushaf;

  const NoteCardItem({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
    this.onNavigateToMushaf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const meta = QuranMetadataService();
    final surahName = meta.getSurahNameArabic(note.surahNumber);
    final ayahText = meta.getVerse(note.surahNumber, note.verseNumber);
    final sublineLabel = formatPageAyahLabel(
      surahName: surahName,
      ayahNumber: note.verseNumber,
      pageNumber: note.pageNumber,
    );

    return Dismissible(
      key: ValueKey('note_${note.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: AppRadii.radiusMd,
        ),
        child: Icon(
          Icons.delete_outline,
          color: colors.surface,
          size: 24.sp,
        ),
      ),
      confirmDismiss: (_) async {
        if (onDelete != null) {
          onDelete!();
          return false; // Handled by callback
        }
        return true;
      },
      child: AppCard(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Note text + Quoted Ayah: "[noteText] {[ayahText]}"
            Text.rich(
              TextSpan(
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  height: 1.6,
                ),
                children: [
                  if (note.noteText.isNotEmpty) ...[
                    TextSpan(
                      text: '${note.noteText} ',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  TextSpan(
                    text: '{$ayahText}',
                    style: AppTypography.quranText.copyWith(
                      color: colors.textPrimary,
                      fontSize: 15.sp,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),

            SizedBox(height: 10.h),

            // 2. Subline: "البقرة: ٤ - الصفحة ٢"
            InkWell(
              onTap: onNavigateToMushaf ?? onTap,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  sublineLabel,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
