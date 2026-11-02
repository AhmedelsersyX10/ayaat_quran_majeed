import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Standard search bar input matching screens 03, 15, 18, 21.
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'ابحث عن سورة أو آية أو صفحة',
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Iconsax.search_normal_1,
            color: colors.textMuted,
            size: AppSizes.iconSm,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: AppTypography.bodyLarge,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            AppIconButton.ghost(
              icon: const Icon(Iconsax.close_circle),
              onPressed: () {
                controller?.clear();
                onChanged?.call('');
                onClear?.call();
              },
              iconColor: colors.textMuted,
              size: 28,
              iconSize: 18,
            ),
        ],
      ),
    );
  }
}

/// Standard multi-line or single-line text input field (e.g. note editor, screen 29).
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.titleSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.radiusMd,
            border: Border.all(color: colors.border, width: 0.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            minLines: minLines,
            maxLines: maxLines,
            onChanged: onChanged,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: colors.textMuted,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

