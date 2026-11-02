import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Application Shell containing the persistent 5-tab bottom navigation bar.
///
/// Wraps [StatefulNavigationShell] to preserve the state, scroll position,
/// and sub-routes of each of the 5 tabs independently across tab switches.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTabSelected,
        ),
      ),
    );
  }
}
