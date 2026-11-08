import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_dialog_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reciter Surahs & Offline Download Page matching Reference Screenshot 36.
///
/// Features:
/// - RTL Directionality throughout.
/// - Top App Bar: Green back arrow on right and Reciter name.
/// - Grouped by starting Juz (e.g. "الجزء ١", "الجزء ٣", etc.) with shaded header bars.
/// - Per-surah download actions:
///   - Not downloaded: Green outline cloud with down arrow (Reference 36).
///   - Downloading: Circular progress indicator with cancel option.
///   - Downloaded: Green checkmark ("وعلامة خضراء للمكتمل").
///   - Failed: Retry icon with error indication.
/// - Tapping a surah row initiates audio playback (offline or streaming).
class ReciterSurahsPage extends StatelessWidget {
  final int reciterId;
  final int? moshafId;

  const ReciterSurahsPage({
    super.key,
    required this.reciterId,
    this.moshafId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        body: SafeArea(
          child: BlocBuilder<ReciterSurahsCubit, ReciterSurahsState>(
            builder: (context, state) {
              if (state is ReciterSurahsLoading || state is ReciterSurahsInitial) {
                return Center(
                  child: CircularProgressIndicator(color: colors.primary),
                );
              }

              if (state is ReciterSurahsFailure) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: AppSizes.iconXl * 1.5,
                          color: colors.error,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          state.message,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        AppButton.primary(
                          text: AppStrings.tr(AppStrings.retry),
                          onPressed: () {
                            context.read<ReciterSurahsCubit>().loadSurahs(
                                  reciterId: reciterId,
                                  moshafId: moshafId,
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              final loaded = state as ReciterSurahsLoaded;

              return Column(
                children: [
                  // 1. Top Bar (Reference 36: Green back arrow on right, reciter name)
                  _buildHeader(context, loaded.reciter.name),

                  // 2. Grouped Surahs List
                  Expanded(
                    child: _buildSurahsList(context, loaded),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String reciterName) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Green back arrow (points right in RTL, popping current screen)
          AppIconButton.ghost(
            tooltip: AppStrings.tr(AppStrings.returnHome),
            icon: Icon(
              Icons.arrow_forward_rounded,
              size: AppSizes.iconLg,
              color: colors.primary,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              reciterName,
              style: AppTypography.titleLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahsList(BuildContext context, ReciterSurahsLoaded state) {
    if (state.surahs.isEmpty) {
      return AppEmptyState(
        icon: Icon(
          Icons.mic_off_outlined,
          size: AppSizes.iconXl * 1.5,
          color: context.colors.textMuted,
        ),
        title: AppStrings.tr(AppStrings.noRecitersFound),
      );
    }

    final flatItems = _flattenJuzGroups(state.juzGroups);

    return ListView.builder(
      itemCount: flatItems.length,
      itemBuilder: (context, index) {
        final item = flatItems[index];

        if (item is _JuzHeaderListItem) {
          return _buildJuzHeader(context, item.juzNumber);
        } else if (item is _SurahRowListItem) {
          final surah = item.surah;
          final status = state.downloadStatuses[surah.surahNumber] ??
              SurahDownloadStatus.notDownloaded;
          final progress = state.downloadProgresses[surah.surahNumber] ?? 0.0;

          return _buildSurahRow(
            context,
            surah: surah,
            status: status,
            progress: progress,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildJuzHeader(BuildContext context, int juzNumber) {
    final colors = context.colors;
    final arabicJuzNum = toArabicDigits(juzNumber);
    final headerTitle = '${AppStrings.tr(AppStrings.alJuz)} $arabicJuzNum';

    return Container(
      width: double.infinity,
      color: colors.border.withOpacity(0.35),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        headerTitle,
        style: AppTypography.titleSmall.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSurahRow(
    BuildContext context, {
    required ReciterSurah surah,
    required SurahDownloadStatus status,
    required double progress,
  }) {
    final colors = context.colors;

    return InkWell(
      onTap: () => _handleSurahTap(context, surah),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.divider.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Surah Name on the right in RTL
            Expanded(
              child: Text(
                surah.surahName,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Download action / indicator on the left
            _buildDownloadAction(
              context,
              surah: surah,
              status: status,
              progress: progress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadAction(
    BuildContext context, {
    required ReciterSurah surah,
    required SurahDownloadStatus status,
    required double progress,
  }) {
    final colors = context.colors;
    final cubit = context.read<ReciterSurahsCubit>();

    switch (status) {
      case SurahDownloadStatus.downloaded:
        // Completed: Green checkmark ("وعلامة خضراء للمكتمل")
        return AppIconButton.ghost(
          tooltip: AppStrings.tr(AppStrings.deleteDownload),
          icon: Icon(
            Icons.check_circle_rounded,
            size: AppSizes.iconLg,
            color: colors.primary,
          ),
          onPressed: () => _confirmDeleteSurah(context, surah),
        );

      case SurahDownloadStatus.downloading:
        // In Progress: Circular progress with cancel button
        return SizedBox(
          width: 36.w,
          height: 36.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 2.5,
                color: colors.primary,
                backgroundColor: colors.primary.withOpacity(0.15),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: AppSizes.iconSm,
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.primary,
                ),
                onPressed: () => cubit.cancelDownload(surah.surahNumber),
              ),
            ],
          ),
        );

      case SurahDownloadStatus.failed:
        // Failed: Retry icon
        return AppIconButton.ghost(
          tooltip: AppStrings.tr(AppStrings.retry),
          icon: Icon(
            Icons.refresh_rounded,
            size: AppSizes.iconLg,
            color: colors.error,
          ),
          onPressed: () => cubit.downloadSurah(surah.surahNumber),
        );

      case SurahDownloadStatus.notDownloaded:
        // Not Downloaded: Green outline cloud with down arrow (Reference 36)
        return AppIconButton.ghost(
          tooltip: AppStrings.tr(AppStrings.downloadSurah),
          icon: Icon(
            Icons.cloud_download_outlined,
            size: AppSizes.iconLg,
            color: colors.primary,
          ),
          onPressed: () => cubit.downloadSurah(surah.surahNumber),
        );
    }
  }

  void _handleSurahTap(BuildContext context, ReciterSurah surah) {
    try {
      context.read<AudioPlaybackCubit>().playSurah(surah.surahNumber);
    } catch (_) {}
  }

  void _confirmDeleteSurah(BuildContext context, ReciterSurah surah) {
    final colors = context.colors;
    final cubit = context.read<ReciterSurahsCubit>();

    AppDialogShell.show(
      context: context,
      title: AppStrings.tr(AppStrings.deleteDownload),
      actions: [
        AppButton.secondary(
          text: AppStrings.tr(AppStrings.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.destructive(
          text: AppStrings.tr(AppStrings.delete),
          onPressed: () {
            Navigator.of(context).pop();
            cubit.deleteDownloadedSurah(surah.surahNumber);
          },
        ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          AppStrings.tr(AppStrings.deleteDownloadConfirm),
          style: AppTypography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<dynamic> _flattenJuzGroups(List<ReciterJuzGroup> groups) {
    final List<dynamic> flat = [];
    for (final group in groups) {
      flat.add(_JuzHeaderListItem(group.juzNumber));
      for (final surah in group.surahs) {
        flat.add(_SurahRowListItem(surah));
      }
    }
    return flat;
  }
}

class _JuzHeaderListItem {
  final int juzNumber;
  const _JuzHeaderListItem(this.juzNumber);
}

class _SurahRowListItem {
  final ReciterSurah surah;
  const _SurahRowListItem(this.surah);
}
