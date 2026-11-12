import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_sheet_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Modal bottom sheet presenting sources, verified attributions,
/// and a button to view open-source software licenses.
class SourcesAndLicensesSheet extends StatelessWidget {
  final List<ContentSource>? sources;

  const SourcesAndLicensesSheet({super.key, this.sources});

  /// Displays the [SourcesAndLicensesSheet] modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return AppBottomSheetShell.show<void>(
      context: context,
      title: AppStrings.tr(AppStrings.sourcesAndAttributionsTitle),
      child: const SourcesAndLicensesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final list =
        sources ??
        (sl.isRegistered<SettingsRepository>()
            ? sl<SettingsRepository>().getSourcesAndAttributions()
            : const <ContentSource>[]);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Intro text
            Text(
              AppStrings.tr(AppStrings.sourcesIntro),
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Attributed sources cards
            ...list.map(
              (source) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard.standard(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _categoryIcon(source.category),
                            size: 18,
                            color: colors.primary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              source.title,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        source.provider,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        source.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (source.url != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          source.url!,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.textMuted,
                            decoration: TextDecoration.underline,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.sm),

            // Open source software licenses button
            AppButton.secondary(
              text: AppStrings.tr(AppStrings.openSourceLicenses),
              icon: const Icon(Iconsax.document_text),
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: AppStrings.tr(AppStrings.appName),
                  applicationVersion: '1.0.0',
                );
              },
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(ContentSourceCategory category) {
    switch (category) {
      case ContentSourceCategory.quranEngine:
        return Iconsax.book_saved;
      case ContentSourceCategory.tafsir:
        return Iconsax.book_1;
      case ContentSourceCategory.audio:
        return Iconsax.music;
      case ContentSourceCategory.calendar:
        return Iconsax.calendar_1;
      case ContentSourceCategory.openSource:
        return Iconsax.code;
    }
  }
}
