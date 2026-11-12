import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import '../theme/share_card_theme.dart';
import '../../domain/entities/share_params.dart';

/// Pixel-faithful exportable Quran Ayah card widget.
/// Designed for high-resolution screenshot capturing and live previewing.
class ShareAyahCard extends StatelessWidget {
  final ShareParams params;
  final ShareCardTheme cardTheme;
  final double fontSize;
  final TextAlign alignment;
  final QuranMetadataService metadataService;

  const ShareAyahCard({
    super.key,
    required this.params,
    this.cardTheme = ShareCardTheme.defaultTheme,
    this.fontSize = 22.0,
    this.alignment = TextAlign.center,
    this.metadataService = const QuranMetadataService(),
  });

  bool get _shouldShowBasmalah =>
      params.fromAyah == 1 &&
      params.surahNumber != 1 &&
      params.surahNumber != 9;

  @override
  Widget build(BuildContext context) {
    final theme = cardTheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Surah Header Badge
              _buildSurahHeaderBadge(theme),
              const SizedBox(height: 16),

              // 2. Basmalah
              if (_shouldShowBasmalah) ...[
                _buildBasmalah(theme),
                const SizedBox(height: 16),
              ],

              // 3. User Note Quote (Ref 29)
              if (params.noteText != null &&
                  params.noteText!.trim().isNotEmpty) ...[
                _buildNoteSection(theme),
                const SizedBox(height: 16),
              ],

              // 4. Quran Verse Spans
              _buildQuranVerses(context, theme),

              // 5. Tafsir Section
              if (params.includeTafsir &&
                  params.tafsirText != null &&
                  params.tafsirText!.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                _buildTafsirSection(theme),
              ],

              const SizedBox(height: 20),
              Divider(
                color: theme.borderColor.withOpacity(0.8),
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 14),

              // 6. Footer: Ayah Range Badge & App Branding
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahHeaderBadge(ShareCardTheme theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: theme.headerSurfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 16, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(
              'سورة ${params.surahName}',
              style: TextStyle(
                fontFamily: AppTypography.arabicFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.badgeTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasmalah(ShareCardTheme theme) {
    return Center(
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTypography.uthmanicFontFamily,
          fontSize: (fontSize * 0.9).clamp(16.0, 26.0),
          color: theme.accentColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildNoteSection(ShareCardTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.accentColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note_rounded, size: 18, color: theme.accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              params.noteText!.trim(),
              style: TextStyle(
                fontFamily: AppTypography.arabicFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranVerses(BuildContext context, ShareCardTheme theme) {
    final spans = <InlineSpan>[];

    for (int i = params.fromAyah; i <= params.toAyah; i++) {
      var verseText = metadataService.getVerse(params.surahNumber, i);
      if (params.withoutTashkeel) {
        verseText = metadataService.removeDiacritics(verseText);
      }
      final ayahNumberArabic = toArabicDigits(i);

      spans.add(
        TextSpan(
          text: '$verseText ',
          style: TextStyle(
            fontFamily: AppTypography.uthmanicFontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: theme.textColor,
            height: 1.9,
          ),
        ),
      );

      // Verse end ornament symbol
      spans.add(
        TextSpan(
          text: '﴿$ayahNumberArabic﴾ ',
          style: TextStyle(
            fontFamily: AppTypography.arabicFontFamily,
            fontSize: fontSize * 0.75,
            fontWeight: FontWeight.w700,
            color: theme.accentColor,
            height: 1.9,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: alignment,
        text: TextSpan(children: spans),
      ),
    );
  }

  Widget _buildTafsirSection(ShareCardTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.accentColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 14,
                color: theme.accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                params.tafsirBookName ?? 'التفسير الميسر',
                style: TextStyle(
                  fontFamily: AppTypography.arabicFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            params.tafsirText!.trim(),
            style: TextStyle(
              fontFamily: AppTypography.arabicFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: theme.textColor.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ShareCardTheme theme) {
    final rangeText = params.fromAyah == params.toAyah
        ? 'الآية ${toArabicDigits(params.fromAyah)}'
        : 'الآيات ${toArabicDigits(params.fromAyah)} - ${toArabicDigits(params.toAyah)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ayah range citation
        Text(
          '[سورة ${params.surahName} : $rangeText]',
          style: TextStyle(
            fontFamily: AppTypography.arabicFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.textColor.withOpacity(0.65),
          ),
        ),

        // App Branding
        if (params.includeAppBranding)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/ayaat.png',
                height: 16,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.auto_stories,
                  size: 14,
                  color: theme.accentColor,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'آيات',
                style: TextStyle(
                  fontFamily: AppTypography.arabicFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.accentColor,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
