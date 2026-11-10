import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet for choosing a specific daily wird or start position
/// conforming to Reference Screenshot 08 ("بدء الختمة من" with daily wird list).
class KhatmaSelectWirdSheet extends StatelessWidget {
  final KhatmaProgram program;
  final VoidCallback? onBack;
  final ValueChanged<int>? onStartWirdSelected;
  final KhatmaWirdCalculator calculator;

  const KhatmaSelectWirdSheet({
    super.key,
    required this.program,
    this.onBack,
    this.onStartWirdSelected,
    this.calculator = const KhatmaWirdCalculator(),
  });

  /// Displays [KhatmaSelectWirdSheet] as an independent modal bottom sheet.
  static Future<int?> show(
    BuildContext context, {
    required KhatmaProgram program,
  }) {
    final colors = context.colors;
    KhatmaCubit? cubit;
    try {
      cubit = context.read<KhatmaCubit>();
    } catch (_) {}

    return showModalBottomSheet<int>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      builder: (sheetContext) {
        final content = KhatmaSelectWirdSheet(program: program);
        if (cubit != null) {
          return BlocProvider.value(
            value: cubit,
            child: content,
          );
        }
        return content;
      },
    );
  }

  void _handleSelectWird(BuildContext context, int wirdNumber) {
    if (onStartWirdSelected != null) {
      onStartWirdSelected!(wirdNumber);
    } else {
      try {
        context.read<KhatmaCubit>().createKhatma(
              program: program,
              startDate: DateTime.now(),
              startWirdNumber: wirdNumber,
            );
      } catch (_) {}
      Navigator.of(context).maybePop(wirdNumber);
    }
  }

  Future<void> _handleSelectByAyah(BuildContext context) async {
    final result = await AyahPickerSheet.show(
      context,
      surahNumber: 1,
    );
    if (result == null || !context.mounted) return;

    final wirdNumber = calculator.findWirdNumberForAyah(
      program: program,
      surahNumber: result.surahNumber,
      ayahNumber: result.ayahNumber,
    );
    _handleSelectWird(context, wirdNumber);
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      try {
        context.read<KhatmaCubit>().goToStep(KhatmaCreationStep.startFrom);
      } catch (_) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;

    final wirds = calculator.calculateWirds(
      program: program,
      startDate: DateTime.now(),
      startWirdNumber: 1,
    );

    return Container(
      height: screenHeight * 0.92,
      decoration: BoxDecoration(
        color: colors.scaffoldBackground,
        borderRadius: AppRadii.bottomSheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Back arrow on right (RTL start) + Title "بدء الختمة من"
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.primary,
                      size: 26.sp,
                    ),
                    onPressed: () => _handleBack(context),
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    AppStrings.tr(AppStrings.startFrom),
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.divider),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                children: [
                  // Option 1: بداية المصحف (Reference 08 Top Tile)
                  _buildBeginningCard(context, colors),

                  SizedBox(height: AppSpacing.md),

                  // Option 2: Scrollable Daily Wirds List (Reference 08)
                  _buildWirdsListCard(context, wirds, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeginningCard(BuildContext context, dynamic colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleSelectWird(context, 1),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18.h,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colors.divider.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            AppStrings.tr(AppStrings.mushafBeginning),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWirdsListCard(
    BuildContext context,
    List<KhatmaWird> wirds,
    dynamic colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.divider.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          children: [
            // Optional Ayah Picker Header Action
            InkWell(
              onTap: () => _handleSelectByAyah(context),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14.h,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 20.sp,
                      color: colors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      AppStrings.tr(AppStrings.selectByAyah),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.divider),

            // Daily Wird Rows
            ...wirds.asMap().entries.map((entry) {
              final index = entry.key;
              final wird = entry.value;
              final isLast = index == wirds.length - 1;

              final title =
                  '${AppStrings.tr(AppStrings.wirdOfToday)} ${toArabicDigits(wird.dayNumber)}';
              final subtitle = (wird.customTitle != null &&
                      wird.customTitle!.isNotEmpty)
                  ? wird.customTitle!
                  : wird.rangeText;

              return Column(
                children: [
                  InkWell(
                    onTap: () => _handleSelectWird(context, wird.dayNumber),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 14.h,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              subtitle,
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.divider.withOpacity(0.6),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
