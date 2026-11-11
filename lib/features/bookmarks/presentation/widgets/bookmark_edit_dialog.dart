import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_dialog_shell.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Standard dialog for customizing a bookmark's name and color ribbon.
class BookmarkEditDialog extends StatefulWidget {
  final BookmarkItem item;
  final void Function(String newName, String newColorHex) onSave;

  const BookmarkEditDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required BookmarkItem item,
    required void Function(String newName, String newColorHex) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => BookmarkEditDialog(item: item, onSave: onSave),
    );
  }

  @override
  State<BookmarkEditDialog> createState() => _BookmarkEditDialogState();
}

class _BookmarkEditDialogState extends State<BookmarkEditDialog> {
  late final TextEditingController _nameController;
  late String _selectedColorHex;

  static const List<String> _availableColors = [
    '#C9484A', // Red
    '#D7AC3C', // Yellow
    '#62A77B', // Green
    '#218FC9', // Blue
    '#8E44AD', // Purple
    '#16A085', // Teal
    '#E67E22', // Orange
    '#5D4037', // Brown
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _selectedColorHex = widget.item.colorHex.toUpperCase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '').padLeft(8, 'f');
    return Color(int.parse(clean, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppDialogShell(
      title: 'تعديل الفاصل',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.tr(AppStrings.cancel),
            style: AppTypography.titleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onPressed: () {
            final name = _nameController.text.trim();
            widget.onSave(
              name.isNotEmpty ? name : widget.item.name,
              _selectedColorHex,
            );
            Navigator.of(context).pop();
          },
          child: Text(
            AppStrings.tr(AppStrings.save),
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tr(AppStrings.bookmarkName),
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _nameController,
            textDirection: TextDirection.rtl,
            autofocus: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'اختر لون الفاصل',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _availableColors.map((hex) {
              final color = _parseHex(hex);
              final isSelected = hex.toUpperCase() == _selectedColorHex;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedColorHex = hex.toUpperCase();
                  });
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
