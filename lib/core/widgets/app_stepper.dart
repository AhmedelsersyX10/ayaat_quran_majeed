import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:flutter/material.dart';

/// Counter stepper widget with circular minus and plus buttons.
/// Matches the repeat counters in Recitation Settings (Screen 40).
class AppStepper extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final int step;

  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canDecrement = value - step >= minValue;
    final canIncrement = value + step <= maxValue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minus Button
        AppIconButton.filled(
          icon: const Icon(Icons.remove),
          iconSize: 18,
          size: AppSizes.stepperButtonSize,
          backgroundColor: canDecrement ? colors.primary : colors.border,
          iconColor: canDecrement ? colors.textOnPrimary : colors.textMuted,
          onPressed: canDecrement ? () => onChanged(value - step) : null,
        ),
        SizedBox(width: AppSpacing.md),

        // Value Display in Arabic-Indic digits
        Container(
          constraints: const BoxConstraints(minWidth: 36),
          alignment: Alignment.center,
          child: Text(
            toArabicDigits(value),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),

        // Plus Button
        AppIconButton.filled(
          icon: const Icon(Icons.add),
          iconSize: 18,
          size: AppSizes.stepperButtonSize,
          backgroundColor: canIncrement ? colors.primary : colors.border,
          iconColor: canIncrement ? colors.textOnPrimary : colors.textMuted,
          onPressed: canIncrement ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }
}
