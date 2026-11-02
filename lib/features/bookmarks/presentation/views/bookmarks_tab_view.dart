import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

/// Tab 2: Bookmarks View.
/// Conforms to reference screenshot 11_bookmarks_tab.
class BookmarksTabView extends StatefulWidget {
  const BookmarksTabView({super.key});

  @override
  State<BookmarksTabView> createState() => _BookmarksTabViewState();
}

class _BookmarksTabViewState extends State<BookmarksTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const List<Map<String, dynamic>> _defaultColors = [
    {'key': 'red', 'labelKey': AppStrings.colorRed, 'color': Color(0xFFD32F2F)},
    {
      'key': 'yellow',
      'labelKey': AppStrings.colorYellow,
      'color': Color(0xFFFBC02D),
    },
    {
      'key': 'green',
      'labelKey': AppStrings.colorGreen,
      'color': Color(0xFF2E7D32),
    },
    {
      'key': 'blue',
      'labelKey': AppStrings.colorBlue,
      'color': Color(0xFF1976D2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    Widget content = _buildBookmarksContent(colors);

    // Provide BookmarkCubit if registered
    if (sl.isRegistered<BookmarkCubit>()) {
      return BlocProvider.value(
        value: sl<BookmarkCubit>()..loadBookmarks(),
        child: content,
      );
    }

    return content;
  }

  Widget _buildBookmarksContent(dynamic colors) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.tr(AppStrings.editBookmarks),
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              AppStrings.tr(AppStrings.editBookmarks),
              style: AppTypography.titleMedium.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(_defaultColors.length, (index) {
                  final item = _defaultColors[index];
                  final color = item['color'] as Color;
                  final label = AppStrings.tr(item['labelKey'] as String);

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // In future tasks: open bookmarked page if saved
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.bookmark,
                                color: color,
                                size: AppSizes.iconMd,
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  label,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index < _defaultColors.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: AppSpacing.md,
                          endIndent: AppSpacing.md,
                          color: colors.divider.withValues(alpha: 0.3),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
