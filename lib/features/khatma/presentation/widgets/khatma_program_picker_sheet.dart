import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet and view for Khatma Program Selection conforming to
/// Reference Screenshots 09 (Meaning Programs), 14 (Sections), and 32 (Full Quarters List).
class KhatmaProgramPickerSheet extends StatelessWidget {
  final KhatmaProgramCategory category;
  final VoidCallback? onBack;
  final ValueChanged<KhatmaProgram>? onProgramSelected;

  const KhatmaProgramPickerSheet({
    super.key,
    required this.category,
    this.onBack,
    this.onProgramSelected,
  });

  /// Displays the Program Picker as an independent modal bottom sheet.
  static Future<KhatmaProgram?> show(
    BuildContext context, {
    required KhatmaProgramCategory category,
  }) {
    final colors = context.colors;
    KhatmaCubit? cubit;
    try {
      cubit = context.read<KhatmaCubit>();
    } catch (_) {}

    return showModalBottomSheet<KhatmaProgram>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      builder: (sheetContext) {
        final content = KhatmaProgramPickerSheet(category: category);
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

  void _handleSelect(BuildContext context, KhatmaProgram program) {
    if (onProgramSelected != null) {
      onProgramSelected!(program);
    } else {
      try {
        context.read<KhatmaCubit>().selectProgram(program);
      } catch (_) {}
      Navigator.of(context).maybePop(program);
    }
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      try {
        context.read<KhatmaCubit>().goToStep(KhatmaCreationStep.menu);
      } catch (_) {}
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Back arrow on right (RTL start) + Title "برنامج الختمة"
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
                    AppStrings.tr(AppStrings.programPicker),
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
              child: category == KhatmaProgramCategory.meaning
                  ? _buildMeaningList(context)
                  : _buildPartsAndQuartersList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the concise 3-item list for Meaning-divided programs (Reference Screenshot 09).
  Widget _buildMeaningList(BuildContext context) {
    final colors = context.colors;
    const programs = KhatmaProgram.meaningPrograms;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      children: [
        _buildProgramsCard(
          context: context,
          programs: programs,
          colors: colors,
        ),
      ],
    );
  }

  /// Builds the categorized list for Parts & Quarters programs (Reference Screenshots 14 & 32).
  Widget _buildPartsAndQuartersList(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      children: [
        // Section 1: "الأشهر" (Reference 14)
        _buildSectionHeader(
          title: AppStrings.tr(AppStrings.monthsCategory),
          colors: colors,
          topPadding: AppSpacing.xs,
        ),
        SizedBox(height: AppSpacing.xs),
        _buildProgramsCard(
          context: context,
          programs: const [KhatmaProgram.monthlyProgram],
          colors: colors,
        ),

        SizedBox(height: AppSpacing.lg),

        // Section 2: "أخرى" (Reference 14 & 32)
        _buildSectionHeader(
          title: AppStrings.tr(AppStrings.otherCategory),
          colors: colors,
          topPadding: AppSpacing.xs,
        ),
        SizedBox(height: AppSpacing.xs),
        _buildProgramsCard(
          context: context,
          programs: KhatmaProgram.partsAndQuartersPrograms,
          colors: colors,
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required dynamic colors,
    double topPadding = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds a rounded white card containing a list of program rows with dividers.
  Widget _buildProgramsCard({
    required BuildContext context,
    required List<KhatmaProgram> programs,
    required dynamic colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < programs.length; i++) ...[
            _buildProgramRow(
              context: context,
              program: programs[i],
              colors: colors,
            ),
            if (i < programs.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.divider,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgramRow({
    required BuildContext context,
    required KhatmaProgram program,
    required dynamic colors,
  }) {
    return InkWell(
      onTap: () => _handleSelect(context, program),
      borderRadius: AppRadii.radiusMd,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
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
    );
  }
}
