import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_feedback_states.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_segmented_tabs.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

/// Pixel-faithful responsive Index Bottom Sheet Shell conforming to References 03 and 04.
///
/// Features:
/// - Responsive height leaving the underlying mushaf header partially visible.
/// - Top rounded corners matching design system tokens.
/// - Centered outlined segmented tabs: "السور" (right) and "الأرباع" (left) in RTL.
/// - Dynamic "الفهرس" title display (shown on Surahs tab matching Ref 03; omitted on Quarters matching Ref 04).
/// - Decoupled architecture: accepts tab slot builders, keeping shell chrome isolated from data lists.
/// - Native presentation of loading, empty, and failure feedback states.
class IndexSheetShell extends StatelessWidget {
  /// Optional builder for the Surahs tab content.
  final WidgetBuilder? surahsBuilder;

  /// Optional builder for the Quarters tab content.
  final WidgetBuilder? quartersBuilder;

  /// Optional standalone widget for Surahs tab (alternative to builder).
  final Widget? surahsChild;

  /// Optional standalone widget for Quarters tab (alternative to builder).
  final Widget? quartersChild;

  /// Height factor relative to the screen height (defaults to 0.88 to expose top background).
  final double heightFactor;

  /// Whether to display a subtle top drag handle indicator.
  final bool showDragHandle;

  /// Optional callback invoked when the user swipes down to close.
  final VoidCallback? onClose;

  const IndexSheetShell({
    super.key,
    this.surahsBuilder,
    this.quartersBuilder,
    this.surahsChild,
    this.quartersChild,
    this.heightFactor = 0.88,
    this.showDragHandle = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * heightFactor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: BlocBuilder<IndexCubit, IndexState>(
            builder: (context, state) {
              final cubit = context.read<IndexCubit>();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle Indicator
                  if (showDragHandle) ...[
                    SizedBox(height: 8.h),
                    Center(
                      child: Container(
                        width: AppSizes.dragHandleWidth,
                        height: AppSizes.dragHandleHeight,
                        decoration: BoxDecoration(
                          color: colors.textMuted.withValues(alpha: 0.4),
                          borderRadius: AppRadii.radiusPill,
                        ),
                      ),
                    ),
                  ],

                  // Top Centered Outlined Segmented Tabs (Screens 03 & 04)
                  SizedBox(height: 10.h),
                  Center(
                    child: AppSegmentedTabs(
                      width: 200.w,
                      height: 38.h,
                      variant: AppSegmentedTabVariant.outlined,
                      tabs: [
                        AppStrings.tr(AppStrings.tabSurahs),
                        AppStrings.tr(AppStrings.tabQuarters),
                      ],
                      selectedIndex: state.selectedTab.index,
                      onTabChanged: (index) {
                        final targetTab = IndexTab.values[index];
                        cubit.selectTab(targetTab);
                      },
                    ),
                  ),

                  // Dynamic "الفهرس" Title: shown on Surahs tab (Ref 03), hidden on Quarters (Ref 04)
                  if (state.selectedTab == IndexTab.surahs &&
                      state.status != IndexStatus.loading &&
                      state.status != IndexStatus.failure) ...[
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        AppStrings.tr(AppStrings.indexTitle),
                        style: AppTypography.displayLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),

                  // Content Area or Feedback States
                  Expanded(
                    child: _buildContent(context, state, cubit),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    IndexState state,
    IndexCubit cubit,
  ) {
    if (state.isLoading) {
      return AppLoadingState(
        message: AppStrings.tr(AppStrings.loading),
      );
    }

    if (state.isFailure) {
      return AppErrorState(
        message: state.errorMessage != null
            ? AppStrings.tr(state.errorMessage!)
            : AppStrings.tr(AppStrings.indexLoadFailed),
        onRetry: () => cubit.retry(),
      );
    }

    if (state.isEmpty) {
      return AppEmptyState(
        icon: Icon(
          Iconsax.book_1,
          size: 48.sp,
          color: context.colors.textMuted,
        ),
        title: AppStrings.tr(AppStrings.emptyIndex),
      );
    }

    // Success State: Render active tab slot
    if (state.selectedTab == IndexTab.surahs) {
      if (surahsBuilder != null) {
        return surahsBuilder!(context);
      }
      return surahsChild ?? const _DefaultIndexSlotPlaceholder(isSurahs: true);
    } else {
      if (quartersBuilder != null) {
        return quartersBuilder!(context);
      }
      return quartersChild ??
          const _DefaultIndexSlotPlaceholder(isSurahs: false);
    }
  }
}

/// Fallback placeholder when no tab slot child or builder is provided.
class _DefaultIndexSlotPlaceholder extends StatelessWidget {
  final bool isSurahs;

  const _DefaultIndexSlotPlaceholder({required this.isSurahs});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = isSurahs
        ? AppStrings.tr(AppStrings.tabSurahs)
        : AppStrings.tr(AppStrings.tabQuarters);

    return Center(
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

