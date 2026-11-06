import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Visual style variants for [AppSegmentedTabs].
enum AppSegmentedTabVariant {
  /// Solid active background fill (screens 18, 34).
  pill,

  /// Outlined border active indicator (screens 03, 04).
  outlined,
}

/// Capsule segmented tab control (e.g. "السور" / "الأرباع" / "الأجزاء").
/// Matches the reference design in screens 03, 04, 18, 34.
class AppSegmentedTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final AppSegmentedTabVariant variant;
  final BorderRadiusGeometry? borderRadius;

  const AppSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.width,
    this.height,
    this.margin,
    this.variant = AppSegmentedTabVariant.pill,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tabHeight = height ?? 36.h;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isOutlined = variant == AppSegmentedTabVariant.outlined;
    final effectiveRadius = borderRadius ??
        (isOutlined ? BorderRadius.circular(6.r) : AppRadii.radiusPill);

    Widget container = Container(
      margin: margin,
      height: tabHeight,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: colors.border.withValues(alpha: 0.8),
          width: isOutlined ? 0.8 : 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          // Calculate pill offset respecting RTL
          final double leftOffset = isRtl
              ? (tabs.length - 1 - selectedIndex) * tabWidth
              : selectedIndex * tabWidth;

          return Stack(
            children: [
              // Sliding Active Indicator Pill
              AnimatedPositioned(
                duration: AppDurations.standard,
                curve: AppDurations.defaultCurve,
                left: leftOffset,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isOutlined ? Colors.transparent : colors.primary,
                    borderRadius: effectiveRadius,
                    border: isOutlined
                        ? Border.all(color: colors.primary, width: 1.5)
                        : null,
                  ),
                ),
              ),
              // Tab Labels
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedIndex;
                  final textColor = isSelected
                      ? (isOutlined ? colors.primary : colors.textOnPrimary)
                      : colors.textSecondary;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabChanged(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppDurations.fast,
                          style: AppTypography.labelMedium.copyWith(
                            color: textColor,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Text(
                            tabs[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: container);
    }
    return container;
  }
}
