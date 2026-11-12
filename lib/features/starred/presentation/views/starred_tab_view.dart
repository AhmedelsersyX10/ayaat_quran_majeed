import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_cubit.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_state.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/widgets/starred_surah_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Tab 3: Starred Verses View ("مميزة بنجمة").
/// Pixel-faithful implementation matching reference screenshots 12 (empty) & 28 (populated).
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

    try {
      context.read<StarredCubit>();
      return BlocBuilder<StarredCubit, StarredState>(
        builder: (context, state) => _buildView(context, state),
      );
    } catch (_) {
      if (sl.isRegistered<StarredCubit>()) {
        return BlocProvider.value(
          value: sl<StarredCubit>()..loadStarredVerses(),
          child: BlocBuilder<StarredCubit, StarredState>(
            builder: (context, state) => _buildView(context, state),
          ),
        );
      }
      return _buildView(
        context,
        const StarredState(
          isLoading: false,
          items: [],
          groups: [],
          starredKeys: {},
        ),
      );
    }
  }

  Widget _buildView(BuildContext context, StarredState state) {
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
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.isEmpty
                ? _buildEmptyState(colors)
                : _buildPopulatedList(context, state),
      ),
    );
  }

  /// Empty state conforming to reference screenshot 12_starred_empty.
  Widget _buildEmptyState(dynamic colors) {
    return Center(
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
    );
  }

  /// Populated list conforming to reference screenshot 28_starred_list_with_data.
  Widget _buildPopulatedList(BuildContext context, StarredState state) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: state.groups.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final group = state.groups[index];
        return StarredSurahGroupCard(
          group: group,
          onItemTap: (item) => _navigateToAyah(context, item),
        );
      },
    );
  }

  void _navigateToAyah(BuildContext context, StarredAyahItem item) {
    context.pushNamed(
      AppRoutes.readerName,
      queryParameters: {
        'page': item.pageNumber.toString(),
        'surah': item.surahNumber.toString(),
        'ayah': item.verseNumber.toString(),
      },
    );
  }
}
