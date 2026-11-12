import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_dialog_shell.dart';
import 'package:flutter/material.dart';

/// Modal dialog allowing the user to manually adjust the Hijri calendar
/// date by ±1 day relative to the standard Umm al-Qura calculation.
class HijriAdjustmentDialog extends StatefulWidget {
  final int initialOffset;
  final ValueChanged<int> onOffsetSelected;

  const HijriAdjustmentDialog({
    super.key,
    required this.initialOffset,
    required this.onOffsetSelected,
  });

  /// Displays the [HijriAdjustmentDialog].
  static Future<void> show({
    required BuildContext context,
    required int initialOffset,
    required ValueChanged<int> onOffsetSelected,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => HijriAdjustmentDialog(
        initialOffset: initialOffset,
        onOffsetSelected: onOffsetSelected,
      ),
    );
  }

  @override
  State<HijriAdjustmentDialog> createState() => _HijriAdjustmentDialogState();
}

class _HijriAdjustmentDialogState extends State<HijriAdjustmentDialog> {
  late int _selectedOffset;

  static const List<_AdjustmentOption> _options = [
    _AdjustmentOption(1, AppStrings.hijriAdvanceOneDay),
    _AdjustmentOption(0, AppStrings.hijriDefaultUmmAlQura),
    _AdjustmentOption(-1, AppStrings.hijriDelayOneDay),
  ];

  @override
  void initState() {
    super.initState();
    _selectedOffset = widget.initialOffset.clamp(-1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppDialogShell(
        title: AppStrings.tr(AppStrings.hijriAdjustmentTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.tr(AppStrings.cancel),
              style: AppTypography.labelLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            onPressed: () {
              widget.onOffsetSelected(_selectedOffset);
              Navigator.of(context).pop();
            },
            child: Text(
              AppStrings.tr(AppStrings.confirm),
              style: AppTypography.labelLarge.copyWith(
                color: colors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _options.map((option) {
            final isSelected = _selectedOffset == option.offset;

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: isSelected
                    ? colors.primary.withOpacity(0.08)
                    : colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  onTap: () {
                    setState(() {
                      _selectedOffset = option.offset;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.border.withOpacity(0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: option.offset,
                          groupValue: _selectedOffset,
                          activeColor: colors.primary,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedOffset = val;
                              });
                            }
                          },
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            AppStrings.tr(option.labelKey),
                            style: AppTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? colors.primary
                                  : colors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AdjustmentOption {
  final int offset;
  final String labelKey;

  const _AdjustmentOption(this.offset, this.labelKey);
}
