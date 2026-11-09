import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/ayah_tafsir.dart';
import '../cubit/tafsir_cubit.dart';
import '../cubit/tafsir_state.dart';
import '../widgets/tafsir_card.dart';

/// Full-screen navigable Tafsir reader matching Reference 17.
///
/// Features:
/// - Horizontal 604-page swiping (RTL) synchronized with Mushaf reader.
/// - Surah banners & Basmallah on first ayah of each surah.
/// - Distinct Quran text in Uthmanic/Amiri font with verse-end symbols.
/// - Rounded beige cards displaying the Tafsir explanation text.
/// - Audio recitation follow-along highlight.
/// - Loading indicator, empty state, and failure retry state.
class TafsirPageView extends StatefulWidget {
  final int initialPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onToggleChrome;
  final void Function(int surah, int ayah)? onVerseLongPress;

  const TafsirPageView({
    super.key,
    required this.initialPage,
    required this.onPageChanged,
    required this.onToggleChrome,
    this.onVerseLongPress,
  });

  @override
  State<TafsirPageView> createState() => TafsirPageViewState();
}

class TafsirPageViewState extends State<TafsirPageView> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPage - 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TafsirCubit>().loadPageTafsir(_currentPage);
      }
    });
  }

  @override
  void didUpdateWidget(TafsirPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage &&
        widget.initialPage != _currentPage) {
      jumpToPage(widget.initialPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Programmatically jump to [targetPage] (1 to 604).
  void jumpToPage(int targetPage) {
    final int safePage = targetPage.clamp(1, 604);
    if (_currentPage == safePage) return;

    _currentPage = safePage;
    if (_pageController.hasClients) {
      final int diff = (safePage - ((_pageController.page?.round() ?? 0) + 1)).abs();
      final int zeroBased = safePage - 1;
      if (diff > 5) {
        _pageController.jumpToPage(zeroBased);
      } else {
        _pageController.animateToPage(
          zeroBased,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuart,
        );
      }
    }
    context.read<TafsirCubit>().loadPageTafsir(safePage);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 604,
        onPageChanged: (zeroBasedIndex) {
          final int newPage = zeroBasedIndex + 1;
          _currentPage = newPage;
          context.read<TafsirCubit>().loadPageTafsir(newPage);
          widget.onPageChanged(newPage);
        },
        itemBuilder: (context, index) {
          final int pageNumber = index + 1;
          return _TafsirSinglePageContent(
            pageNumber: pageNumber,
            isCurrentPage: pageNumber == _currentPage,
            onToggleChrome: widget.onToggleChrome,
            onVerseLongPress: widget.onVerseLongPress,
          );
        },
      ),
    );
  }
}

class _TafsirSinglePageContent extends StatelessWidget {
  final int pageNumber;
  final bool isCurrentPage;
  final VoidCallback onToggleChrome;
  final void Function(int surah, int ayah)? onVerseLongPress;

  const _TafsirSinglePageContent({
    required this.pageNumber,
    required this.isCurrentPage,
    required this.onToggleChrome,
    this.onVerseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TafsirCubit, TafsirState>(
      buildWhen: (prev, curr) =>
          isCurrentPage &&
          (prev.status != curr.status ||
              prev.pageNumber != curr.pageNumber ||
              prev.verses != curr.verses ||
              prev.selectedBook != curr.selectedBook),
      builder: (context, state) {
        // If not the loaded page, display a lightweight spinner placeholder while paging
        if (state.pageNumber != pageNumber || state.status == TafsirStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.status == TafsirStatus.failure) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage ?? 'تعذر تحميل التفسير',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppButton.primary(
                    text: 'إعادة المحاولة',
                    onPressed: () {
                      context.read<TafsirCubit>().retry();
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (state.status == TafsirStatus.empty || state.verses.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 48.sp,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'لا يوجد تفسير متاح لهذه الصفحة',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final topPadding = MediaQuery.of(context).padding.top;
        final isLatinBook = state.selectedBook != null &&
            state.selectedBook!.language != 'ar' &&
            state.selectedBook!.category.name.toLowerCase().contains('translation');

        return GestureDetector(
          onTap: onToggleChrome,
          behavior: HitTestBehavior.opaque,
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: topPadding + 64.h,
              bottom: 140.h,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
            ),
            itemCount: state.verses.length,
            itemBuilder: (context, index) {
              final verse = state.verses[index];
              return _AyahTafsirItemWidget(
                verse: verse,
                isRtl: !isLatinBook,
                onVerseLongPress: onVerseLongPress,
              );
            },
          ),
        );
      },
    );
  }
}

class _AyahTafsirItemWidget extends StatelessWidget {
  final AyahTafsir verse;
  final bool isRtl;
  final void Function(int surah, int ayah)? onVerseLongPress;

  const _AyahTafsirItemWidget({
    required this.verse,
    required this.isRtl,
    this.onVerseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Surah Header Banner if first ayah of surah
        if (verse.isFirstAyahOfSurah) ...[
          Container(
            margin: EdgeInsets.only(top: 16.h, bottom: 12.h),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.mushafBadgeFill,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: AppColors.mushafOrnament.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'سُورَةُ ${verse.surahName}',
              style: TextStyle(
                fontFamily: AppTypography.amiriFontFamily,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.mushafBadgeText,
              ),
            ),
          ),
          if (verse.surahNumber != 1 && verse.surahNumber != 9) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.amiriFontFamily,
                  fontSize: 20.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],

        // 2. Quran Text with optional audio follow-along highlight
        BlocBuilder<AudioPlaybackCubit, AudioPlaybackState>(
          builder: (context, audioState) {
            final isAudioPlaying = audioState.hasTiming &&
                audioState.surahNumber == verse.surahNumber &&
                audioState.currentAyah == verse.ayahNumber;

            return InkWell(
              onLongPress: onVerseLongPress != null
                  ? () => onVerseLongPress!(verse.surahNumber, verse.ayahNumber)
                  : null,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: isAudioPlaying
                      ? AppColors.playbackHighlight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  '${verse.ayahText} ${verse.ayahEndSymbol}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.amiriFontFamily,
                    fontSize: 22.sp,
                    height: 2.1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),

        // 3. Tafsir Card
        TafsirCard(
          text: verse.tafsirText,
          isRtl: isRtl,
        ),

        SizedBox(height: 12.h),
      ],
    );
  }
}
