import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet for choosing an ayah within a surah.
///
/// Pixel-faithful replica of references 38 ("اختيار الآية") and 39
/// (scrolled to selected ayah with green checkmark).
/// Used for direct reader jump and for Recitation Settings range picker (ref 40).
class AyahPickerSheet extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;
  final ValueChanged<int>? onAyahSelected;
  final QuranMetadataService metadataService;

  const AyahPickerSheet({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
    this.onAyahSelected,
    this.metadataService = const QuranMetadataService(),
  });

  /// Displays the picker in a standard modal bottom sheet.
  /// Returns the chosen ayah number, or null if dismissed without selection.
  static Future<int?> show(
    BuildContext context, {
    required int surahNumber,
    int? initialAyahNumber,
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  late int _selectedAyah;
  late final ScrollController _scrollController;
  late final int _verseCount;
  late final String _surahName;

  @override
  void initState() {
    super.initState();
    _verseCount = widget.metadataService.getVerseCount(widget.surahNumber);
    _surahName = widget.metadataService.getSurahNameArabic(widget.surahNumber);
    _selectedAyah = widget.initialAyahNumber?.clamp(1, _verseCount) ?? 1;

    // Approximate row height ~80dp to scroll to selected item on open
    final double initialOffset = ((_selectedAyah - 1) * 80.0).clamp(0.0, 99999.0);
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
    if (widget.onAyahSelected != null) {
      widget.onAyahSelected!(ayahNumber);
    }
    Navigator.of(context).pop(ayahNumber);
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
            // Top App Bar / Title (Ref 38)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primaryDark,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppStrings.selectAyah,
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              color: AppColors.mushafBadgeFill.withOpacity(0.5),
              child: Text(
                _surahName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.mushafBadgeText,
                ),
              ),
            ),

            // Verses List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: _verseCount,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final int ayahNumber = index + 1;
                  final bool isSelected = ayahNumber == _selectedAyah;
                  final String verseText = widget.metadataService.getVerse(
                    widget.surahNumber,
                    ayahNumber,
                  );

                  return InkWell(
                    onTap: () => _handleSelect(ayahNumber),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ayah title & text preview
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_surahName : ${convertToArabicNumber(ayahNumber.toString())}',
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
