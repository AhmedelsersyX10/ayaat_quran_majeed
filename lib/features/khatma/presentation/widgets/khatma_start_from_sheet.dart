import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet for choosing the Khatma start position conforming to
/// Reference Screenshot 07 ("بدء الختمة من").
///
/// Provides options:
/// 1. "بداية المصحف" (Start from Al-Fatihah, Day 1)
/// 2. "ورد محدد" (Specific wird -> navigates to Reference 08)
/// 3. "موضع محدد" (Specific position -> launches [AyahPickerSheet] and derives starting wird)
class KhatmaStartFromSheet extends StatelessWidget {
  final KhatmaProgram program;
  final VoidCallback? onBack;
  final ValueChanged<int>? onStartWirdSelected;
  final VoidCallback? onSelectSpecificWird;
  final KhatmaWirdCalculator calculator;

  const KhatmaStartFromSheet({
    super.key,
    required this.program,
    this.onBack,
    this.onStartWirdSelected,
    this.onSelectSpecificWird,
    this.calculator = const KhatmaWirdCalculator(),
  });

  /// Displays [KhatmaStartFromSheet] as an independent modal bottom sheet.
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
        final content = KhatmaStartFromSheet(program: program);
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

  void _handleBeginningSelected(BuildContext context) {
    if (onStartWirdSelected != null) {
      onStartWirdSelected!(1);
    } else {
      try {
        context.read<KhatmaCubit>().createKhatma(
              program: program,
              startDate: DateTime.now(),
              startWirdNumber: 1,
            );
      } catch (_) {}
      Navigator.of(context).maybePop(1);
    }
  }

  void _handleSpecificWirdTapped(BuildContext context) {
    if (onSelectSpecificWird != null) {
      onSelectSpecificWird!();
    } else {
      try {
        context.read<KhatmaCubit>().goToStep(KhatmaCreationStep.selectWird);
      } catch (_) {}
    }
  }

  Future<void> _handleSpecificPositionTapped(BuildContext context) async {
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
      if (context.mounted) {
        Navigator.of(context).maybePop(wirdNumber);
      }
    }
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      try {
        final cubit = context.read<KhatmaCubit>();
        final state = cubit.state;
        if (state is KhatmaCreating && state.customProgramCategory != null) {
          cubit.goToStep(KhatmaCreationStep.programPicker);
        } else {
          cubit.goToStep(KhatmaCreationStep.menu);
        }
      } catch (_) {
        Navigator.of(context).maybePop();
      }
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

            // Options List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                children: [
                  // Option 1: بداية المصحف (Reference 07)
                  _buildOptionCard(
                    title: AppStrings.tr(AppStrings.mushafBeginning),
                    colors: colors,
                    onTap: () => _handleBeginningSelected(context),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Option 2: ورد محدد (Reference 07 -> Reference 08)
                  _buildOptionCard(
                    title: AppStrings.tr(AppStrings.specificWird),
                    colors: colors,
                    onTap: () => _handleSpecificWirdTapped(context),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Option 3: موضع محدد (Ayah Picker integration)
                  _buildOptionCard(
                    title: AppStrings.tr(AppStrings.specificPosition),
                    colors: colors,
                    onTap: () => _handleSpecificPositionTapped(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required dynamic colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

