import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom Reader Toolbar with Page Slider and Tafsir button.
///
/// Pixel-faithful replica of reference 05:
/// - RTL Directionality: Page 1 on the right, Page 604 on the left.
/// - Soft beige rounded container track (`AppColors.mushafBadgeFill`).
/// - Distinctive green pill thumb (`AppColors.primary`).
/// - Real-time tooltip badge displaying the Arabic-Indic page number and Surah name.
/// - Tafsir icon button on the left.
class MushafPageSlider extends StatefulWidget {
  final int currentPage;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<int>? onDragStarted;
  final ValueChanged<int>? onScrubbing;
  final VoidCallback? onTafseerPressed;
  final QuranMetadataService metadataService;

  const MushafPageSlider({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
    this.onDragStarted,
    this.onScrubbing,
    this.onTafseerPressed,
    this.metadataService = const QuranMetadataService(),
  });

  @override
  State<MushafPageSlider> createState() => _MushafPageSliderState();
}

class _MushafPageSliderState extends State<MushafPageSlider> {
  bool _isDragging = false;
  late int _scrubbingPage;

  @override
  void initState() {
    super.initState();
    _scrubbingPage = widget.currentPage.clamp(1, 604);
  }

  @override
  void didUpdateWidget(MushafPageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.currentPage != oldWidget.currentPage) {
      _scrubbingPage = widget.currentPage.clamp(1, 604);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int activePage = _isDragging ? _scrubbingPage : widget.currentPage.clamp(1, 604);
    final String surahName = widget.metadataService.getSurahNameArabicForPage(activePage);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrubbing Tooltip Badge (appears during drag)
          if (_isDragging)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'الصفحة ${convertToArabicNumber(activePage.toString())} • $surahName',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Bottom Bar Row (Ref 05)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Slider Track Capsule (Spanning center/right in RTL)
                Expanded(
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.mushafBadgeFill,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    alignment: Alignment.center,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 0.0, // Hidden default track — container serves as track
                        thumbColor: AppColors.primary,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        overlayColor: AppColors.primary.withOpacity(0.12),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        thumbShape: _PillSliderThumbShape(
                          thumbWidth: 28.w,
                          thumbHeight: 18.h,
                          borderRadius: 9.r,
                        ),
                      ),
                      child: Slider(
                        value: activePage.toDouble().clamp(1.0, 604.0),
                        min: 1.0,
                        max: 604.0,
                        divisions: 603,
                        onChangeStart: (val) {
                          setState(() {
                            _isDragging = true;
                            _scrubbingPage = val.round().clamp(1, 604);
                          });
                          widget.onDragStarted?.call(_scrubbingPage);
                        },
                        onChanged: (val) {
                          final page = val.round().clamp(1, 604);
                          setState(() {
                            _scrubbingPage = page;
                          });
                          widget.onScrubbing?.call(page);
                        },
                        onChangeEnd: (val) {
                          final page = val.round().clamp(1, 604);
                          setState(() {
                            _isDragging = false;
                            _scrubbingPage = page;
                          });
                          widget.onPageSelected(page);
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Tafsir Button on Left (Ref 05)
                InkWell(
                  onTap: widget.onTafseerPressed,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 42.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.mushafBadgeFill,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.article_outlined,
                      size: 22.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Pill/Capsule Thumb Shape matching reference 05.
class _PillSliderThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;
  final double borderRadius;

  const _PillSliderThumbShape({
    this.thumbWidth = 26.0,
    this.thumbHeight = 16.0,
    this.borderRadius = 8.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final rect = Rect.fromCenter(
      center: center,
      width: thumbWidth,
      height: thumbHeight,
    );
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      paint,
    );
  }
}

