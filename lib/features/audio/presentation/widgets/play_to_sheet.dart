import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet for configuring recitation range endpoints (Reference 22).
///
/// Layout:
/// 1. Top bar: Back arrow, Surah:Ayah title (e.g. "البقرة: ٦"), Star toggle, Share button.
/// 2. Quick Presets Card:
///    - "نهاية الصفحة" with current page number
///    - "نهاية السورة" with current surah name
///    - "تلاوة مستمرة" with infinity symbol (∞)
/// 3. Segmented Tab Switcher (3 options):
///    - "الآيات" (Ayat): selectable verses from starting position forward
///    - "الصفحات" (Pages): selectable pages from current page forward
///    - "السور" (Surahs): selectable surahs from current surah forward
/// 4. Dynamic selection list respecting inclusive boundaries and end-before-start validation.
class PlayToSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final bool isStarred;
  final VoidCallback? onStarTap;
  final VoidCallback? onShareTap;
  final ValueChanged<PlaybackRange>? onRangeSelected;
  final QuranMetadataService metadataService;

  const PlayToSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    this.isStarred = false,
    this.onStarTap,
    this.onShareTap,
    this.onRangeSelected,
    this.metadataService = const QuranMetadataService(),
  });

  /// Displays the Play To modal bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    bool isStarred = false,
    VoidCallback? onStarTap,
    VoidCallback? onShareTap,
    ValueChanged<PlaybackRange>? onRangeSelected,
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) => PlayToSheet(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        isStarred: isStarred,
        onStarTap: onStarTap,
        onShareTap: onShareTap,
        onRangeSelected: onRangeSelected,
        metadataService: metadataService,
      ),
    );
  }

  @override
  State<PlayToSheet> createState() => _PlayToSheetState();
}

class _PlayToSheetState extends State<PlayToSheet> {
  int _selectedTabIndex = 0; // 0: الآيات, 1: الصفحات, 2: السور
  late bool _starred;
  late final int _currentPage;
  late final List<Map<String, dynamic>> _remainingVerses;

  @override
  void initState() {
    super.initState();
    _starred = widget.isStarred;
    _currentPage = widget.metadataService.getPageNumber(
      widget.surahNumber,
      widget.verseNumber,
    );

    // Build the list of selectable verses starting from (surahNumber, verseNumber) forward
    final allVerses = widget.metadataService.allVersesRawData;
    final startIndex = allVerses.indexWhere(
      (v) =>
          (v['sora'] == widget.surahNumber || v['surah'] == widget.surahNumber) &&
          (v['aya_no'] == widget.verseNumber || v['ayah'] == widget.verseNumber),
    );

    if (startIndex != -1) {
      _remainingVerses = allVerses.sublist(startIndex);
    } else {
      _remainingVerses = allVerses;
    }
  }

  void _handleStarToggle() {
    setState(() {
      _starred = !_starred;
    });
    widget.onStarTap?.call();
  }

  void _selectRange(int endSurah, int endAyah) {
    final range = PlaybackRange(
      startSurah: widget.surahNumber,
      startAyah: widget.verseNumber,
      endSurah: endSurah,
      endAyah: endAyah,
    );

    Navigator.of(context).pop();

    if (widget.onRangeSelected != null) {
      widget.onRangeSelected!(range);
    } else {
      context.read<AudioPlaybackCubit>().updateRange(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahName =
        widget.metadataService.getSurahNameArabic(widget.surahNumber);
    final ayahNumeral = toArabicDigits(widget.verseNumber);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.45, 0.88, 0.95],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. Top Header Bar (Reference 22)
                _buildHeader(context, surahName, ayahNumeral),

                // 2. Presets Card (End of Page / End of Surah / Continuous)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildPresetsCard(surahName),
                ),

                SizedBox(height: 12.h),

                // 3. Segmented 3-Tab Control
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: _buildSegmentedTabs(),
                ),

                SizedBox(height: 10.h),

