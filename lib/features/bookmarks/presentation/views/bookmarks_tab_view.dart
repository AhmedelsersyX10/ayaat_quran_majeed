import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/cubit/bookmark_state.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_edit_dialog.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_row_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Tab 2: Bookmarks View ("الفواصل").
/// Pixel-faithful implementation matching reference screenshots 11 & 27.
class BookmarksTabView extends StatefulWidget {
  const BookmarksTabView({super.key});

  @override
  State<BookmarksTabView> createState() => _BookmarksTabViewState();
}

class _BookmarksTabViewState extends State<BookmarksTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    try {
      context.read<BookmarkCubit>();
      return BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) => _buildView(context, state),
      );
    } catch (_) {
      if (sl.isRegistered<BookmarkCubit>()) {
        return BlocProvider.value(
          value: sl<BookmarkCubit>()..loadBookmarks(),
          child: BlocBuilder<BookmarkCubit, BookmarkState>(
            builder: (context, state) => _buildView(context, state),
          ),
        );
      }
      return _buildView(
        context,
        BookmarkState(isLoading: false, bookmarks: BookmarkItem.defaultSlots()),
      );
    }
  }

  Widget _buildView(BuildContext context, BookmarkState state) {
    final colors = context.colors;
    final isEditMode = state.isEditMode;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          AppStrings.tr(AppStrings.bookmarksTitle),
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                context.read<BookmarkCubit>().toggleEditMode();
              } catch (_) {
                if (sl.isRegistered<BookmarkCubit>()) {
                  sl<BookmarkCubit>().toggleEditMode();
                }
              }
            },
            child: Text(
              isEditMode
                  ? AppStrings.tr(AppStrings.done)
                  : AppStrings.tr(AppStrings.editBookmarks),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(state.bookmarks.length, (index) {
                        final item = state.bookmarks[index];
                        final isLast = index == state.bookmarks.length - 1;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BookmarkRowItem(
                              item: item,
                              isEditMode: isEditMode,
                              onTap: () {
                                if (item.isAssigned &&
                                    item.pageNumber != null) {
                                  context.pushNamed(
                                    AppRoutes.readerName,
                                    queryParameters: {
                                      'page': item.pageNumber.toString(),
                                      if (item.surahNumber != null)
                                        'surah': item.surahNumber.toString(),
                                      if (item.verseNumber != null)
                                        'ayah': item.verseNumber.toString(),
                                    },
                                  );
                                }
                              },
                              onUnassign: () {
                                context.read<BookmarkCubit>().unassignBookmark(
                                  item.id,
                                );
                              },
                              onEdit: () {
                                BookmarkEditDialog.show(
                                  context: context,
                                  item: item,
                                  onSave: (newName, newColorHex) {
                                    context
                                        .read<BookmarkCubit>()
                                        .updateBookmarkMetadata(
                                          item.id,
                                          name: newName,
                                          colorHex: newColorHex,
                                        );
                                  },
                                );
                              },
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                indent: AppSpacing.md,
                                endIndent: AppSpacing.md,
                                color: colors.divider.withOpacity(0.3),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  if (isEditMode) ...[
                    SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          BookmarkEditDialog.show(
                            context: context,
                            item: BookmarkItem(
                              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                              name: 'فاصل جديد',
                              colorHex: '#8E44AD',
                              isDefault: false,
                            ),
                            onSave: (newName, newColorHex) {
                              context.read<BookmarkCubit>().addCustomBookmark(
                                BookmarkItem(
                                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                  name: newName,
                                  colorHex: newColorHex,
                                  isDefault: false,
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        label: Text(
                          AppStrings.tr(AppStrings.newBookmark),
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
