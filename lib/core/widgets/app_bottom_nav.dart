import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Item definition for the bottom navigation bar.
class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Standard 5-tab bottom navigation bar for the Ayaat app.
/// Matches screens 03, 10, 11, 12, 13, 26, 27, 28, 30, 31.
///
/// Tab ordering in RTL (from Right to Left):
/// 0: السور (Index)
/// 1: الختمة (Khatma)
/// 2: الفواصل (Bookmarks)
/// 3: مميزة بنجمة (Starred)
/// 4: الملاحظات (Notes)
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem>? items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  /// Default 5 tabs defined in the approved specification, localized using [AppStrings].
  /// Matches the exact icons in reference screenshots 03, 10, 11, 12, 13.
  static List<AppBottomNavItem> getDefaultItems() => [
    AppBottomNavItem(
      icon: Icons.format_list_bulleted,
      activeIcon: Icons.format_list_bulleted,
      label: AppStrings.tr(AppStrings.navSurahs),
    ),
    AppBottomNavItem(
      icon: Iconsax.tick_circle,
      activeIcon: Iconsax.tick_circle,
      label: AppStrings.tr(AppStrings.navKhatma),
    ),
    AppBottomNavItem(
      icon: Iconsax.bookmark,
      activeIcon: Iconsax.bookmark_2,
      label: AppStrings.tr(AppStrings.navBookmarks),
    ),
    AppBottomNavItem(
      icon: Iconsax.star,
      activeIcon: Iconsax.star1,
      label: AppStrings.tr(AppStrings.navStarred),
    ),
    AppBottomNavItem(
      icon: Iconsax.note_2,
      activeIcon: Iconsax.note_21,
      label: AppStrings.tr(AppStrings.navNotes),
    ),
  ];

  /// Getter alias for backwards compatibility.
  static List<AppBottomNavItem> get defaultItems => getDefaultItems();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final navItems = items ?? getDefaultItems();

    return Container(
      decoration: BoxDecoration(
        color: colors.bottomNavBackground,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = index == currentIndex;
              final color = isSelected ? colors.primary : colors.textSecondary;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: color,
                        size: AppSizes.iconMd,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: AppTypography.bodySmall.copyWith(
                          color: color,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
