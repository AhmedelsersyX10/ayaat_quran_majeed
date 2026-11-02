import 'dart:math';

import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum HizbQuarterType {
  firstQuarter,
  half,
  threeQuarters,
  full,
}

/// Unified indicator for quarters of a Hizb matching screens 04 and 36.
class HizbQuarterIndicator extends StatelessWidget {
  final HizbQuarterType type;
  final double size;
  final Color? activeColor;
  final Color? trackColor;

  const HizbQuarterIndicator({
    super.key,
    required this.type,
    this.size = 20.0,
    this.activeColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveTrackColor = trackColor ?? AppColors.border;

    return CustomPaint(
      size: Size(size, size),
      painter: _HizbQuarterPainter(
        type: type,
        activeColor: effectiveActiveColor,
        trackColor: effectiveTrackColor,
      ),
    );
  }
}

class _HizbQuarterPainter extends CustomPainter {
  final HizbQuarterType type;
  final Color activeColor;
  final Color trackColor;

  _HizbQuarterPainter({
    required this.type,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw background track circle
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(rect.center, size.width / 2, trackPaint);

    // Draw active arc based on quarter type
    final Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    const double startAngle = -pi / 2; // Start from top
    double sweepAngle;

    switch (type) {
      case HizbQuarterType.firstQuarter:
        sweepAngle = pi / 2; // 90 degrees
        break;
      case HizbQuarterType.half:
        sweepAngle = pi; // 180 degrees
        break;
      case HizbQuarterType.threeQuarters:
        sweepAngle = 3 * pi / 2; // 270 degrees
        break;
      case HizbQuarterType.full:
        sweepAngle = 2 * pi; // 360 degrees
        break;
    }

    canvas.drawArc(rect, startAngle, sweepAngle, true, activePaint);
  }

  @override
  bool shouldRepaint(_HizbQuarterPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

// --- Backward-Compatible Legacy Widgets ---

class QuarterCircle extends StatelessWidget {
  final Color color;
  final double size;

  const QuarterCircle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: QuarterCirclePainter(color),
    );
  }
}

class HalfCircle extends StatelessWidget {
  final Color color;
  final double size;

  const HalfCircle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HalfCirclePainter(color),
    );
  }
}

class ThreeQuartersCircle extends StatelessWidget {
  final Color color;
  final double size;

  const ThreeQuartersCircle(
      {super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ThreeQuartersCirclePainter(color),
    );
  }
}

class QuarterCirclePainter extends CustomPainter {
  final Color color;

  QuarterCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Rect rect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
    const double startAngle = -pi / 2;
    const double sweepAngle = pi / 2;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HalfCirclePainter extends CustomPainter {
  final Color color;

  HalfCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Rect rect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
    const double startAngle = -pi / 2;
    const double sweepAngle = pi;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ThreeQuartersCirclePainter extends CustomPainter {
  final Color color;

  ThreeQuartersCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Rect rect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
    const double startAngle = -pi / 2;
    const double sweepAngle = 3 * pi / 2;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
