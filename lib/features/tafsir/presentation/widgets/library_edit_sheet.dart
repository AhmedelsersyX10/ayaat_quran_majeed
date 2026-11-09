import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/tafsir_catalog.dart';
import '../../domain/entities/tafsir_book.dart';
import '../../domain/entities/tafsir_category.dart';
import '../cubit/library_cubit.dart';
import '../cubit/library_state.dart';

/// Modal bottom sheet for Library Editing matching Reference 34 ("تحرير المكتبة").
class LibraryEditSheet extends StatelessWidget {
  const LibraryEditSheet({super.key});

  /// Displays the Library Editor modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (sheetContext) => BlocProvider<LibraryCubit>(
        create: (_) => sl<LibraryCubit>()..loadLibrary(),
        child: const LibraryEditSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LibraryCubit, LibraryState>(
      listener: (context, state) {
        if (state.userNotice != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.userNotice!,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryDark,
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<LibraryCubit>().clearNotice();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.destructive,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.92,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.bottomSheetTop,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
                    width: AppSizes.dragHandleWidth,
                    height: AppSizes.dragHandleHeight,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.4),
                      borderRadius: AppRadii.radiusPill,
                    ),
                  ),
                ),

                // Header matching Reference 34: Green '✕' at start, then Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // Green 'X' close button
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.primary,
                            size: 26.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      // Title
                      Text(
                        AppStrings.tr(AppStrings.libraryEditTitle),
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppColors.divider),

                // Content
                Expanded(
                  child: state.status == LibraryStatus.loading && state.myLibraryBooks.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : CustomScrollView(
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            // 1. "مكتبتي" Section
                            SliverToBoxAdapter(
                              child: _buildSectionBanner(AppStrings.tr(AppStrings.myLibrary)),
                            ),

                            SliverToBoxAdapter(
                              child: _buildMyLibraryList(context, state.myLibraryBooks),
                            ),

                            // 2. Available Books by Category
                            ..._buildCategorizedSections(context, state),
                            
                            SliverToBoxAdapter(
                              child: SizedBox(height: AppSpacing.xxl),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shaded banner header matching Reference 34 (#F4EFE9 background, #988875 camel text).
  Widget _buildSectionBanner(String title) {
    return Container(
      width: double.infinity,
      color: AppColors.scaffoldLight,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: const Color(0xFF988875),
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Reorderable list for pinned books inside "مكتبتي".
  Widget _buildMyLibraryList(BuildContext context, List<TafsirBook> books) {
    final cubit = context.read<LibraryCubit>();

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: books.length,
      onReorder: (oldIndex, newIndex) => cubit.reorderMyLibrary(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final book = books[index];
        final isDefault = book.id == TafsirCatalog.defaultBookId;

        return Column(
          key: ValueKey('my_lib_${book.id}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Red circular minus button (Start in RTL)
                  InkWell(
                    onTap: () => cubit.removeFromMyLibrary(book.id),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        color: isDefault
                            ? AppColors.destructive.withOpacity(0.4)
                            : AppColors.destructive,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16.r,
                      ),
                    ),
                  ),

                  SizedBox(width: AppSpacing.md),

                  // Book Title and Author / Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (book.author.isNotEmpty || book.description.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            book.author.isNotEmpty ? book.author : book.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: AppSpacing.md),

                  // Reorder drag handle (End in RTL)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: AppColors.textMuted,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],
        );
      },
    );
  }

  /// Categorized available books matching Reference 34 (ARABIC, ARABIC: GRAMMAR, ENGLISH, etc.).
  List<Widget> _buildCategorizedSections(BuildContext context, LibraryState state) {
    final categorized = state.categorizedAvailableBooks;
    final slivers = <Widget>[];

    // Category configurations in Reference 34 order
    final categories = [
      (TafsirCategory.arabicTafsir, 'ARABIC'),
      (TafsirCategory.arabicGrammar, 'ARABIC: GRAMMAR'),
      (TafsirCategory.englishTranslation, 'ENGLISH'),
      (TafsirCategory.otherTranslations, 'TRANSLATIONS'),
    ];

    for (final entry in categories) {
      final cat = entry.$1;
      final bannerTitle = entry.$2;
      final books = categorized[cat] ?? [];

      if (books.isEmpty) continue;

      // Section Banner
      slivers.add(
        SliverToBoxAdapter(
          child: _buildSectionBanner(bannerTitle),
        ),
      );

      // Book rows
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = books[index];
              return _buildAvailableBookRow(context, book, state);
            },
            childCount: books.length,
          ),
        ),
      );
    }

    return slivers;
  }

  /// Row for an available book with green '+' button or downloading indicator.
  Widget _buildAvailableBookRow(
    BuildContext context,
    TafsirBook book,
    LibraryState state,
  ) {
    final cubit = context.read<LibraryCubit>();
    final isDownloading = state.downloadingProgress.containsKey(book.id);
    final progress = state.downloadingProgress[book.id] ?? 0.0;
    final downloadError = state.failedDownloads[book.id];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Green circular plus button or progress indicator
              if (isDownloading)
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              else if (downloadError != null)
                InkWell(
                  onTap: () => cubit.addToMyLibrary(book.id),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: const BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () => cubit.addToMyLibrary(book.id),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                ),

              SizedBox(width: AppSpacing.md),

              // Book Title and Subtitle / Author details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (book.author.isNotEmpty || book.description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        book.author.isNotEmpty ? book.author : book.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (downloadError != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        downloadError,
                        style: TextStyle(
                          color: AppColors.destructive,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
