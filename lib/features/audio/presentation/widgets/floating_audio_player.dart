import 'dart:math' as math;
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/recitation_settings_sheet.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/reciter_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Floating audio player matching Reference 05 (compact pill) and Video 37 (expanded card).
///
/// Features:
/// - Compact mode (Ref 05): pill shape with green circular play button, reciter name, and chevron.
/// - Expanded mode (Video 37):
///   - Top bar: close button (x), reciter name with dropdown chevron, more options (...).
///   - Loading state: green circular spinner with "جاري التحميل" in green.
///   - Playing/Paused state: green circular indicator with animated equalizer bars,
///     skip previous ayah, play/pause, and skip next ayah.
/// - Pure RTL layout, accessible semantics, responsive via flutter_screenutil.
class FloatingAudioPlayer extends StatefulWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onDismiss;
  final VoidCallback? onPlayFallback;
  final bool isInitiallyExpanded;

  const FloatingAudioPlayer({
    super.key,
    this.onSettingsPressed,
    this.onDismiss,
    this.onPlayFallback,
    this.isInitiallyExpanded = false,
  });

  @override
  State<FloatingAudioPlayer> createState() => FloatingAudioPlayerState();
}

class FloatingAudioPlayerState extends State<FloatingAudioPlayer> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void expand() {
    if (!_isExpanded) {
      setState(() => _isExpanded = true);
    }
  }

  void collapse() {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
    }
  }

  String _resolveReciterName(BuildContext context, AudioPlaybackState audioState) {
    if (audioState.reciter != null && audioState.reciter!.name.isNotEmpty) {
      return audioState.reciter!.name;
    }
    try {
      final reciterState = context.watch<ReciterSelectionCubit>().state;
      if (reciterState is ReciterSelectionSuccess) {
        return reciterState.selectedReciter.name;
      }
    } catch (_) {}
    return 'محمود خليل الحصري';
  }

  void _openReciterPicker(BuildContext context) {
    ReciterSelectionSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlaybackCubit, AudioPlaybackState>(
      builder: (context, audioState) {
        final reciterName = _resolveReciterName(context, audioState);
        final status = audioState.status;
        final isPlaying = status == PlaybackStatus.playing;
        final isLoading = status == PlaybackStatus.loading;

        // Auto-expand on loading or playing if not already expanded
        final bool effectivelyExpanded = _isExpanded || isLoading || isPlaying;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutQuart,
            child: effectivelyExpanded
                ? _buildExpandedCard(context, audioState, reciterName, isPlaying, isLoading)
                : _buildCompactPill(context, audioState, reciterName, isPlaying, isLoading),
          ),
        );
      },
    );
  }

  /// Builds the compact pill player matching Reference 05.
  Widget _buildCompactPill(
    BuildContext context,
    AudioPlaybackState audioState,
    String reciterName,
    bool isPlaying,
    bool isLoading,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reciter name and dropdown chevron
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                expand();
                _openReciterPicker(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    reciterName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            // Play / Pause / Loading button
            Semantics(
              button: true,
              label: isPlaying
                  ? AppStrings.tr(AppStrings.pause)
                  : AppStrings.tr(AppStrings.play),
              child: InkWell(
                onTap: () => _handlePlayPause(context, audioState),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the expanded player card matching Video 37.
  Widget _buildExpandedCard(
    BuildContext context,
    AudioPlaybackState audioState,
    String reciterName,
    bool isPlaying,
    bool isLoading,
  ) {
    return Container(
      width: 330.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withOpacity(0.7), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1C000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: [x] Dismiss --- Reciter Name + Chevron --- [...] Settings
          Row(
            children: [
              // Close / Dismiss button (x)
              Semantics(
                button: true,
                label: AppStrings.tr(AppStrings.close),
                child: InkWell(
                  onTap: () {
                    context.read<AudioPlaybackCubit>().stop();
                    collapse();
                    widget.onDismiss?.call();
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              // Center: Reciter name + chevron dropdown
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openReciterPicker(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        reciterName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
              // Settings button (...)
              Semantics(
                button: true,
                label: AppStrings.tr(AppStrings.recitationSettings),
                child: InkWell(
                  onTap: widget.onSettingsPressed ??
                      () => RecitationSettingsSheet.show(context),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Bottom Controls Row: Loading state OR Playback controls
          if (isLoading)
            _buildLoadingRow(context)
          else
            _buildControlsRow(context, audioState, isPlaying),
        ],
      ),
    );
  }

  /// Builds the loading controls row with spinner and "جاري التحميل" (Video 37 at 00:00).
  Widget _buildLoadingRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      child: Row(
        children: [
          // Animated circular spinner inside green container
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppStrings.tr(AppStrings.loadingAudio),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          // Empty spacer matching left circle width for symmetry
          SizedBox(width: 36.w),
        ],
      ),
    );
  }

  /// Builds active playback controls: animated sound waves indicator, skip previous, play/pause, skip next.
  Widget _buildControlsRow(
    BuildContext context,
    AudioPlaybackState audioState,
    bool isPlaying,
  ) {
    final audioCubit = context.read<AudioPlaybackCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular status button with animated sound waves (Equalizer)
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: EqualizerWaveBars(isPlaying: isPlaying),
            ),
          ),
          // Controls group: Skip Previous --- Play/Pause --- Skip Next
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skip Next Ayah (pointed left in RTL)
              Semantics(
                button: true,
                label: AppStrings.tr(AppStrings.nextAyah),
                child: InkWell(
                  onTap: () => audioCubit.skipNextAyah(),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.skip_previous_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Main Play / Pause button
              Semantics(
                button: true,
                label: isPlaying
                    ? AppStrings.tr(AppStrings.pause)
                    : AppStrings.tr(AppStrings.play),
                child: InkWell(
                  onTap: () => _handlePlayPause(context, audioState),
                  borderRadius: BorderRadius.circular(24.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 38.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Skip Previous Ayah (pointed right in RTL)
              Semantics(
                button: true,
                label: AppStrings.tr(AppStrings.previousAyah),
                child: InkWell(
                  onTap: () => audioCubit.skipPreviousAyah(),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.skip_next_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Collapse / minimize toggle
          Semantics(
            button: true,
            label: 'تصغير المشغل',
            child: InkWell(
              onTap: collapse,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlayPause(BuildContext context, AudioPlaybackState audioState) {
    final cubit = context.read<AudioPlaybackCubit>();
    switch (audioState.status) {
      case PlaybackStatus.playing:
        cubit.pause();
        break;
      case PlaybackStatus.paused:
        cubit.resume();
        break;
      case PlaybackStatus.idle:
      case PlaybackStatus.completed:
      case PlaybackStatus.failure:
        if (widget.onPlayFallback != null) {
          widget.onPlayFallback!();
        } else {
          cubit.playAyah(audioState.surahNumber, audioState.currentAyah ?? 1);
        }
        break;
      case PlaybackStatus.loading:
        cubit.pause();
        break;
    }
  }
}

/// Animated 3-bar sound wave equalizer indicator for the active playing state.
class EqualizerWaveBars extends StatefulWidget {
  final bool isPlaying;

  const EqualizerWaveBars({super.key, required this.isPlaying});

  @override
  State<EqualizerWaveBars> createState() => _EqualizerWaveBarsState();
}

class _EqualizerWaveBarsState extends State<EqualizerWaveBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant EqualizerWaveBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final h1 = 6.0 + 8.0 * math.sin(t * math.pi);
        final h2 = 14.0 - 7.0 * math.cos(t * math.pi);
        final h3 = 8.0 + 6.0 * math.sin((t + 0.3) * math.pi);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBar(widget.isPlaying ? h1 : 8.0),
            SizedBox(width: 2.w),
            _buildBar(widget.isPlaying ? h2 : 14.0),
            SizedBox(width: 2.w),
            _buildBar(widget.isPlaying ? h3 : 9.0),
          ],
        );
      },
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 2.5.w,
      height: height.clamp(4.0, 16.0).h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
