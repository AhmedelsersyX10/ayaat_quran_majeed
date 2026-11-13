import 'dart:math' as math;

import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// Custom toggle switch matching the Khatma reminder switch in screens 26 and 31.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isEnabled;
  final String? semanticLabel;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final width = AppSizes.switchWidth;
    final height = AppSizes.switchHeight;
    final thumbSize = height - 6.0;

    final trackColor = value
        ? (isEnabled
              ? colors.primaryLight
              : colors.primaryLight.withOpacity(0.5))
        : (isEnabled ? colors.border : colors.border.withOpacity(0.5));

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final effectiveTargetWidth = math.max(width, 44.0);

    return Semantics(
      toggled: value,
      enabled: isEnabled,
      label: semanticLabel ?? 'تفعيل التنبيه اليومي',
      child: GestureDetector(
        onTap: isEnabled ? () => onChanged(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 44.0,
            minWidth: effectiveTargetWidth,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppDurations.defaultCurve,
              width: width,
              height: height,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    duration: AppDurations.fast,
                    curve: AppDurations.defaultCurve,
                    alignment: value
                        ? (isRtl ? Alignment.centerLeft : Alignment.centerRight)
                        : (isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft),
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
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
}
