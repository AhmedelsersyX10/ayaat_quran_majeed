import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

/// Single bookmark row matching reference screenshots 11 (empty) and 27 (assigned).
class BookmarkRowItem extends StatelessWidget {
  final BookmarkItem item;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onUnassign;
  final VoidCallback? onEdit;
  final QuranMetadataService? metadataService;

  const BookmarkRowItem({
    super.key,
    required this.item,
    this.isEditMode = false,
    this.onTap,
    this.onUnassign,
    this.onEdit,
    this.metadataService,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta =
        metadataService ??
        (sl.isRegistered<QuranMetadataService>()
            ? sl<QuranMetadataService>()
            : null);

    final surahName = (item.surahNumber != null && meta != null)
        ? meta.getSurahNameArabic(item.surahNumber!)
        : (item.surahNumber != null ? '${item.surahNumber}' : '');

    final timeStr = item.updatedAt != null
        ? formatArabicTime(
            hour: item.updatedAt!.hour,
            minute: item.updatedAt!.minute,
          )
        : '';

    final timePrefix = timeStr.isNotEmpty ? '$timeStr  ' : '';
    final pagePrefix = AppStrings.tr(AppStrings.pagePrefix);
    final ayahArabic = toArabicDigits(item.verseNumber ?? 0);
    final pageArabic = toArabicDigits(item.pageNumber ?? 0);

    final subtitle = item.isAssigned
        ? '$timePrefix$surahName: $ayahArabic - $pagePrefix $pageArabic'
        : null;

    return InkWell(
      onTap: isEditMode ? onEdit : onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Bookmark icon (Left/Start in visual row matching screenshots 11 & 27)
            if (isEditMode) ...[
              if (item.isAssigned)
                IconButton(
                  tooltip: AppStrings.tr(AppStrings.delete),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 16.sp,
                    ),
                  ),
                  onPressed: onUnassign,
                )
              else
                SizedBox(width: 24.w),
              SizedBox(width: AppSpacing.sm),
            ],

            // Title & optional metadata subtitle (RTL right-aligned text)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isEditMode) ...[
                        SizedBox(width: AppSpacing.xs),
                        Icon(
                          Iconsax.edit_2,
                          size: 14.sp,
                          color: colors.textSecondary.withOpacity(0.6),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: AppSpacing.md),

            // Trailing ribbon icon (Screens 11 & 27 place the ribbon on the far end)
            _buildRibbonIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildRibbonIcon() {
    if (item.isAssigned) {
      // Screen 27: Filled colored ribbon
      return Icon(Icons.bookmark, color: item.color, size: 24.sp);
    } else {
      // Screen 11: Outlined colored ribbon
      return Icon(Iconsax.bookmark, color: item.color, size: 24.sp);
    }
  }
}
