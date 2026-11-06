import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_sheet_shell.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/surahs_grouped_list_view.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/json_asset_service.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Tab 0: Surahs & Quarters Index View.
/// Conforms to reference screenshots 03_index_surahs_tab and 04_index_quarters_tab.
/// Uses [IndexSheetShell] driven by [IndexCubit], rendering [SurahsGroupedListView] for Tab 0.
class SurahsTabView extends StatelessWidget {
  const SurahsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IndexCubit>(
      create: (_) => sl.isRegistered<IndexCubit>()
          ? (sl<IndexCubit>()..loadState())
          : (IndexCubit(const _FallbackIndexRepository())..loadState()),
      child: const _SurahsTabViewContent(),
    );
  }
}

class _FallbackIndexRepository implements IndexRepository {
  const _FallbackIndexRepository();

  @override
  Future<IndexTab> getActiveTab() async => IndexTab.surahs;

  @override
  Future<void> setActiveTab(IndexTab tab) async {}

  @override
  Future<List<JuzGroup>> getSurahsGroupedByJuz() async => const [];

  @override
  Future<int> getCurrentReadingSurah() async => 1;
}

class _SurahsTabViewContent extends StatefulWidget {
  const _SurahsTabViewContent();

  @override
  State<_SurahsTabViewContent> createState() => _SurahsTabViewContentState();
}

class _SurahsTabViewContentState extends State<_SurahsTabViewContent>
    with AutomaticKeepAliveClientMixin {
  final QuranMetadataService _metadataService = const QuranMetadataService();

  @override
  bool get wantKeepAlive => true;

  void _navigateToPage(int pageNumber) {
    if (context.mounted) {
      context.go('${AppRoutes.reader}?page=$pageNumber');
    }
  }

  HizbQuarterType _quarterTypeFor(int quarterIndex) {
    switch (quarterIndex % 4) {
      case 1:
        return HizbQuarterType.firstQuarter;
      case 2:
        return HizbQuarterType.half;
      case 3:
        return HizbQuarterType.threeQuarters;
      default:
        return HizbQuarterType.full;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: IndexSheetShell(
        heightFactor: 1.0,
        showDragHandle: false,
        surahsBuilder: (ctx) {
          final state = ctx.watch<IndexCubit>().state;
          return SurahsGroupedListView(
            groups: state.juzGroups,
            currentReadingSurah: state.currentReadingSurah,
            onSurahSelected: (page, _) => _navigateToPage(page),
            onJuzSelected: (page, _) => _navigateToPage(page),
          );
        },
        quartersBuilder: (_) => _buildQuartersList(colors),
      ),
    );
  }

  Widget _buildQuartersList(dynamic colors) {
    final quarters = JsonAssetService.quartersData;

    if (quarters.isEmpty) {
      return Center(
        child: Text(
          AppStrings.tr(AppStrings.loading),
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: quarters.length,
      itemBuilder: (context, index) {
        final quarter = quarters[index];
        final quarterIndex = index + 1;
        final quarterType = _quarterTypeFor(quarterIndex);

        final surahNumber = quarter['surah'] as int? ?? 1;
        final ayahNumber = quarter['ayah'] as int? ?? 1;
        final pageNumber = _metadataService.getPageNumber(surahNumber, ayahNumber);
        final surahName = _metadataService.getSurahNameArabic(surahNumber);
        final quarterText = (quarter['text'] ?? '').toString();

        return Column(
          children: [
            InkWell(
              onTap: () => _navigateToPage(pageNumber),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quarterText,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$surahName - ${AppStrings.tr(AppStrings.ayah)} ${toArabicDigits(ayahNumber)} - '
                            '${AppStrings.tr(AppStrings.page)} ${toArabicDigits(pageNumber)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HizbQuarterIndicator(
                      type: quarterType,
                      size: 34,
                      activeColor: colors.primary,
                      trackColor: colors.surface,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: colors.divider.withValues(alpha: 0.3),
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
            ),
          ],
        );
      },
    );
  }
}
