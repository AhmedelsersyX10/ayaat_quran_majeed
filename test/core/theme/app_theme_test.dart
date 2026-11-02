import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Design System Theme & Tokens Tests', () {
    test('AppColors tokens match reference measurements', () {
      expect(AppColors.primary, equals(const Color(0xFF007330)));
      expect(AppColors.scaffoldLight, equals(const Color(0xFFF4EFE9)));
      expect(AppColors.surface, equals(const Color(0xFFFFFCF7)));
      expect(AppColors.bottomNavBackground, equals(const Color(0xFFFEFAF1)));
      expect(AppColors.textPrimary, equals(const Color(0xFF201C19)));
      expect(AppColors.textSecondary, equals(const Color(0xFF656460)));
      expect(AppColors.bookmarkYellow, equals(const Color(0xFFD7AC3C)));
      expect(AppColors.bookmarkGreen, equals(const Color(0xFF62A77B)));
      expect(AppColors.bookmarkBlue, equals(const Color(0xFF218FC9)));
      expect(AppColors.bookmarkPink, equals(const Color(0xFFC9484A)));
    });

    test('lightTheme registers AppColorsExtension correctly', () {
      final theme = AppTheme.lightTheme;
      final extension = theme.extension<AppColorsExtension>();

      expect(extension, isNotNull);
      expect(extension!.primary, equals(AppColors.primary));
      expect(extension.scaffoldBackground, equals(AppColors.scaffoldLight));
      expect(extension.surface, equals(AppColors.surface));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.scaffoldLight));
      expect(theme.primaryColor, equals(AppColors.primary));
    });

    test('darkTheme registers dark AppColorsExtension correctly', () {
      final theme = AppTheme.darkTheme;
      final extension = theme.extension<AppColorsExtension>();

      expect(extension, isNotNull);
      expect(extension!.scaffoldBackground, equals(AppColors.scaffoldDark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.scaffoldDark));
    });
  });
}

