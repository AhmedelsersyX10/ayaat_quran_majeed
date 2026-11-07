import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_section_header.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet for choosing the active Quran reciter and moshaf edition
/// matching reference 18.
///
/// Features:
/// - Pure RTL layout with rounded top corners (AppRadii.xl).
/// - Header with green close (✕) on the right and title "اختيار القارئ" in center.
/// - The cancelled audio-tafsir section ("المختصر الصوتي") and photo dependencies
///   are completely excluded.
/// - Section header "التلاوات" with subtle background banner.
/// - Only lists reciters meeting the timing policy from Task 0.01 (hasAnyTimingSupport).
/// - Visual row design matching reference 18:
///   - Speaker icon on the right (leading).
///   - Reciter name in Arabic.
///   - Green circular info icon (i) on the left (trailing) to view surahs (Ref 36).
///   - Highlighted pure white card background for the active/selected reciter.
/// - Handles Loading, Success, Empty, and Failure states.
class ReciterSelectionSheet extends StatelessWidget {
  final ValueChanged<Reciter>? onReciterInfoTap;

  const ReciterSelectionSheet({
    super.key,
    this.onReciterInfoTap,
  });

  /// Helper static method to display the sheet modally.
  static Future<Reciter?> show(
    BuildContext context, {
    ValueChanged<Reciter>? onReciterInfoTap,
  }) {
    return showModalBottomSheet<Reciter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<ReciterSelectionCubit>(),
        child: ReciterSelectionSheet(
          onReciterInfoTap: onReciterInfoTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: AppSizes.nearFullSheetHeightFactor.sh,
        decoration: BoxDecoration(
          color: colors.scaffoldBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // 1. Header Row (Ref 18: Green ✕ on right, centered title "اختيار القارئ")
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    AppIconButton.ghost(
                      tooltip: AppStrings.tr(AppStrings.close),
                      icon: Icon(
                        Icons.close_rounded,
                        size: AppSizes.iconLg,
                        color: colors.primary,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        AppStrings.tr(AppStrings.selectReciter),
                        textAlign: TextAlign.center,
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Balancing spacer for exact center alignment
                    SizedBox(width: AppSizes.iconLg + AppSpacing.md),
                  ],
                ),
              ),

              // 2. Sheet Content: BlocBuilder
              Expanded(
                child: BlocBuilder<ReciterSelectionCubit, ReciterSelectionState>(
                  builder: (context, state) {
                    if (state is ReciterSelectionLoading ||
                        state is ReciterSelectionInitial) {
                      return Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      );
                    }

                    if (state is ReciterSelectionFailure) {
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
                                  context
                                      .read<ReciterSelectionCubit>()
                                      .loadReciters(forceRefresh: true);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is ReciterSelectionEmpty) {
                      return AppEmptyState(
                        icon: Icon(
                          Icons.mic_off_outlined,
                          size: AppSizes.iconXl * 1.5,
                          color: colors.textMuted,
                        ),
                        title: AppStrings.tr(AppStrings.noRecitersFound),
                        buttonText: AppStrings.tr(AppStrings.retry),
                        onButtonPressed: () {
                          context
                              .read<ReciterSelectionCubit>()
                              .loadReciters(forceRefresh: true);
                        },
                      );
                    }

                    final success = state as ReciterSelectionSuccess;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section Header: "التلاوات" (Ref 18)
                        AppSectionHeader(
                          title: AppStrings.tr(AppStrings.recitations),
                          backgroundColor: colors.surface.withOpacity(0.7),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                        ),

                        // Reciters List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                              horizontal: AppSpacing.sm,
                            ),
                            itemCount: success.reciters.length,
                            itemBuilder: (context, index) {
                              final reciter = success.reciters[index];
                              final isSelected =
                                  reciter.id == success.selectedReciter.id;

                              return _ReciterTile(
                                reciter: reciter,
                                isSelected: isSelected,
                                onSelect: () => _handleReciterSelection(
                                  context,
                                  reciter: reciter,
                                  currentSelection: success,
                                ),
                                onInfo: () => onReciterInfoTap?.call(reciter),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReciterSelection(
    BuildContext context, {
    required Reciter reciter,
    required ReciterSelectionSuccess currentSelection,
  }) {
    final qualifiedMoshafs = reciter.qualifiedMoshafs;
    if (qualifiedMoshafs.isEmpty) return;

    if (qualifiedMoshafs.length == 1) {
      // Single qualified edition: Select and pop directly
      final moshaf = qualifiedMoshafs.first;
      context
          .read<ReciterSelectionCubit>()
          .selectReciterAndMoshaf(reciter: reciter, moshaf: moshaf);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(reciter);
      }
    } else {
      // Multiple qualified editions: prompt to choose moshaf edition
      _showMoshafEditionPicker(
        context,
        reciter: reciter,
        qualifiedMoshafs: qualifiedMoshafs,
        selectedMoshafId: reciter.id == currentSelection.selectedReciter.id
            ? currentSelection.selectedMoshaf.id
            : null,
      );
    }
  }

  void _showMoshafEditionPicker(
    BuildContext context, {
    required Reciter reciter,
    required List<Moshaf> qualifiedMoshafs,
    required int? selectedMoshafId,
  }) {
    final colors = context.colors;
    final cubit = context.read<ReciterSelectionCubit>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: colors.scaffoldBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.tr(AppStrings.chooseMoshafEdition),
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppIconButton.ghost(
                          icon: Icon(
                            Icons.close_rounded,
                            color: colors.textSecondary,
                          ),
                          onPressed: () {
                            if (Navigator.of(modalContext).canPop()) {
                              Navigator.of(modalContext).pop();
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    ...qualifiedMoshafs.map((m) {
                    final isMoshafSelected = m.id == selectedMoshafId;
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: isMoshafSelected
                            ? Colors.white
                            : colors.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          onTap: () {
                            cubit.selectReciterAndMoshaf(
                              reciter: reciter,
                              moshaf: m,
                            );
                            if (Navigator.of(modalContext).canPop()) {
                              Navigator.of(modalContext).pop();
                            }
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop(reciter);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.volume_up_outlined,
                                  color: isMoshafSelected
                                      ? colors.primary
                                      : colors.textSecondary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    m.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: isMoshafSelected
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isMoshafSelected)
                                  Icon(
                                    Icons.check_rounded,
                                    color: colors.primary,
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}

class _ReciterTile extends StatelessWidget {
  final Reciter reciter;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onInfo;

  const _ReciterTile({
    required this.reciter,
    required this.isSelected,
    required this.onSelect,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3.h,
      ),
      child: Material(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        elevation: isSelected ? 0.5 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onSelect,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: isSelected
                  ? Border.all(
                      color: colors.border.withOpacity(0.5),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Right: Speaker Icon (Ref 18)
                Icon(
                  Icons.volume_up_outlined,
                  size: 22.sp,
                  color: isSelected
                      ? colors.primary
                      : colors.textMuted.withOpacity(0.8),
                ),
                SizedBox(width: AppSpacing.md),

                // Middle: Reciter Name
                Expanded(
                  child: Text(
                    reciter.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),

                // Left: Info (i) Icon in Green (Ref 18)
                AppIconButton.ghost(
                  tooltip: AppStrings.tr(AppStrings.reciterNotFound),
                  icon: Icon(
                    Icons.info_outline_rounded,
                    size: 24.sp,
                    color: colors.primary,
                  ),
                  onPressed: onInfo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
