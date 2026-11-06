import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/surah_index_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Callback invoked when a Surah row is tapped.
/// Passes [pageNumber] and [surahNumber].
typedef SurahSelectedCallback = void Function(int pageNumber, int surahNumber);

/// Callback invoked when a Juz header is tapped.
/// Passes [startPage] and [juzNumber].
typedef JuzSelectedCallback = void Function(int startPage, int juzNumber);

/// Displays the 114 Surahs grouped strictly by Juz, matching Reference Screenshot 03.
///
/// Fully responsive via `flutter_screenutil`, RTL-aligned, and supports jumping
/// directly to the reader by passing primitive page numbers.
class SurahsGroupedListView extends StatelessWidget {
  /// The 30 canonical Juz groups with their respective starting Surahs.
  final List<JuzGroup> groups;

  /// The active/current reading Surah number (1 to 114) highlighted with a primary green badge.
  final int currentReadingSurah;

  /// Optional callback invoked when a Surah row is selected.
  final SurahSelectedCallback? onSurahSelected;

  /// Optional callback invoked when a Juz header is selected.
  final JuzSelectedCallback? onJuzSelected;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Optional list padding.
  final EdgeInsetsGeometry? padding;

  const SurahsGroupedListView({
    super.key,
    required this.groups,
    this.currentReadingSurah = 1,
    this.onSurahSelected,
    this.onJuzSelected,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildFlatList(groups);

    return ListView.builder(
      controller: controller,
      padding: padding ?? EdgeInsets.symmetric(vertical: 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _JuzHeaderItem) {
          return _buildJuzHeader(context, item.group);
        } else if (item is _SurahRowItem) {
          return _buildSurahRow(context, item.surah);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Flattens the [JuzGroup]s into individual list items for lazy recycling.
  List<_IndexListItem> _buildFlatList(List<JuzGroup> groups) {
    final List<_IndexListItem> flat = [];
    for (final group in groups) {
      flat.add(_JuzHeaderItem(group));
      for (final surah in group.surahs) {
        flat.add(_SurahRowItem(surah));
      }
    }
    return flat;
  }

  Widget _buildJuzHeader(BuildContext context, JuzGroup group) {
    final colors = context.colors;
    final juzLabel = '${AppStrings.tr(AppStrings.alJuz)} ${group.nameArabic}';

    return InkWell(
      onTap: onJuzSelected != null
          ? () => onJuzSelected!(group.startPage, group.juzNumber)
          : null,
      child: Padding(
        padding: EdgeInsets.only(
          top: 18.h,
          bottom: 8.h,
          right: 20.w,
          left: 20.w,
        ),
        child: Text(
          juzLabel,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahRow(BuildContext context, SurahIndexItem surah) {
    final colors = context.colors;
    final isCurrent = surah.number == currentReadingSurah;
    final revelationText = surah.isMakki
        ? AppStrings.tr(AppStrings.makki)
        : AppStrings.tr(AppStrings.madani);

    final subtitleText =
        '${AppStrings.tr(AppStrings.alPage)} ${toArabicDigits(surah.pageNumber)} - '
        '${AppStrings.tr(AppStrings.ayahs)} ${toArabicDigits(surah.verseCount)} - '
        '$revelationText';

    return InkWell(
      onTap: onSurahSelected != null
          ? () => onSurahSelected!(surah.pageNumber, surah.number)
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        child: Row(
          children: [
            // Circular Badge with Arabic Numeral (Green if current, Neutral if inactive)
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? colors.primary
                    : const Color(0xFFDDD1C5),
              ),
              alignment: Alignment.center,
              child: Text(
                toArabicDigits(surah.number),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? colors.textOnPrimary
                      : colors.textPrimary,
                ),
              ),
            ),

            SizedBox(width: 14.w),

            // Surah Name and Subtitle Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameArabic,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitleText,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Base sealed type for flattened index list rows.
abstract class _IndexListItem {
  const _IndexListItem();
}

class _JuzHeaderItem extends _IndexListItem {
  final JuzGroup group;
  const _JuzHeaderItem(this.group);
}

class _SurahRowItem extends _IndexListItem {
  final SurahIndexItem surah;
  const _SurahRowItem(this.surah);
}
