import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

double _sp(double size) {
  try {
    return size.sp;
  } catch (_) {
    return size;
  }
}

/// Semantic typography tokens for the Arabic RTL Ayaat app.
/// Uses the Cairo font family with defensive flutter_screenutil `.sp` scaling.
abstract class AppTypography {
  static const String arabicFontFamily = 'cairo';
  static const String uthmanicFontFamily =
      'KFGQPC Uthmanic Script HAFS Regular';
  static const String amiriFontFamily = 'AmiriQuran';
  static const String surahNamesFontFamily = 'surah_names';

  /// Page titles (e.g. "الختمة", "الفواصل", "الملاحظات") - 24sp, Bold
  static TextStyle get displayLarge => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(24),
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  /// Card headers & Dialog titles - 18sp, Bold
  static TextStyle get titleLarge => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(18),
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  /// Surah names & List row main titles - 16sp, SemiBold/Bold
  static TextStyle get titleMedium => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(16),
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  /// Section headers (e.g. "الجزء الأول", "خيارات مقترحة") - 14sp, SemiBold
  static TextStyle get titleSmall => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(14),
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textSecondary,
      );

  /// Body large (Note text, quoted ayah previews) - 15sp, Regular
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(15),
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Body medium (Subtitles, metadata: "مكية - ٧ آيات") - 13sp, Regular
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(13),
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  /// Body small (Bottom nav labels, small timestamps, hints) - 11sp, Regular
  static TextStyle get bodySmall => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(11),
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.textMuted,
      );

  /// Primary button label - 15sp, Bold
  static TextStyle get labelLarge => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(15),
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textOnPrimary,
      );

  /// Segmented tab labels - 13sp, SemiBold
  static TextStyle get labelMedium => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(13),
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  /// Counter numbers & badge labels - 11sp, Medium
  static TextStyle get labelSmall => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(11),
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.textSecondary,
      );

  /// Tafsir body explanation style - 14sp, Regular, warm brown
  static TextStyle get tafsirBody => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(14),
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.textTafsir,
      );

  /// Quran verse Uthmanic style - 18sp, Regular
  static TextStyle get quranText => TextStyle(
        fontFamily: uthmanicFontFamily,
        fontSize: _sp(18),
        fontWeight: FontWeight.w400,
        height: 1.8,
        color: AppColors.textPrimary,
      );

  /// Surah name calligraphy glyph style - 22sp
  static TextStyle get surahNameGlyph => TextStyle(
        fontFamily: surahNamesFontFamily,
        fontSize: _sp(22),
        height: 1.2,
        color: AppColors.textPrimary,
      );

  /// Mushaf page header style ("الجزء الأول", "الفاتحة") - 13sp, Medium
  static TextStyle get mushafPageHeader => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(13),
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.mushafOrnament,
      );

  /// Mushaf page footer badge text style - 11sp, SemiBold
  static TextStyle get mushafPageFooter => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: _sp(11),
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.mushafBadgeText,
      );
}
