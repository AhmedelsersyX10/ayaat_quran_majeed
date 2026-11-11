import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_dialog_shell.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_edit_dialog.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

/// Dialog shown when user taps "فاصل آخر..." from AyahOptionsSheet.
/// Allows selecting an existing bookmark slot to assign to the current ayah,
/// or creating a new custom bookmark.
class BookmarkPickerDialog extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final List<BookmarkItem> bookmarks;
  final void Function(String bookmarkId) onSelectBookmark;
  final void Function(BookmarkItem newBookmark) onAddNewBookmark;

  const BookmarkPickerDialog({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.bookmarks,
    required this.onSelectBookmark,
    required this.onAddNewBookmark,
  });

  static Future<void> show({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required int pageNumber,
    required List<BookmarkItem> bookmarks,
    required void Function(String bookmarkId) onSelectBookmark,
    required void Function(BookmarkItem newBookmark) onAddNewBookmark,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => BookmarkPickerDialog(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        pageNumber: pageNumber,
        bookmarks: bookmarks,
        onSelectBookmark: onSelectBookmark,
        onAddNewBookmark: onAddNewBookmark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = sl.isRegistered<QuranMetadataService>()
        ? sl<QuranMetadataService>()
        : null;

    return AppDialogShell(
      title: AppStrings.tr(AppStrings.anotherBookmark),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.tr(AppStrings.cancel),
            style: AppTypography.titleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...bookmarks.map((b) {
            final isCurrent =
                b.isAssigned &&
                b.surahNumber == surahNumber &&
                b.verseNumber == verseNumber;

            String subtitle;
            if (isCurrent) {
              subtitle = 'محدد لهذه الآية';
            } else if (b.isAssigned) {
              final sName =
                  meta?.getSurahNameArabic(b.surahNumber!) ??
                  '${b.surahNumber}';
              subtitle = '$sName: ${toArabicDigits(b.verseNumber ?? 0)}';
            } else {
              subtitle = 'غير مستخدم';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2.h,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectBookmark(b.id);
                  },
                  leading: Icon(
                    b.isAssigned ? Icons.bookmark : Iconsax.bookmark,
                    color: b.color,
                    size: 24.sp,
                  ),
                  title: Text(
                    b.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isCurrent
                          ? AppColors.primary
                          : colors.textSecondary,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isCurrent
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20.sp,
                        )
                      : null,
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: colors.divider.withOpacity(0.3),
                ),
              ],
            );
          }),
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showAddNewBookmarkDialog(context);
              },
              icon: Icon(Icons.add, color: AppColors.primary, size: 18.sp),
              label: Text(
                AppStrings.tr(AppStrings.newBookmark),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNewBookmarkDialog(BuildContext context) {
    BookmarkEditDialog.show(
      context: context,
      item: BookmarkItem(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: 'فاصل جديد',
        colorHex: '#8E44AD',
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        pageNumber: pageNumber,
        updatedAt: DateTime.now(),
        isDefault: false,
      ),
      onSave: (newName, newColorHex) {
        onAddNewBookmark(
          BookmarkItem(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: newName,
            colorHex: newColorHex,
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            pageNumber: pageNumber,
            updatedAt: DateTime.now(),
            isDefault: false,
          ),
        );
      },
    );
  }
}
