import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Top search bar widget matching screenshots 15 and 21.
class SearchTopBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const SearchTopBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onSubmitted,
    required this.onClear,
    required this.onBack,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.readerSurface,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56.h,
          child: Row(
            children: [
              // Back arrow on the right in RTL (pointing right to go back)
              IconButton(
                key: const Key('search_back_button'),
                icon: Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                tooltip: AppStrings.tr(AppStrings.close),
                onPressed: onBack,
              ),
              Expanded(
                child: TextField(
                  key: const Key('search_input_field'),
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  textInputAction: TextInputAction.search,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.tr(AppStrings.searchHint),
                    hintStyle: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 16.sp,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              // Clear button appears when text is not empty
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    key: const Key('search_clear_button'),
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    tooltip: AppStrings.tr(AppStrings.reset),
                    onPressed: onClear,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
