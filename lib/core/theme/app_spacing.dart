import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

double _w(double size) {
  try {
    return size.w;
  } catch (_) {
    return size;
  }
}

double _h(double size) {
  try {
    return size.h;
  } catch (_) {
    return size;
  }
}

double _r(double size) {
  try {
    return size.r;
  } catch (_) {
    return size;
  }
}

/// Spacing design tokens based on a 4dp / 8dp grid, scaled defensively with flutter_screenutil.
abstract class AppSpacing {
  /// 2dp
  static double get xxs => _w(2);

  /// 4dp
  static double get xs => _w(4);

  /// 8dp
  static double get sm => _w(8);

  /// 12dp
  static double get md => _w(12);

  /// 16dp - Standard screen padding & margin
  static double get lg => _w(16);

  /// 20dp
  static double get xl => _w(20);

  /// 24dp
  static double get xxl => _w(24);

  /// 32dp
  static double get xxxl => _w(32);
}

/// Corner radii tokens scaled defensively with flutter_screenutil.
abstract class AppRadii {
  /// 4dp
  static double get xs => _r(4);

  /// 8dp - Small chips, sub-cards
  static double get sm => _r(8);

  /// 12dp - Standard buttons, medium cards, text fields
  static double get md => _r(12);

  /// 16dp - Dialogs, large cards, prominent containers
  static double get lg => _r(16);

  /// 20dp - Bottom sheet top corners
  static double get xl => _r(20);

  /// Fully rounded pill / capsule radius
  static double get pill => _r(999);

  // Pre-built BorderRadius objects for convenience
  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusPill => BorderRadius.circular(pill);

  /// Top corners only for bottom sheet shells
  static BorderRadius get bottomSheetTop => BorderRadius.only(
        topLeft: Radius.circular(xl),
        topRight: Radius.circular(xl),
      );
}

/// Sizing and touch targets tokens
abstract class AppSizes {
  /// Minimum touch target size for accessibility (44dp)
  static double get minTouchTarget => _r(44);

  /// Standard full-width primary CTA button height (48dp)
  static double get buttonHeightLg => _h(48);

  /// Compact inside-card button height (38dp)
  static double get buttonHeightSm => _h(38);

  /// Bottom navigation bar height (56dp)
  static double get bottomNavHeight => _h(56);

  /// Bottom sheet drag handle width (44dp) and height (4dp)
  static double get dragHandleWidth => _w(44);
  static double get dragHandleHeight => _h(4);

  /// Stepper circular button diameter (34dp)
  static double get stepperButtonSize => _r(34);

  /// Checkmark circular badge diameter (20dp)
  static double get checkmarkSize => _r(20);

  /// Switch dimensions (48dp width, 28dp height)
  static double get switchWidth => _w(48);
  static double get switchHeight => _h(28);

  // Icon Sizes
  static double get iconXs => _r(16);
  static double get iconSm => _r(20);
  static double get iconMd => _r(24);
  static double get iconLg => _r(28);
  static double get iconXl => _r(32);

  /// Fraction of screen height occupied by near-full-height sheets (reference 16)
  static const double nearFullSheetHeightFactor = 0.95;

  /// Measured date card horizontal layout tokens (reference 16)
  static double get dateCardsOuterPadding => _w(56);
  static double get dateCardsCenterGap => _w(48);
}

/// Animation durations and curves matching the reference app motion
abstract class AppDurations {
  /// Fast tap / button splash / checkbox toggle (150ms)
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard tab slide / expansion transition (250ms)
  static const Duration standard = Duration(milliseconds: 250);

  /// Bottom sheet slide-up / page route transition (300ms)
  static const Duration sheet = Duration(milliseconds: 300);

  /// Standard deceleration curve
  static const Curve defaultCurve = Curves.easeOutCubic;
}
