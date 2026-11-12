import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_sheet_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_list_tile.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_state.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/widgets/sources_and_licenses_sheet.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/hijri_adjustment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

/// Modal bottom sheet presenting user preferences and sources.
class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  /// Displays the [SettingsBottomSheet] modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return AppBottomSheetShell.show<void>(
      context: context,
      title: AppStrings.tr(AppStrings.settings),
      child: BlocProvider<SettingsCubit>(
        create: (_) => sl<SettingsCubit>()..loadSettings(),
        child: const SettingsBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsInitial) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: const CircularProgressIndicator(),
              ),
            );
          }
          if (state is SettingsFailure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(state.message, style: AppTypography.bodyMedium),
              ),
            );
          }

          final loaded = state as SettingsLoaded;
          final settings = loaded.settings;
          final colors = context.colors;
          final cubit = context.read<SettingsCubit>();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Keep Screen Awake
                AppListTile(
                  leading: Icon(Iconsax.lamp_on, color: colors.primary),
                  title: Text(AppStrings.tr(AppStrings.keepScreenAwake)),
                  subtitle: Text(AppStrings.tr(AppStrings.keepScreenAwakeDesc)),
                  trailing: AppSwitch(
                    value: settings.keepScreenAwake,
                    onChanged: (val) => cubit.toggleKeepScreenAwake(val),
                  ),
                  onTap: () =>
                      cubit.toggleKeepScreenAwake(!settings.keepScreenAwake),
                  showDivider: true,
                ),

                // 2. Hijri Calendar Adjustment
                AppListTile(
                  leading: Icon(Iconsax.calendar_1, color: colors.primary),
                  title: Text(AppStrings.tr(AppStrings.hijriAdjustment)),
                  subtitle: Text(_formatHijriSubtitle(settings.hijriOffset)),
                  trailing: Icon(
                    Icons.chevron_left_rounded,
                    color: colors.textSecondary,
                  ),
                  onTap: () async {
                    await HijriAdjustmentDialog.show(
                      context: context,
                      initialOffset: settings.hijriOffset,
                      onOffsetSelected: (newOffset) {
                        cubit.updateHijriOffset(newOffset);
                      },
                    );
                  },
                  showDivider: true,
                ),

                // 3. Mushaf Font Size & Layout Info
                AppListTile(
                  leading: Icon(Iconsax.text, color: colors.primary),
                  title: Text(AppStrings.tr(AppStrings.mushafFontSizeTitle)),
                  subtitle: Text(
                    AppStrings.tr(AppStrings.mushafFixedLayoutDesc),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      '١٥ سطراً',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  showDivider: true,
                ),

                // 4. Sources and Attributions
                AppListTile(
                  leading: Icon(Iconsax.book_1, color: colors.primary),
                  title: Text(
                    AppStrings.tr(AppStrings.sourcesAndAttributionsTitle),
                  ),
                  subtitle: Text(
                    AppStrings.tr(AppStrings.sourcesAndAttributionsDesc),
                  ),
                  trailing: Icon(
                    Icons.chevron_left_rounded,
                    color: colors.textSecondary,
                  ),
                  onTap: () {
                    SourcesAndLicensesSheet.show(context);
                  },
                  showDivider: false,
                ),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatHijriSubtitle(int offset) {
    if (offset > 0) return AppStrings.tr(AppStrings.hijriAdvanceOneDay);
    if (offset < 0) return AppStrings.tr(AppStrings.hijriDelayOneDay);
    return AppStrings.tr(AppStrings.hijriDefaultUmmAlQura);
  }
}
