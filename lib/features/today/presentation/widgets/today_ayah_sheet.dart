import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/hijri_adjustment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet presenting the Ayah of the Day matching reference 16.
///
/// Features:
/// - Rounded near-full-height container (95% height) with soft background.
/// - Top header with title "اليوم" on the right and green close icon (✕) on the left.
/// - Two side-by-side calendar cards (Hijri on the right, Gregorian on the left)
///   with measured reference proportions (outer space ~56dp, center gap ~48dp).
/// - "آية اليوم" section header with green share button.
/// - Rounded white Ayah card with decorative verse-end symbol, divider,
///   and green "التفسير" action on the right.
class TodayAyahSheet extends StatelessWidget {
  final ValueChanged<TodayAyah> onShare;
  final ValueChanged<TodayAyah> onTafsir;
  final ValueChanged<TodayAyah> onAyahTap;

  const TodayAyahSheet({
    super.key,
    required this.onShare,
    required this.onTafsir,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: AppSizes.nearFullSheetHeightFactor.sh,
        decoration: BoxDecoration(
          color: colors.scaffoldBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // 1. Top Header Row (Ref 16: Title on right, green X on left)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.tr(AppStrings.todayTitle),
                      style: AppTypography.displayLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    AppIconButton.ghost(
                      tooltip: AppStrings.tr(AppStrings.close),
                      icon: Icon(
                        Icons.close_rounded,
                        size: AppSizes.iconLg,
                        color: colors.primary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // 2. Body: BlocBuilder handling Loading / Failure / Success
              Expanded(
                child: BlocBuilder<TodayCubit, TodayState>(
                  builder: (context, state) {
                    if (state is TodayLoading || state is TodayInitial) {
                      return Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      );
                    }

                    if (state is TodayFailure) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: AppSizes.buttonHeightLg,
                                color: colors.destructive,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: AppTypography.titleMedium.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.lg),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.textOnPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.md,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  context.read<TodayCubit>().loadTodayAyah();
                                },
                                child: Text(
                                  AppStrings.tr(AppStrings.retry),
                                  style: AppTypography.labelLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is TodaySuccess) {
                      return _buildSuccessContent(context, state.ayah);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, TodayAyah ayah) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.sm),

          // 2. Date Cards Row (Hijri right, Gregorian left in RTL, with reference proportions)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (AppSizes.dateCardsOuterPadding - AppSpacing.lg)
                  .clamp(0.0, 100.0),
            ),
            child: Row(
              children: [
                // Right Card: Hijri Date (tappable to adjust Hijri offset)
                Expanded(
                  child: _buildDateCard(
                    context,
                    monthName: ayah.hijriMonthName,
                    dayNumber: ayah.hijriDay,
                    tooltip: AppStrings.tr(AppStrings.hijriAdjustmentTitle),
                    onTap: () {
                      final cubit = context.read<TodayCubit>();
                      HijriAdjustmentDialog.show(
                        context: context,
                        initialOffset: cubit.currentHijriOffset,
                        onOffsetSelected: (newOffset) {
                          cubit.updateHijriOffset(newOffset);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: AppSizes.dateCardsCenterGap),
                // Left Card: Gregorian Date
                Expanded(
                  child: _buildDateCard(
                    context,
                    monthName: ayah.gregorianMonthName,
                    dayNumber: ayah.gregorianDay,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xxl),

          // 3. Ayah Header Row ("آية اليوم" on right, Share button on left in RTL)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.tr(AppStrings.todayAyah),
                style: AppTypography.titleMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              AppIconButton.ghost(
                tooltip: AppStrings.tr(AppStrings.share),
                icon: Icon(
                  Icons.share_outlined,
                  size: AppSizes.iconMd,
                  color: colors.primary,
                ),
                onPressed: () => onShare(ayah),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          // 4. Ayah Card (Ref 16: White rounded card with ayah text + divider + green Tafsir)
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: colors.border.withOpacity(0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayah Text (clickable to navigate and highlight in mushaf)
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadii.lg),
                  ),
                  onTap: () => onAyahTap(ayah),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xxl,
                    ),
                    child: Text(
                      '${ayah.ayahText} ${ayah.ayahEndSymbol}',
                      textAlign: TextAlign.center,
                      style: AppTypography.quranText.copyWith(
                        fontFamily: AppTypography.amiriFontFamily,
                        fontSize: 22.sp,
                        height: 2.1,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.divider.withOpacity(0.5),
                ),

                // Tafsir CTA on the right (start in RTL)
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadii.lg),
                  ),
                  onTap: () => onTafsir(ayah),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        AppStrings.tr(AppStrings.tafsir),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context, {
    required String monthName,
    required String dayNumber,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final colors = context.colors;

    final content = Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: colors.border.withOpacity(0.7), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header Banner (month name)
              Container(
                width: double.infinity,
                color: colors.ayahHeaderSurface,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  monthName,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              // Day number in Arabic-Indic numerals
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  dayNumber,
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: content);
    }
    return content;
  }
}
