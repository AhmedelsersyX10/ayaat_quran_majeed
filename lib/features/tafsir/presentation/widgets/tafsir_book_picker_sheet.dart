import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/tafsir_book.dart';
import '../cubit/tafsir_cubit.dart';
import '../cubit/tafsir_state.dart';

/// Modal bottom sheet allowing the user to select the active Tafsir or Translation book.
class TafsirBookPickerSheet extends StatelessWidget {
  const TafsirBookPickerSheet({super.key});

  /// Displays the book picker sheet.
  static Future<void> show(BuildContext context) {
    final cubit = context.read<TafsirCubit>();
    cubit.loadAvailableBooks();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: const TafsirBookPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TafsirCubit, TafsirState>(
      builder: (context, state) {
        final books = state.availableBooks.isNotEmpty
            ? state.availableBooks
            : (state.selectedBook != null ? [state.selectedBook!] : <TafsirBook>[]);

        return AppBottomSheetShell(
          title: 'كتب التفسير والترجمة',
          child: books.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.border.withOpacity(0.4),
                  ),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final isSelected = book.id == state.selectedBook?.id;

                    return InkWell(
                      onTap: () {
                        context.read<TafsirCubit>().selectBook(book.id);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            // Selection radio / checkmark
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 22.sp,
                            ),
                            SizedBox(width: AppSpacing.md),

                            // Book title and metadata
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          book.name,
                                          style: AppTypography.titleMedium.copyWith(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.mushafBadgeFill,
                                          borderRadius: BorderRadius.circular(AppRadii.pill),
                                        ),
                                        child: Text(
                                          book.languageName,
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.mushafBadgeText,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (book.author.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      book.author,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
