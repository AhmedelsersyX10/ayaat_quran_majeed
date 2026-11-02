import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Tab 1: Khatma View.
/// Conforms to reference screenshot 10_khatma_empty_state.
class KhatmaTabView extends StatefulWidget {
  const KhatmaTabView({super.key});

  @override
  State<KhatmaTabView> createState() => _KhatmaTabViewState();
}

class _KhatmaTabViewState extends State<KhatmaTabView>
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
          AppStrings.tr(AppStrings.khatmaTitle),
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    AppStrings.tr(AppStrings.khatmaGuidanceDesc),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: 240,
                  child: AppButton.primary(
                    text: AppStrings.tr(AppStrings.startKhatmaBtn),
                    onPressed: () {
                      // Placeholder action for future Khatma feature setup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.tr(AppStrings.startKhatmaBtn),
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
