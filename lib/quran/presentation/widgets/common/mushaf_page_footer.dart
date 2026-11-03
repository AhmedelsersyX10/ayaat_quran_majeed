import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Renders the Mushaf page bottom footer badge:
/// - When a Hizb quarter starts on this page:
///     pill badge showing "[page] | [hizb quarter]" (e.g. "١ | الحزب ١")
/// - On regular pages:
///     pill badge showing "[page]" (e.g. "٣")
///
/// Styled to match reference screenshots 01 and 02 with decorative ornamental capsule.
class MushafPageFooter extends StatelessWidget {
  final int pageNumber;
  final QuranMetadataService metadataService;

  const MushafPageFooter({
    super.key,
    required this.pageNumber,
    this.metadataService = const QuranMetadataService(),
  });

  @override
  Widget build(BuildContext context) {
    if (pageNumber < 1 || pageNumber > 604) {
      return const SizedBox.shrink();
    }

    final String hizbText = metadataService.getHizbTextByPage(pageNumber);
    final String pageArabic = toArabicDigits(pageNumber);

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: CustomPaint(
          painter: const MushafBadgePainter(
            borderColor: AppColors.mushafOrnament,
            fillColor: AppColors.mushafBadgeFill,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: hizbText.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          pageArabic,
                          style: AppTypography.mushafPageFooter,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          width: 1.w,
                          height: 12.h,
                          color: AppColors.mushafOrnament.withOpacity(0.55),
                        ),
                        Text(
                          hizbText,
                          style: AppTypography.mushafPageFooter,
                        ),
                      ],
                    )
                  : Text(
                      pageArabic,
                      style: AppTypography.mushafPageFooter,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the decorative Mushaf page number / hizb capsule.
/// Draws an outer capsule with ornamental curls at both ends and an inner subtle stroke.
class MushafBadgePainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  const MushafBadgePainter({
    required this.borderColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (w <= 0 || h <= 0) return;

    const double earWidth = 6.0;
    final double radius = h / 2;

    // 1. Background fill
    final Rect mainRect = Rect.fromLTWH(earWidth * 0.5, 0, w - earWidth, h);
    final RRect mainRRect = RRect.fromRectAndRadius(mainRect, Radius.circular(radius));

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(mainRRect, fillPaint);

    // 2. Outer border
    final Paint borderPaint = Paint()
      ..color = borderColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(mainRRect, borderPaint);

    // 3. Inner fine stroke
    if (w > earWidth * 2 + 6 && h > 6) {
      final Rect innerRect = Rect.fromLTWH(
        earWidth * 0.5 + 2.0,
        2.0,
        w - earWidth - 4.0,
        h - 4.0,
      );
      final RRect innerRRect = RRect.fromRectAndRadius(
        innerRect,
        Radius.circular((h - 4.0) / 2),
      );
      final Paint innerBorderPaint = Paint()
        ..color = borderColor.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRRect(innerRRect, innerBorderPaint);
    }

    // 4. Ornamental decorative scroll ears on left and right
    _drawOrnamentalEar(canvas, 0, h, earWidth, true, borderPaint);
    _drawOrnamentalEar(canvas, w, h, earWidth, false, borderPaint);
  }

  void _drawOrnamentalEar(
    Canvas canvas,
    double x,
    double h,
    double earWidth,
    bool isLeft,
    Paint paint,
  ) {
    final double dir = isLeft ? 1 : -1;
    final double anchorX = x + (isLeft ? earWidth * 0.5 : -earWidth * 0.5);
    final double centerY = h / 2;

    final Path path = Path();
    // Outer scroll curve
    path.moveTo(anchorX, h * 0.2);
    path.quadraticBezierTo(
      anchorX - dir * earWidth,
      centerY,
      anchorX,
      h * 0.8,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MushafBadgePainter oldDelegate) {
    return oldDelegate.borderColor != borderColor || oldDelegate.fillColor != fillColor;
  }
}