                // 4. Scrollable List of Targets (Ayat, Pages, Surahs)
                Expanded(
                  child: _buildTabContent(scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String surahName,
    String ayahNumeral,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right (RTL start): Back Arrow + Surah:Ayah Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: 'رجوع',
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$surahName: $ayahNumeral',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Left (RTL end): Star Toggle & Share Action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: 'تمييز بنجمة',
                child: InkWell(
                  onTap: _handleStarToggle,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      _starred ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Semantics(
                button: true,
                label: 'مشاركة',
                child: InkWell(
                  onTap: widget.onShareTap,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.share_outlined,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsCard(String surahName) {
    // Determine end of current page
    final pageSegments = widget.metadataService.getPageData(_currentPage);
    final lastSegment = pageSegments.isNotEmpty ? pageSegments.last : null;
    final int pageEndSurah =
        lastSegment != null ? (lastSegment['surah'] as int) : widget.surahNumber;
    final int pageEndAyah =
        lastSegment != null ? (lastSegment['end'] as int) : widget.verseNumber;

    // Determine end of current surah
    final int surahEndAyah =
        widget.metadataService.getVerseCount(widget.surahNumber);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: نهاية الصفحة
          _buildPresetRow(
            title: AppStrings.tr(AppStrings.endOfPage),
            subtitle:
                '${AppStrings.tr(AppStrings.pagePrefix)} ${toArabicDigits(_currentPage)}',
            onTap: () => _selectRange(pageEndSurah, pageEndAyah),
          ),
          _buildDivider(),

          // Row 2: نهاية السورة
          _buildPresetRow(
            title: AppStrings.tr(AppStrings.endOfSurah),
            subtitle: surahName,
            onTap: () => _selectRange(widget.surahNumber, surahEndAyah),
          ),
          _buildDivider(),

          // Row 3: تلاوة مستمرة (∞)
          _buildPresetRow(
            title: AppStrings.tr(AppStrings.continuousRecitation),
            subtitle: '∞',
            onTap: () => _selectRange(114, 6),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title (Right)
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            // Subtitle / indicator (Left)
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    final tabs = [
      AppStrings.tr(AppStrings.ayatTab),
      AppStrings.tr(AppStrings.pages),
      AppStrings.tr(AppStrings.tabSurahs),
    ];

    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.border.withOpacity(0.8),
          width: 0.8,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.tabPillActiveTan
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(ScrollController scrollController) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAyatList(scrollController);
      case 1:
        return _buildPagesList(scrollController);
      case 2:
        return _buildSurahsList(scrollController);
      default:
        return _buildAyatList(scrollController);
    }
  }

  /// Tab 0: List of verses starting from current verse forward.
  Widget _buildAyatList(ScrollController scrollController) {
    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _remainingVerses.length,
      separatorBuilder: (_, __) => _buildDivider(),
      itemBuilder: (context, index) {
        final item = _remainingVerses[index];
        final int surah = (item['sora'] ?? item['surah']) as int;
        final int ayah = (item['aya_no'] ?? item['ayah']) as int;
        final String sName = widget.metadataService.getSurahNameArabic(surah);
        final String verseText = widget.metadataService.getVerse(surah, ayah);

        return InkWell(
          onTap: () => _selectRange(surah, ayah),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Surah:Ayah on right, Ayah numeral on left
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$sName: ${toArabicDigits(ayah)}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      toArabicDigits(ayah),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Verse Quranic text
                Text(
                  verseText,
                  style: AppTypography.quranText.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.textPrimary,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tab 1: List of pages starting from current page to 604.
  Widget _buildPagesList(ScrollController scrollController) {
    final pageCount = 604 - _currentPage + 1;

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: pageCount,
      separatorBuilder: (_, __) => _buildDivider(),
      itemBuilder: (context, index) {
        final targetPage = _currentPage + index;
        final segments = widget.metadataService.getPageData(targetPage);
        final lastSegment = segments.isNotEmpty ? segments.last : null;
        final int lastSurah =
            lastSegment != null ? (lastSegment['surah'] as int) : widget.surahNumber;
        final int lastAyah =
            lastSegment != null ? (lastSegment['end'] as int) : widget.verseNumber;
        final String sName = widget.metadataService.getSurahNameArabic(lastSurah);
        final int juzNum =
            widget.metadataService.getJuzNumberForPage(targetPage);
        final String juzName = widget.metadataService.getJuzNameArabic(juzNum);

        return InkWell(
          onTap: () => _selectRange(lastSurah, lastAyah),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right: Page title & Surah name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.tr(AppStrings.pagePrefix)} ${toArabicDigits(targetPage)}',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'سورة $sName',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Left: Juz designation
                Text(
                  'الجزء $juzName',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tab 2: List of surahs starting from current surah to 114.
  Widget _buildSurahsList(ScrollController scrollController) {
    final surahCount = 114 - widget.surahNumber + 1;

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: surahCount,
      separatorBuilder: (_, __) => _buildDivider(),
      itemBuilder: (context, index) {
        final targetSurah = widget.surahNumber + index;
        final String sName = widget.metadataService.getSurahNameArabic(targetSurah);
        final int verseCount = widget.metadataService.getVerseCount(targetSurah);
        final bool isMakki = widget.metadataService.isMakki(targetSurah);

        return InkWell(
          onTap: () => _selectRange(targetSurah, verseCount),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right: Surah name & metadata
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سورة $sName',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'آياتها ${toArabicDigits(verseCount)} - ${isMakki ? 'مكية' : 'مدنية'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Left: Surah numeral
                Text(
                  toArabicDigits(targetSurah),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}

