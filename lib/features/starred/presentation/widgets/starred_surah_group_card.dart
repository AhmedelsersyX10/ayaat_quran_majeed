import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_surah_group.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/widgets/starred_ayah_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card grouping starred verses under a Surah header.
/// Pixel-faithful matching reference screenshot 28.
class StarredSurahGroupCard extends StatelessWidget {
  final StarredSurahGroup group;
  final ValueChanged<StarredAyahItem> onItemTap;

  const StarredSurahGroupCard({
    super.key,
    required this.group,
    required this.onItemTap,
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

        // 2. Rounded White Card containing verses
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(group.items.length, (index) {
              final item = group.items[index];
              final isLast = index == group.items.length - 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StarredAyahItemView(
                    item: item,
                    onTap: () => onItemTap(item),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: colors.divider.withOpacity(0.3),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

