import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/share_cubit.dart';
import '../cubit/share_state.dart';
import '../views/share_card_preview_page.dart';

/// Modal dialog for configuring Ayah range and choosing between Text and Image Card sharing.
class ShareAyahDialog extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final int? pageNumber;
  final String? noteText;

  // Legacy compatibility parameters
  final int? index;
  final dynamic jsonData;
  final dynamic translationDataList;

  const ShareAyahDialog({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    this.pageNumber,
    this.noteText,
    this.index,
    this.jsonData,
    this.translationDataList,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShareCubit>(
      create: (_) {
        final cubit = sl<ShareCubit>();
        cubit.init(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: pageNumber ?? index,
          noteText: noteText,
        );
        return cubit;
      },
      child: const _ShareAyahDialogContent(),
    );
  }
}

class _ShareAyahDialogContent extends StatelessWidget {
  const _ShareAyahDialogContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShareCubit, ShareState>(
      listener: (context, state) {
        if (state.status == ShareActionStatus.shareSuccess) {
          Navigator.of(context).pop();
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
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ShareCubit>();
        final totalVerses = state.totalVersesInSurah;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            clipBehavior: Clip.antiAlias,
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.35),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${AppStrings.tr(AppStrings.shareAyah)} - سورة ${state.params.surahName}',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 2. Range Pickers
                        Row(
                          children: [
                            // From Ayah
                            Expanded(
                              child: _buildAyahDropdown(
                                context: context,
                                label: AppStrings.tr(AppStrings.fromAyah),
                                value: state.params.fromAyah,
                                totalVerses: totalVerses,
                                onChanged: (newFrom) {
                                  if (newFrom != null) {
                                    cubit.updateRange(
                                      newFrom,
                                      state.params.toAyah < newFrom
                                          ? newFrom
                                          : state.params.toAyah,
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // To Ayah
                            Expanded(
                              child: _buildAyahDropdown(
                                context: context,
                                label: AppStrings.tr(AppStrings.toAyah),
                                value: state.params.toAyah,
                                totalVerses: totalVerses,
                                minVerse: state.params.fromAyah,
                                onChanged: (newTo) {
                                  if (newTo != null) {
                                    cubit.updateRange(
                                      state.params.fromAyah,
                                      newTo,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // 3. Option Toggles
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: Text(
                            AppStrings.tr(AppStrings.withoutDiacritics),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: state.params.withoutTashkeel,
                          onChanged: (val) =>
                              cubit.toggleWithoutTashkeel(val ?? false),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: Text(
                            AppStrings.tr(AppStrings.includeTafsir),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: state.params.includeTafsir,
                          onChanged: (val) => cubit.toggleTafsir(val ?? false),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: Text(
                            AppStrings.tr(AppStrings.includeAppBranding),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: state.params.includeAppBranding,
                          onChanged: (val) =>
                              cubit.toggleBranding(val ?? false),
                        ),
                        SizedBox(height: 18.h),

                        // 4. Action Buttons (Text vs Image)
                        Row(
                          children: [
                            // Share as Text
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state.isLoading
                                    ? null
                                    : () => cubit.shareAsText(),
                                icon:
                                    state.status ==
                                        ShareActionStatus.sharingText
                                    ? SizedBox(
                                        width: 16.sp,
                                        height: 16.sp,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.text_fields_rounded,
                                        size: 18.sp,
                                      ),
                                label: Text(
                                  AppStrings.tr(AppStrings.shareAsText),
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
                            SizedBox(width: 10.w),

                            // Share as Image (Preview)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        final currentCubit = context
                                            .read<ShareCubit>();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: currentCubit,
                                              child:
                                                  const ShareCardPreviewPage(),
                                            ),
                                          ),
                                        );
                                      },
                                icon: Icon(Icons.image_rounded, size: 18.sp),
                                label: Text(
                                  AppStrings.tr(AppStrings.shareAsImage),
                                  style: AppTypography.labelLarge.copyWith(
                                    fontSize: 13.sp,
                                  ),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAyahDropdown({
    required BuildContext context,
    required String label,
    required int value,
    required int totalVerses,
    int minVerse = 1,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColors.scaffoldLight,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value.clamp(minVerse, totalVerses),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: List.generate(totalVerses - minVerse + 1, (index) {
                final ayahNum = minVerse + index;
                return DropdownMenuItem<int>(
                  value: ayahNum,
                  child: Text(
                    'الآية ${toArabicDigits(ayahNum)}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
