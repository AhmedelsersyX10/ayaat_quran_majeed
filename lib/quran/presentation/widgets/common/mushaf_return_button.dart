import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Floating Return Arrow Button with Page Number.
///
/// Appears after the user drags the page slider away from their initial page.
/// Displays a return/undo arrow and the Arabic-Indic numeral of the origin page.
/// When tapped, jumps back to that page and dismisses.
/// Binding requirement: AGENTS.md Section 14.
class MushafReturnButton extends StatelessWidget {
  final int? returnPage;
  final VoidCallback onReturn;
  final VoidCallback? onDismiss;

  const MushafReturnButton({
    super.key,
    required this.returnPage,
    required this.onReturn,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = returnPage != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: isVisible
          ? Directionality(
              textDirection: TextDirection.rtl,
              key: ValueKey<int>(returnPage!),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onReturn,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24.r),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.undo_rounded,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          convertToArabicNumber(returnPage.toString()),
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty_return')),
    );
  }
}

