import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet launcher and container for New Khatma Menu conforming to Reference Screenshot 06.
class NewKhatmaMenuSheet extends StatelessWidget {
  final VoidCallback? onBack;
  final ValueChanged<KhatmaProgram>? onProgramSelected;
  final ValueChanged<KhatmaProgramCategory>? onCategorySelected;

  const NewKhatmaMenuSheet({
    super.key,
    this.onBack,
    this.onProgramSelected,
    this.onCategorySelected,
  });

  /// Displays the New Khatma Menu modal bottom sheet overlaying the Khatma tab.
  /// Uses [useRootNavigator: false] to preserve visibility of the bottom navigation bar.
  static Future<T?> show<T>(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<KhatmaCubit>();

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: const NewKhatmaMenuSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    final cubit = context.read<KhatmaCubit>();

    return Container(
      height: screenHeight * 0.92,
      decoration: BoxDecoration(
        color: colors.scaffoldBackground,
        borderRadius: AppRadii.bottomSheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Bar: Back arrow on right (RTL start) + Title "ختمة جديدة"
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
                    onPressed: () {
                      if (onBack != null) {
                        onBack!();
                      } else {
                        Navigator.of(context).maybePop();
                        cubit.cancelCreation();
                      }
                    },
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    AppStrings.tr(AppStrings.newKhatma),
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.divider),

            // Content List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                children: [
                  // Section 1: ختمة مقترحة (Suggested Khatma)
                  _buildSectionHeader(
                    title: AppStrings.tr(AppStrings.suggestedKhatmaHeader),
                    subtitle: AppStrings.tr(AppStrings.suggestedKhatmaDesc),
                    colors: colors,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildSuggestedCard(
                    program: KhatmaProgram.defaultProgram,
                    colors: colors,
                    onTap: () {
                      if (onProgramSelected != null) {
                        onProgramSelected!(KhatmaProgram.defaultProgram);
                      } else {
                        cubit.selectProgram(KhatmaProgram.defaultProgram);
                      }
                    },
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Section 2: أخرى (Other Categories)
                  _buildSectionHeader(
                    title: AppStrings.tr(AppStrings.otherCategory),
                    colors: colors,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildOtherOptionsCard(
                    colors: colors,
                    onMeaningTap: () {
                      if (onCategorySelected != null) {
                        onCategorySelected!(KhatmaProgramCategory.meaning);
                      } else {
                        cubit.selectCategory(KhatmaProgramCategory.meaning);
                      }
                    },
                    onPartsAndQuartersTap: () {
                      if (onCategorySelected != null) {
                        onCategorySelected!(KhatmaProgramCategory.partsAndQuarters);
                      } else {
                        cubit.selectCategory(
                            KhatmaProgramCategory.partsAndQuarters);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    required dynamic colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestedCard({
    required KhatmaProgram program,
    required dynamic colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.radiusMd,
        side: BorderSide(color: colors.border.withValues(alpha: 0.5)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusMd,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                program.subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherOptionsCard({
    required dynamic colors,
    required VoidCallback onMeaningTap,
    required VoidCallback onPartsAndQuartersTap,
  }) {
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.radiusMd,
        side: BorderSide(color: colors.border.withValues(alpha: 0.5)),
      ),
      elevation: 0,
      child: ClipRRect(
        borderRadius: AppRadii.radiusMd,
        child: Column(
          children: [
            // Option 1: ختمة مقسمة بالمعنى
            InkWell(
              onTap: onMeaningTap,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Text(
                  AppStrings.tr(AppStrings.khatmaMeaningDivision),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.divider),
            // Option 2: ختمة مقسمة بالأجزاء والأرباع
            InkWell(
              onTap: onPartsAndQuartersTap,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Text(
                  AppStrings.tr(AppStrings.khatmaPartsAndQuartersDivision),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
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
