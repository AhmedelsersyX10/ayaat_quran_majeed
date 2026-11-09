import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Floating top reader app bar matching reference 05 and reference 17 (Tafsir mode).
///
/// Features:
/// - Actions in visual RTL order: Index/list, optional Tafsir book title, Search, Today, Settings.
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

  /// Optional active book title shown in Tafsir mode (Reference 17).
  final String? tafsirBookTitle;

  /// Callback when user taps the Tafsir book title to open book switcher.
  final VoidCallback? onSelectTafsirBook;

  const FloatingQuranAppBar({
    super.key,
    required this.isVisible,
    required this.onIndex,
    required this.onSearch,
    required this.onToday,
    required this.onSettings,
    required this.backgroundColor,
    required this.iconColor,
    this.tafsirBookTitle,
    this.onSelectTafsirBook,
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
                  // 1. Right action in RTL: Index / List icon and optional active Tafsir book title (Ref 17)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      if (tafsirBookTitle != null) ...[
                        SizedBox(width: AppSpacing.xs),
                        InkWell(
                          onTap: onSelectTafsirBook,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tafsirBookTitle!,
                                  style: TextStyle(
                                    fontFamily: AppTypography.arabicFontFamily,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: iconColor,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18.sp,
                                  color: iconColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
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
