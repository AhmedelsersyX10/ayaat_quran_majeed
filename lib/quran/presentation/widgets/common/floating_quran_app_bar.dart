import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Floating top reader app bar matching reference 05.
///
/// Features:
/// - Exact 4 actions in visual RTL order: Index/list, Search, Today, Settings.
/// - No toolbar back arrow (system back remains intact).
/// - Respects top safe area and accessible touch targets (>= 48x48).
/// - Smooth slide animation and pointer event ignoring when hidden.
class FloatingQuranAppBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onIndex;
  final VoidCallback onSearch;
  final VoidCallback onToday;
  final VoidCallback onSettings;
  final Color backgroundColor;
  final Color iconColor;

  const FloatingQuranAppBar({
    super.key,
    required this.isVisible,
    required this.onIndex,
    required this.onSearch,
    required this.onToday,
    required this.onSettings,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final barHeight = AppSizes.bottomNavHeight;
    final totalHeight = barHeight + topPadding;

    return AnimatedPositioned(
      duration: AppDurations.sheet,
      curve: Curves.easeInOutQuart,
      top: isVisible ? 0 : -totalHeight,
      left: 0,
      right: 0,
      height: totalHeight,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.96),
            boxShadow: [
              if (isVisible)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: EdgeInsets.only(top: topPadding),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Right action in RTL: Index / List icon
                  IconButton(
                    tooltip: AppStrings.tr(AppStrings.navSurahs),
                    icon: Icon(
                      Icons.format_list_bulleted,
                      size: AppSizes.iconLg,
                      color: iconColor,
                    ),
                    onPressed: onIndex,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),

                  // 2. Left group in RTL: Search, Today, Settings
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: AppStrings.tr(AppStrings.searchQuranHint),
                        icon: Icon(
                          Icons.search_rounded,
                          size: AppSizes.iconLg,
                          color: iconColor,
                        ),
                        onPressed: onSearch,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      IconButton(
                        tooltip: AppStrings.tr(AppStrings.todayTitle),
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          size: AppSizes.iconMd,
                          color: iconColor,
                        ),
                        onPressed: onToday,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      IconButton(
                        tooltip: AppStrings.tr(AppStrings.settings),
                        icon: Icon(
                          Icons.settings_outlined,
                          size: AppSizes.iconMd,
                          color: iconColor,
                        ),
                        onPressed: onSettings,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ],
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
