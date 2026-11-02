import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Capsule segmented tab control (e.g. "السور" / "الأرباع" / "الأجزاء").
/// Matches the reference design in screens 03, 04, 18, 34.
class AppSegmentedTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const AppSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tabHeight = height ?? 36.h;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      margin: margin,
      height: tabHeight,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.radiusPill,
        border: Border.all(color: colors.border, width: 0.5),
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
                    color: colors.primary,
                    borderRadius: AppRadii.radiusPill,
                  ),
                ),
              ),
              // Tab Labels
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabChanged(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppDurations.fast,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? colors.textOnPrimary
                                : colors.textPrimary,
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
  }
}

