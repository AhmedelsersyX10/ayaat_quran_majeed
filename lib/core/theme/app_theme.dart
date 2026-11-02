import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Central theme configuration for the application.
abstract class AppTheme {
  static const String arabicFontFamily = AppTypography.arabicFontFamily;

  /// Standard Light Theme matching the 39 reference screenshots.
  static ThemeData get lightTheme {
    final colors = AppColorsExtension.light();

    return ThemeData(
      useMaterial3: false,
      fontFamily: arabicFontFamily,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.primaryLight,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.scaffoldBackground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bottomNavBackground,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.bodySmall.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusMd,
          side: BorderSide(color: colors.divider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 0.5,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.bottomSheetTop,
        ),
      ),
    );
  }

  /// Standard Dark Theme (prepared for dark mode).
  static ThemeData get darkTheme {
    final colors = AppColorsExtension.dark();

    return ThemeData.dark().copyWith(
      useMaterial3: false,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.primaryLight,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTypography.titleLarge.copyWith(color: colors.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bottomNavBackground,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
