import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_program_picker_sheet.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_select_wird_sheet.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_start_from_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet launcher and container for New Khatma Menu conforming to Reference Screenshot 06
/// and transitioning reactively to Program Picker (References 09, 14, 32).
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
    KhatmaCubit? cubit;
    try {
      cubit = context.read<KhatmaCubit>();
    } catch (_) {}

    if (cubit != null) {
      return BlocConsumer<KhatmaCubit, KhatmaState>(
        listener: (context, state) {
          if (state is KhatmaLoaded) {
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          if (state is KhatmaCreating) {
            if (state.step == KhatmaCreationStep.programPicker) {
              return KhatmaProgramPickerSheet(
                category: state.customProgramCategory ??
                    KhatmaProgramCategory.meaning,
                onBack: onBack ?? () => cubit?.goToStep(KhatmaCreationStep.menu),
                onProgramSelected: onProgramSelected,
              );
            }
            if (state.step == KhatmaCreationStep.startFrom &&
                state.selectedProgram != null) {
              return KhatmaStartFromSheet(
                program: state.selectedProgram!,
                onBack: onBack ??
                    () {
                      if (state.customProgramCategory != null) {
                        cubit?.goToStep(KhatmaCreationStep.programPicker);
                      } else {
                        cubit?.goToStep(KhatmaCreationStep.menu);
                      }
                    },
              );
            }
            if (state.step == KhatmaCreationStep.selectWird &&
                state.selectedProgram != null) {
              return KhatmaSelectWirdSheet(
                program: state.selectedProgram!,
                onBack: () => cubit?.goToStep(KhatmaCreationStep.startFrom),
              );
            }
          }
          return _buildMenuContent(context, cubit!);
        },
      );
    }

    return _buildStaticMenuContent(context);
  }

  Widget _buildMenuContent(BuildContext context, KhatmaCubit cubit) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
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
                        onCategorySelected!(
                            KhatmaProgramCategory.partsAndQuarters);
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

  Widget _buildStaticMenuContent(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      }
                    },
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
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                children: [
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
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl),
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
                      }
                    },
                    onPartsAndQuartersTap: () {
                      if (onCategorySelected != null) {
                        onCategorySelected!(
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
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.radiusMd,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: SizedBox(
              width: double.infinity,
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
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    program.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            title: AppStrings.tr(AppStrings.khatmaMeaningDivision),
            colors: colors,
            onTap: onMeaningTap,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.divider,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
          _buildOptionTile(
            title: AppStrings.tr(AppStrings.khatmaPartsAndQuartersDivision),
            colors: colors,
            onTap: onPartsAndQuartersTap,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required dynamic colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusMd,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
