import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Result object emitted when an ayah is picked.
class AyahPickerResult {
  final int surahNumber;
  final int ayahNumber;

  const AyahPickerResult({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  String toString() => 'AyahPickerResult($surahNumber:$ayahNumber)';
}

/// Modal bottom sheet for choosing an ayah within a surah or across all surahs.
///
/// Pixel-faithful replica of references 38 ("اختيار الآية") and 39
/// (scrolled to selected ayah with green checkmark).
/// Used for direct reader jump and for Recitation Settings range picker (ref 40).
class AyahPickerSheet extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;
  final ValueChanged<int>? onAyahSelected;
  final void Function(int surahNumber, int ayahNumber)? onVerseSelected;
  final QuranMetadataService metadataService;

  const AyahPickerSheet({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
    this.onAyahSelected,
    this.onVerseSelected,
    this.metadataService = const QuranMetadataService(),
  });

  /// Displays the picker in a standard modal bottom sheet.
  /// Returns the chosen [AyahPickerResult], or null if dismissed without selection.
  static Future<AyahPickerResult?> show(
    BuildContext context, {
    required int surahNumber,
    int? initialAyahNumber,
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) {
    return showModalBottomSheet<AyahPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      useSafeArea: true,
      builder: (ctx) => AyahPickerSheet(
        surahNumber: surahNumber,
        initialAyahNumber: initialAyahNumber,
        metadataService: metadataService,
      ),
    );
  }

  @override
  State<AyahPickerSheet> createState() => _AyahPickerSheetState();
}

class _AyahPickerSheetState extends State<AyahPickerSheet> {
  late int _currentSurah;
  late int _selectedAyah;
  late ScrollController _scrollController;
  late int _verseCount;
  late String _surahName;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surahNumber.clamp(1, 114);
    _verseCount = widget.metadataService.getVerseCount(_currentSurah);
    _surahName = widget.metadataService.getSurahNameArabic(_currentSurah);
    _selectedAyah = widget.initialAyahNumber?.clamp(1, _verseCount) ?? 1;

    // Approximate row height ~70dp to scroll to selected item on open
    final double initialOffset =
        _selectedAyah > 4 ? ((_selectedAyah - 4) * 60.0) : 0.0;
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSelect(int ayahNumber) {
    setState(() {
      _selectedAyah = ayahNumber;
    });
    widget.onAyahSelected?.call(ayahNumber);
    widget.onVerseSelected?.call(_currentSurah, ayahNumber);
    Navigator.of(context).pop(AyahPickerResult(
      surahNumber: _currentSurah,
      ayahNumber: ayahNumber,
    ));
  }

  void _changeSurah(int newSurah) {
    if (newSurah == _currentSurah) return;
    setState(() {
      _currentSurah = newSurah;
      _verseCount = widget.metadataService.getVerseCount(_currentSurah);
      _surahName = widget.metadataService.getSurahNameArabic(_currentSurah);
      _selectedAyah = 1;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _showSurahSelector() {
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.tr(AppStrings.tabSurahs),
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.divider),
                Expanded(
                  child: ListView.separated(
                    itemCount: 114,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final surahNum = index + 1;
                      final name = widget.metadataService.getSurahNameArabic(surahNum);
                      final verses = widget.metadataService.getVerseCount(surahNum);
                      final isSelected = surahNum == _currentSurah;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16.r,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.mushafBadgeFill,
                          child: Text(
                            toArabicDigits(surahNum),
                            style: AppTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.mushafBadgeText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'سورة $name',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'آياتها ${toArabicDigits(verses)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.of(ctx).pop(surahNum);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((selected) {
      if (selected != null) {
        _changeSurah(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top App Bar / Title (Ref 38 & 39)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: AppStrings.tr(AppStrings.close),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppStrings.tr(AppStrings.selectAyah),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Surah Name Header Banner (Ref 38 & 39)
            InkWell(
              onTap: _showSurahSelector,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                color: const Color(0xFFF4EFE6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _surahName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.mushafBadgeText,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.mushafBadgeText,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Verses List (Ref 38 & 39)
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: _verseCount,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, index) {
                  final int ayahNumber = index + 1;
                  final bool isSelected = ayahNumber == _selectedAyah;
                  final String verseText = widget.metadataService.getVerse(
                    _currentSurah,
                    ayahNumber,
                  );

                  return InkWell(
                    onTap: () => _handleSelect(ayahNumber),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ayah title & text preview
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_surahName : ${toArabicDigits(ayahNumber)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  verseText,
                                  style: TextStyle(
                                    fontFamily: 'AmiriQuran',
                                    fontSize: 16.sp,
                                    height: 1.8,
                                    color: AppColors.mushafOrnament,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Green Checkmark on selected item (Ref 38 & 39)
                          if (isSelected)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, right: 8.w),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                                size: 24.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
