import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet presenting options for a selected Ayah.
///
/// Pixel-faithful replica of references 19 (half height ~48%) and 20 (expanded ~88%).
/// Features:
/// - Smooth draggable expansion between half height and full height via [DraggableScrollableSheet].
/// - Header: Surah name + Eastern Arabic-Indic Ayah number (e.g. "البقرة : ٦"),
///   star toggle icon, and share icon.
/// - 4 white rounded section cards matching references 19 & 20:
///   1. Bookmarks: "الفاصل الأحمر" (red ribbon) & "فاصل آخر..." (green ribbon)
///   2. Recitation: "تلاوة" (play icon) & "تشغيل إلى..." (play-to icon)
///   3. Library: "المكتبة" with subtitle "التفسير ومعاني الكلمات" (book icon)
///   4. Notes: "المالملاحظات" (edit pencil icon)
/// - Pure UI shell with interaction contracts only; business logic is deferred
///   to feature-specific tasks per AGENTS.md rules.
class AyahOptionsSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final bool isStarred;
  final VoidCallback? onStarTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onAnotherBookmarkTap;
  final VoidCallback? onReciteTap;
  final VoidCallback? onPlayToTap;
  final VoidCallback? onLibraryTap;
  final VoidCallback? onNotesTap;
  final QuranMetadataService metadataService;

  const AyahOptionsSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    this.isStarred = false,
    this.onStarTap,
    this.onShareTap,
    this.onBookmarkTap,
    this.onAnotherBookmarkTap,
    this.onReciteTap,
    this.onPlayToTap,
    this.onLibraryTap,
    this.onNotesTap,
    this.metadataService = const QuranMetadataService(),
  });

  /// Displays the Ayah Options sheet in a draggable modal bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    bool isStarred = false,
    VoidCallback? onStarTap,
    VoidCallback? onShareTap,
    VoidCallback? onBookmarkTap,
    VoidCallback? onAnotherBookmarkTap,
    VoidCallback? onReciteTap,
    VoidCallback? onPlayToTap,
    VoidCallback? onLibraryTap,
    VoidCallback? onNotesTap,
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) => AyahOptionsSheet(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        isStarred: isStarred,
        onStarTap: onStarTap,
        onShareTap: onShareTap,
        onBookmarkTap: onBookmarkTap,
        onAnotherBookmarkTap: onAnotherBookmarkTap,
        onReciteTap: onReciteTap,
        onPlayToTap: onPlayToTap,
        onLibraryTap: onLibraryTap,
        onNotesTap: onNotesTap,
        metadataService: metadataService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String surahName = metadataService.getSurahNameArabic(surahNumber);
    final String ayahNumeral = toArabicDigits(verseNumber);
    bool localIsStarred = isStarred;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.48,
        minChildSize: 0.35,
        maxChildSize: 0.88,
        snap: true,
        snapSizes: const [0.48, 0.88],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
                    width: AppSizes.dragHandleWidth,
                    height: AppSizes.dragHandleHeight,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                // 2. Top Header Row (Ref 19 & 20: Title on right, Star & Share on left)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Right: Surah Name : Ayah Number (e.g. "البقرة : ٦")
                      Text(
                        '$surahName : $ayahNumeral',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      // Left: Star and Share actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.share_outlined,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                            tooltip: AppStrings.tr(AppStrings.share),
                            onPressed: onShareTap,
                          ),
                          StatefulBuilder(
                            builder: (context, setIconState) {
                              return IconButton(
                                icon: Icon(
                                  localIsStarred
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: localIsStarred
                                      ? AppColors.bookmarkYellow
                                      : AppColors.primary,
                                  size: 26.sp,
                                ),
                                tooltip: AppStrings.tr(AppStrings.starAyah),
                                onPressed: () {
                                  setIconState(() {
                                    localIsStarred = !localIsStarred;
                                  });
                                  onStarTap?.call();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Scrollable Cards Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    children: [
                      // Card 1: Bookmarks
                      _buildOptionsCard(
                        children: [
                          _buildActionRow(
                            title: AppStrings.tr(AppStrings.redBookmark),
                            icon: Icons.bookmark_border_rounded,
                            iconColor: AppColors.bookmarkPink,
                            onTap: onBookmarkTap,
                          ),
                          _buildDivider(),
                          _buildActionRow(
                            title: AppStrings.tr(AppStrings.anotherBookmark),
                            icon: Icons.bookmark_border_rounded,
                            iconColor: AppColors.primary,
                            onTap: onAnotherBookmarkTap,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Card 2: Recitation
                      _buildOptionsCard(
                        children: [
                          _buildActionRow(
                            title: AppStrings.tr(AppStrings.recitation),
                            icon: Icons.play_arrow_rounded,
                            iconColor: AppColors.primary,
                            onTap: onReciteTap,
                          ),
                          _buildDivider(),
                          _buildActionRow(
                            title: AppStrings.tr(AppStrings.playTo),
                            icon: Icons.skip_next_rounded,
                            iconColor: AppColors.primary,
                            onTap: onPlayToTap,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Card 3: Library / Tafsir
                      _buildOptionsCard(
                        children: [
                          _buildActionRow(
                            title: AppStrings.tr(AppStrings.library),
                            subtitle: AppStrings.tr(AppStrings.librarySubtitle),
                            icon: Icons.menu_book_rounded,
                            iconColor: AppColors.primary,
                            onTap: onLibraryTap,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Card 4: Notes
                      _buildOptionsCard(
                        children: [
                          _buildActionRow(
                            title: AppStrings.tr(AppStrings.notesTitle),
                            icon: Icons.edit_outlined,
                            iconColor: AppColors.primary,
                            onTap: onNotesTap,
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right: Title & optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Left: Icon
            Icon(
              icon,
              color: iconColor,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}
