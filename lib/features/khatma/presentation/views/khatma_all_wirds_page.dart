import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_29_day_table.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Full scrollable list of all daily wird portions conforming to
/// Reference Screenshots 24, 25, 33, and 35 ("جميع الأوراد").
class KhatmaAllWirdsPage extends StatelessWidget {
  final Khatma? khatma;

  const KhatmaAllWirdsPage({super.key, this.khatma});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (khatma != null) {
      return _buildContent(context, khatma!.wirds);
    }

    return BlocBuilder<KhatmaCubit, KhatmaState>(
      builder: (context, state) {
        if (state is KhatmaLoaded) {
          return _buildContent(context, state.khatma.wirds);
        }

        // Fallback for standalone preview / inspection using canonical 29-day table
        final fallbackWirds = Khatma29DayTable.days
            .map(
              (entry) => KhatmaWird(
                dayNumber: entry.dayNumber,
                scheduledDate: DateTime.now().add(
                  Duration(days: entry.dayNumber - 1),
                ),
                startSurahNumber: entry.startSurah,
                startAyahNumber: entry.startAyah,
                endSurahNumber: entry.endSurah,
                endAyahNumber: entry.endAyah,
                startPageNumber: 1,
                endPageNumber: 604,
                startSurahName: '',
                endSurahName: '',
                firstVerseText: '',
                lastVerseText: '',
                customTitle: entry.customTitle,
                rangeText: entry.rangeText,
              ),
            )
            .toList();

        return _buildContent(context, fallbackWirds);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<KhatmaWird> wirds) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_rounded, color: colors.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          AppStrings.tr(AppStrings.allWirds),
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        itemCount: wirds.length,
        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final wird = wirds[index];
          return _WirdListItem(
            wird: wird,
            onTap: () {
              try {
                context.push(
                  '${AppRoutes.reader}?page=${wird.startPageNumber}',
                );
              } catch (_) {}
            },
          );
        },
      ),
    );
  }
}

class _WirdListItem extends StatelessWidget {
  final KhatmaWird wird;
  final VoidCallback onTap;

  const _WirdListItem({required this.wird, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.radiusMd.topLeft.x),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wird.dayTitle,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    wird.displayTitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (wird.isCompleted) ...[
              SizedBox(width: 8.w),
              Icon(Icons.check_circle, size: 20.sp, color: colors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
