import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_segmented_tabs.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/json_asset_service.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tab 0: Surahs & Quarters Index View.
/// Conforms to reference screenshots 03_index_surahs_tab and 04_index_quarters_tab.
class SurahsTabView extends StatefulWidget {
  const SurahsTabView({super.key});

  @override
  State<SurahsTabView> createState() => _SurahsTabViewState();
}

class _SurahsTabViewState extends State<SurahsTabView>
    with AutomaticKeepAliveClientMixin {
  final QuranMetadataService _metadataService = const QuranMetadataService();
  int _selectedSegment = 0;
  int _lastReadSurah = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  void _loadLastRead() {
    try {
      final lastReadVal = getValue('lastRead');
      if (lastReadVal != null && lastReadVal != 'non') {
        final page = int.tryParse(lastReadVal.toString()) ?? 1;
        final pageData = _metadataService.getPageData(page);
        if (pageData.isNotEmpty && pageData[0]['surah'] != null) {
          _lastReadSurah = pageData[0]['surah'] as int;
        }
      }
    } catch (_) {}
  }

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
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          AppStrings.tr(AppStrings.indexTitle),
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: colors.textPrimary,
              size: AppSizes.iconMd,
            ),
            tooltip: AppStrings.tr(AppStrings.close),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.reader);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: AppSegmentedTabs(
              tabs: [
                AppStrings.tr(AppStrings.tabSurahs),
                AppStrings.tr(AppStrings.tabQuarters),
              ],
              selectedIndex: _selectedSegment,
              onTabChanged: (index) {
                setState(() => _selectedSegment = index);
              },
            ),
          ),
        ),
      ),
      body: _selectedSegment == 0
          ? _buildSurahsList(colors)
          : _buildQuartersList(colors),
    );
  }

  Widget _buildSurahsList(dynamic colors) {
    final surahsData = JsonAssetService.surahsData;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: 114,
      itemBuilder: (context, index) {
        final surahNumber = index + 1;
        final startPage = _metadataService.getPageNumber(surahNumber, 1);
        final ayahCount = _metadataService.getVerseCount(surahNumber);
        final surahName = _metadataService.getSurahNameArabic(surahNumber);

        String revelationType = AppStrings.tr(AppStrings.makki);
        if (surahsData.length >= surahNumber) {
          final surahJson = surahsData[index];
          final type = (surahJson['revelationType'] ?? '').toString();
          if (type.toLowerCase() == 'medinan') {
            revelationType = AppStrings.tr(AppStrings.madani);
          }
        }

        final isCurrentSurah = surahNumber == _lastReadSurah;

        // Check if this surah starts a new Juz
        final currentJuz = _metadataService.getJuzNumber(surahNumber, 1);
        final previousJuz = surahNumber > 1
            ? _metadataService.getJuzNumber(surahNumber - 1, 1)
            : 0;
        final isJuzStart = currentJuz != previousJuz;
        final juzOrdinal =
            ArabicNumbers.juzOrdinalNames[currentJuz] ??
            toArabicDigits(currentJuz);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isJuzStart)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Text(
                  '${AppStrings.tr(AppStrings.juz)} $juzOrdinal',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            InkWell(
              onTap: () => _navigateToPage(startPage),
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
                            surahName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppStrings.tr(AppStrings.page)} ${toArabicDigits(startPage)} - '
                            '${AppStrings.tr(AppStrings.ayahs)} ${toArabicDigits(ayahCount)} - '
                            '$revelationType',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentSurah
                            ? colors.primary
                            : colors.surface.withValues(alpha: 0.8),
                        border: Border.all(
                          color: isCurrentSurah
                              ? colors.primary
                              : colors.divider.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        toArabicDigits(surahNumber),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isCurrentSurah
                              ? Colors.white
                              : colors.textPrimary,
                        ),
                      ),
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

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: quarters.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        color: colors.divider.withValues(alpha: 0.3),
        indent: AppSpacing.md,
        endIndent: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final quarter = quarters[index];
        final surahId = (quarter['surah'] ?? 1) as int;
        final ayahId = (quarter['ayah'] ?? 1) as int;
        final page = _metadataService.getPageNumber(surahId, ayahId);
        final surahName = _metadataService.getSurahNameArabic(surahId);
        final quarterText = (quarter['text'] ?? '') as String;
        final quarterIndex = (index % 8) + 1;

        return InkWell(
          onTap: () => _navigateToPage(page),
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
                        quarterText.isNotEmpty ? quarterText : surahName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$surahName - ${AppStrings.tr(AppStrings.page)} ${toArabicDigits(page)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                HizbQuarterIndicator(type: _quarterTypeFor(quarterIndex)),
              ],
            ),
          ),
        );
      },
    );
  }
}
