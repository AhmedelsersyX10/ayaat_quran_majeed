import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Custom theme extension providing all reference-derived semantic colors.
/// Allows widgets to access colors via `context.appColors` or
/// `Theme.of(context).extension<AppColorsExtension>()!`.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryMuted;
  final Color primaryContainer;
  final Color scaffoldBackground;
  final Color surface;
  final Color bottomNavBackground;
  final Color readerSurface;
  final Color mushafPaper;
  final Color ayahHeaderSurface;
  final Color scrim;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnPrimary;
  final Color textTafsir;
  final Color divider;
  final Color border;
  final Color bookmarkYellow;
  final Color bookmarkGreen;
  final Color bookmarkBlue;
  final Color bookmarkPink;
  final Color playbackHighlight;
  final Color noteHighlight;
  final Color error;
  final Color destructive;
  final Color success;

  const AppColorsExtension({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryMuted,
    required this.primaryContainer,
    required this.scaffoldBackground,
    required this.surface,
    required this.bottomNavBackground,
    required this.readerSurface,
    required this.mushafPaper,
    required this.ayahHeaderSurface,
    required this.scrim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnPrimary,
    required this.textTafsir,
    required this.divider,
    required this.border,
    required this.bookmarkYellow,
    required this.bookmarkGreen,
    required this.bookmarkBlue,
    required this.bookmarkPink,
    required this.playbackHighlight,
    required this.noteHighlight,
    required this.error,
    required this.destructive,
    required this.success,
  });

  /// Standard light theme instance matching the 39 reference screenshots.
  factory AppColorsExtension.light() {
    return const AppColorsExtension(
      primary: AppColors.primary,
      primaryDark: AppColors.primaryDark,
      primaryLight: AppColors.primaryLight,
      primaryMuted: AppColors.primaryMuted,
      primaryContainer: AppColors.primaryContainer,
      scaffoldBackground: AppColors.scaffoldLight,
      surface: AppColors.surface,
      bottomNavBackground: AppColors.bottomNavBackground,
      readerSurface: AppColors.readerSurface,
      mushafPaper: AppColors.mushafPaperLight,
      ayahHeaderSurface: AppColors.ayahHeaderSurface,
      scrim: AppColors.scrim,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textMuted: AppColors.textMuted,
      textOnPrimary: AppColors.textOnPrimary,
      textTafsir: AppColors.textTafsir,
      divider: AppColors.divider,
      border: AppColors.border,
      bookmarkYellow: AppColors.bookmarkYellow,
      bookmarkGreen: AppColors.bookmarkGreen,
      bookmarkBlue: AppColors.bookmarkBlue,
      bookmarkPink: AppColors.bookmarkPink,
      playbackHighlight: AppColors.playbackHighlight,
      noteHighlight: AppColors.noteHighlight,
      error: AppColors.error,
      destructive: AppColors.destructive,
      success: AppColors.success,
    );
  }

  /// Dark theme instance with inverted contrast for dark mode.
  factory AppColorsExtension.dark() {
    return const AppColorsExtension(
      primary: AppColors.primaryLight,
      primaryDark: AppColors.primary,
      primaryLight: AppColors.primaryMuted,
      primaryMuted: AppColors.primaryDark,
      primaryContainer: Color(0xFF1E3529),
      scaffoldBackground: AppColors.scaffoldDark,
      surface: AppColors.surfaceDark,
      bottomNavBackground: AppColors.deepNavyBlack,
      readerSurface: AppColors.surfaceDark,
      mushafPaper: AppColors.mushafPaperDark,
      ayahHeaderSurface: Color(0xFF2E2C2A),
      scrim: Color(0x99000000),
      textPrimary: Color(0xFFEDEAE1),
      textSecondary: Color(0xFFA5A39E),
      textMuted: Color(0xFF757470),
      textOnPrimary: Color(0xFFFFFFFF),
      textTafsir: Color(0xFFD4C2B0),
      divider: Color(0xFF383838),
      border: Color(0xFF444444),
      bookmarkYellow: AppColors.bookmarkYellow,
      bookmarkGreen: AppColors.bookmarkGreen,
      bookmarkBlue: AppColors.bookmarkBlue,
      bookmarkPink: AppColors.bookmarkPink,
      playbackHighlight: Color(0x44007330),
      noteHighlight: Color(0x441E3529),
      error: AppColors.error,
      destructive: AppColors.destructive,
      success: AppColors.success,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? primaryMuted,
    Color? primaryContainer,
    Color? scaffoldBackground,
    Color? surface,
    Color? bottomNavBackground,
    Color? readerSurface,
    Color? mushafPaper,
    Color? ayahHeaderSurface,
    Color? scrim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnPrimary,
    Color? textTafsir,
    Color? divider,
    Color? border,
    Color? bookmarkYellow,
    Color? bookmarkGreen,
    Color? bookmarkBlue,
    Color? bookmarkPink,
    Color? playbackHighlight,
    Color? noteHighlight,
    Color? error,
    Color? destructive,
    Color? success,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      bottomNavBackground: bottomNavBackground ?? this.bottomNavBackground,
      readerSurface: readerSurface ?? this.readerSurface,
      mushafPaper: mushafPaper ?? this.mushafPaper,
      ayahHeaderSurface: ayahHeaderSurface ?? this.ayahHeaderSurface,
      scrim: scrim ?? this.scrim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textTafsir: textTafsir ?? this.textTafsir,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      bookmarkYellow: bookmarkYellow ?? this.bookmarkYellow,
      bookmarkGreen: bookmarkGreen ?? this.bookmarkGreen,
      bookmarkBlue: bookmarkBlue ?? this.bookmarkBlue,
      bookmarkPink: bookmarkPink ?? this.bookmarkPink,
      playbackHighlight: playbackHighlight ?? this.playbackHighlight,
      noteHighlight: noteHighlight ?? this.noteHighlight,
      error: error ?? this.error,
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      bottomNavBackground:
          Color.lerp(bottomNavBackground, other.bottomNavBackground, t)!,
      readerSurface: Color.lerp(readerSurface, other.readerSurface, t)!,
      mushafPaper: Color.lerp(mushafPaper, other.mushafPaper, t)!,
      ayahHeaderSurface:
          Color.lerp(ayahHeaderSurface, other.ayahHeaderSurface, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      textTafsir: Color.lerp(textTafsir, other.textTafsir, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      bookmarkYellow: Color.lerp(bookmarkYellow, other.bookmarkYellow, t)!,
      bookmarkGreen: Color.lerp(bookmarkGreen, other.bookmarkGreen, t)!,
      bookmarkBlue: Color.lerp(bookmarkBlue, other.bookmarkBlue, t)!,
      bookmarkPink: Color.lerp(bookmarkPink, other.bookmarkPink, t)!,
      playbackHighlight:
          Color.lerp(playbackHighlight, other.playbackHighlight, t)!,
      noteHighlight: Color.lerp(noteHighlight, other.noteHighlight, t)!,
      error: Color.lerp(error, other.error, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Convenience extensions on BuildContext to quickly access design tokens.
extension AppThemeContext on BuildContext {
  /// Custom semantic colors for the current theme.
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light();

  /// Shortcut alias for `appColors`.
  AppColorsExtension get colors => appColors;
}

