import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Tab 3: Starred Verses View.
/// Conforms to reference screenshot 12_starred_empty.
class StarredTabView extends StatefulWidget {
  const StarredTabView({super.key});

  @override
  State<StarredTabView> createState() => _StarredTabViewState();
}

class _StarredTabViewState extends State<StarredTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          AppStrings.tr(AppStrings.starredTitle),
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              AppStrings.tr(AppStrings.emptyStarredTitle),
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
