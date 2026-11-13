import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import '../theme/share_card_theme.dart';
import '../cubit/share_cubit.dart';
import '../cubit/share_state.dart';
import '../widgets/share_ayah_card.dart';

/// Full preview and customization screen for exporting Ayah image cards.
class ShareCardPreviewPage extends StatefulWidget {
  const ShareCardPreviewPage({super.key});

  @override
  State<ShareCardPreviewPage> createState() => _ShareCardPreviewPageState();
}

class _ShareCardPreviewPageState extends State<ShareCardPreviewPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShareCubit, ShareState>(
      listener: (context, state) {
        if (state.status == ShareActionStatus.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage ??
                    AppStrings.tr(AppStrings.imageSavedSuccess),
                style: const TextStyle(
                  fontFamily: AppTypography.arabicFontFamily,
                ),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ShareCubit>().resetStatus();
        } else if (state.status == ShareActionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: const TextStyle(
                  fontFamily: AppTypography.arabicFontFamily,
                ),
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ShareCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldLight,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldLight,
            elevation: 0,
            centerTitle: true,
            title: Text(
              AppStrings.tr(AppStrings.cardPreviewTitle),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textPrimary,
              ),
              tooltip: 'رجوع',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              // 1. Live Card Preview Area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Screenshot(
                      controller: _screenshotController,
                      child: ShareAyahCard(
                        params: state.params,
                        cardTheme: state.cardTheme,
                        fontSize: state.fontSize,
                        alignment: state.alignment,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Bottom Customization & Export Controls
              _buildControlPanel(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlPanel(BuildContext context, ShareState state) {
    final cubit = context.read<ShareCubit>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Themes Picker Row
            Row(
              children: [
                Text(
                  AppStrings.tr(AppStrings.cardTheme),
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ShareCardTheme.predefinedThemes.map((theme) {
                        final isSelected = theme.id == state.cardTheme.id;
                        return GestureDetector(
                          onTap: () => cubit.updateTheme(theme),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 14.r,
                              backgroundColor: theme.backgroundColor,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 14.sp,
                                        color: theme.accentColor,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Font Size & Alignment Row
            Row(
              children: [
                Text(
                  'حجم الخط: ${toArabicDigits(state.fontSize.round())}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primaryContainer,
                      thumbColor: AppColors.primary,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: state.fontSize,
                      min: 16.0,
                      max: 32.0,
                      divisions: 8,
                      onChanged: (val) => cubit.updateFontSize(val),
                    ),
                  ),
                ),
                // Alignment toggles
                _buildAlignmentButton(
                  icon: Icons.format_align_right_rounded,
                  alignment: TextAlign.right,
                  current: state.alignment,
                  onTap: () => cubit.updateAlignment(TextAlign.right),
                ),
                _buildAlignmentButton(
                  icon: Icons.format_align_center_rounded,
                  alignment: TextAlign.center,
                  current: state.alignment,
                  onTap: () => cubit.updateAlignment(TextAlign.center),
                ),
                _buildAlignmentButton(
                  icon: Icons.format_align_left_rounded,
                  alignment: TextAlign.left,
                  current: state.alignment,
                  onTap: () => cubit.updateAlignment(TextAlign.left),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Optional Toggles Row (Tafsir & Branding)
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: Text(
                      AppStrings.tr(AppStrings.includeTafsir),
                      style: TextStyle(
                        fontFamily: AppTypography.arabicFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: state.params.includeTafsir
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    selected: state.params.includeTafsir,
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.scaffoldLight,
                    checkmarkColor: AppColors.primaryDark,
                    onSelected: (val) => cubit.toggleTafsir(val),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FilterChip(
                    label: Text(
                      AppStrings.tr(AppStrings.includeAppBranding),
                      style: TextStyle(
                        fontFamily: AppTypography.arabicFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: state.params.includeAppBranding
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    selected: state.params.includeAppBranding,
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.scaffoldLight,
                    checkmarkColor: AppColors.primaryDark,
                    onSelected: (val) => cubit.toggleBranding(val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Action Buttons
            Row(
              children: [
                // Share image button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => cubit.shareAsImage(_screenshotController),
                    icon: state.status == ShareActionStatus.sharingImage
                        ? SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.share_rounded, size: 18.sp),
                    label: Text(
                      AppStrings.tr(AppStrings.shareImageAction),
                      style: AppTypography.labelLarge,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Save to gallery button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => cubit.saveToGallery(_screenshotController),
                    icon: state.status == ShareActionStatus.savingToGallery
                        ? SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(Icons.download_rounded, size: 18.sp),
                    label: Text(
                      AppStrings.tr(AppStrings.saveToGallery),
                      style: TextStyle(
                        fontFamily: AppTypography.arabicFontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignmentButton({
    required IconData icon,
    required TextAlign alignment,
    required TextAlign current,
    required VoidCallback onTap,
  }) {
    final isSelected = alignment == current;
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 18.sp,
        color: isSelected ? AppColors.primary : AppColors.textMuted,
      ),
      onPressed: onTap,
    );
  }
}
