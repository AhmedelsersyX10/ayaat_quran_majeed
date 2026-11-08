import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal bottom sheet for configuring recitation range and repetition rules.
///
/// Pixel-faithful replica of Reference 40 ("إعدادات التلاوة").
///
/// Features:
/// 1. "نطاق التلاوة":
///    - "من" (Start verse) and "إلى" (End verse) with chevrons.
///    - Order validation: automatically enforces `start <= end`.
/// 2. "التكرار":
///    - "تكرار النطاق": Toggle switch + counter stepper (`+` / `-`).
///    - "تكرار الآية": Toggle switch + counter stepper (`+` / `-`).
///    - Displayed count in styled lavender container with Arabic digits.
/// 3. Immediate reactive updates to [AudioPlaybackCubit] and [PlaybackRepository].
class RecitationSettingsSheet extends StatefulWidget {
  final QuranMetadataService metadataService;

  const RecitationSettingsSheet({
    super.key,
    this.metadataService = const QuranMetadataService(),
  });

  /// Displays the Recitation Settings modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) {
    final cubit = context.read<AudioPlaybackCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) => BlocProvider<AudioPlaybackCubit>.value(
        value: cubit,
        child: RecitationSettingsSheet(
          metadataService: metadataService,
        ),
      ),
    );
  }

  @override
  State<RecitationSettingsSheet> createState() => _RecitationSettingsSheetState();
}

class _RecitationSettingsSheetState extends State<RecitationSettingsSheet> {
  // Local active repeat counts for immediate synchronous UI responsiveness
  int? _localRangeRepeat;
  int? _localAyahRepeat;

  // Local display cache for repeat counts when switch is turned OFF
  int _cachedRangeRepeat = 2;
  int _cachedAyahRepeat = 2;

  // Local range state fallback for when idle
  PlaybackRange? _localRange;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AudioPlaybackCubit>();
    final session = cubit.state;
    _localRange = session.range;
    if (session.repeatSettings.repeatRange > 1) {
      _cachedRangeRepeat = session.repeatSettings.repeatRange;
    }
    if (session.repeatSettings.repeatAyah > 1) {
      _cachedAyahRepeat = session.repeatSettings.repeatAyah;
    }
  }

  PlaybackRange _resolveCurrentRange(AudioPlaybackState audioState) {
    return audioState.range;
  }

  Future<void> _pickFromAyah(PlaybackRange currentRange) async {
    final result = await AyahPickerSheet.show(
      context,
      surahNumber: currentRange.startSurah,
      initialAyahNumber: currentRange.startAyah,
      metadataService: widget.metadataService,
    );

    if (!mounted || result == null) return;

    final int newStartSurah = result.surahNumber;
    final int newStartAyah = result.ayahNumber;

    int newEndSurah = currentRange.endSurah;
    int newEndAyah = currentRange.endAyah;

    // Selection order validation: start cannot precede end
    if (newStartSurah > newEndSurah ||
        (newStartSurah == newEndSurah && newStartAyah > newEndAyah)) {
      newEndSurah = newStartSurah;
      newEndAyah = newStartAyah;
    }

    final updatedRange = PlaybackRange(
      startSurah: newStartSurah,
      startAyah: newStartAyah,
      endSurah: newEndSurah,
      endAyah: newEndAyah,
    );

    setState(() {
      _localRange = updatedRange;
    });

    context.read<AudioPlaybackCubit>().configureRange(updatedRange);
  }

  Future<void> _pickToAyah(PlaybackRange currentRange) async {
    final result = await AyahPickerSheet.show(
      context,
      surahNumber: currentRange.endSurah,
      initialAyahNumber: currentRange.endAyah,
      metadataService: widget.metadataService,
    );

    if (!mounted || result == null) return;

    final int newEndSurah = result.surahNumber;
    final int newEndAyah = result.ayahNumber;

    int newStartSurah = currentRange.startSurah;
    int newStartAyah = currentRange.startAyah;

    // Selection order validation: end cannot be before start
    if (newEndSurah < newStartSurah ||
        (newEndSurah == newStartSurah && newEndAyah < newStartAyah)) {
      newStartSurah = newEndSurah;
      newStartAyah = newEndAyah;
    }

    final updatedRange = PlaybackRange(
      startSurah: newStartSurah,
      startAyah: newStartAyah,
      endSurah: newEndSurah,
      endAyah: newEndAyah,
    );

    setState(() {
      _localRange = updatedRange;
    });

    context.read<AudioPlaybackCubit>().configureRange(updatedRange);
  }

  void _onToggleRangeRepeat(bool active, RepeatSettings currentSettings) {
    if (active) {
      final newCount = _cachedRangeRepeat >= 2 ? _cachedRangeRepeat : 2;
      setState(() {
        _localRangeRepeat = newCount;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatRange: newCount,
      ));
    } else {
      setState(() {
        _localRangeRepeat = 1;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatRange: 1,
        currentRangeRepeat: 1,
      ));
    }
  }

  void _onIncrementRangeRepeat(RepeatSettings currentSettings) {
    final effectiveRepeat = _localRangeRepeat ?? currentSettings.repeatRange;
    final bool isCurrentlyActive = effectiveRepeat > 1;
    final currentCount = isCurrentlyActive ? effectiveRepeat : _cachedRangeRepeat;
    final newCount = (currentCount + 1).clamp(2, 20);

    setState(() {
      _localRangeRepeat = newCount;
      _cachedRangeRepeat = newCount;
    });

    context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
      repeatRange: newCount,
    ));
  }

  void _onDecrementRangeRepeat(RepeatSettings currentSettings) {
    final effectiveRepeat = _localRangeRepeat ?? currentSettings.repeatRange;
    final bool isCurrentlyActive = effectiveRepeat > 1;
    if (!isCurrentlyActive) return;

    if (effectiveRepeat > 2) {
      final newCount = effectiveRepeat - 1;
      setState(() {
        _localRangeRepeat = newCount;
        _cachedRangeRepeat = newCount;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatRange: newCount,
      ));
    } else {
      // Reaching below 2 turns off range repetition
      setState(() {
        _localRangeRepeat = 1;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatRange: 1,
        currentRangeRepeat: 1,
      ));
    }
  }

  void _onToggleAyahRepeat(bool active, RepeatSettings currentSettings) {
    if (active) {
      final newCount = _cachedAyahRepeat >= 2 ? _cachedAyahRepeat : 2;
      setState(() {
        _localAyahRepeat = newCount;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatAyah: newCount,
      ));
    } else {
      setState(() {
        _localAyahRepeat = 1;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatAyah: 1,
        currentAyahRepeat: 1,
      ));
    }
  }

  void _onIncrementAyahRepeat(RepeatSettings currentSettings) {
    final effectiveRepeat = _localAyahRepeat ?? currentSettings.repeatAyah;
    final bool isCurrentlyActive = effectiveRepeat > 1;
    final currentCount = isCurrentlyActive ? effectiveRepeat : _cachedAyahRepeat;
    final newCount = (currentCount + 1).clamp(2, 20);

    setState(() {
      _localAyahRepeat = newCount;
      _cachedAyahRepeat = newCount;
    });

    context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
      repeatAyah: newCount,
    ));
  }

  void _onDecrementAyahRepeat(RepeatSettings currentSettings) {
    final effectiveRepeat = _localAyahRepeat ?? currentSettings.repeatAyah;
    final bool isCurrentlyActive = effectiveRepeat > 1;
    if (!isCurrentlyActive) return;

    if (effectiveRepeat > 2) {
      final newCount = effectiveRepeat - 1;
      setState(() {
        _localAyahRepeat = newCount;
        _cachedAyahRepeat = newCount;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatAyah: newCount,
      ));
    } else {
      // Reaching below 2 turns off ayah repetition
      setState(() {
        _localAyahRepeat = 1;
      });
      context.read<AudioPlaybackCubit>().setRepeatSettings(currentSettings.copyWith(
        repeatAyah: 1,
        currentAyahRepeat: 1,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlaybackCubit, AudioPlaybackState>(
      builder: (context, audioState) {
        final currentRange = _localRange ?? _resolveCurrentRange(audioState);
        final repeatSettings = audioState.repeatSettings;

        final activeRangeRepeat = _localRangeRepeat ?? repeatSettings.repeatRange;
        final isRangeRepeatActive = activeRangeRepeat > 1;
        final rangeCount = isRangeRepeatActive
            ? activeRangeRepeat
            : _cachedRangeRepeat;

        final activeAyahRepeat = _localAyahRepeat ?? repeatSettings.repeatAyah;
        final isAyahRepeatActive = activeAyahRepeat > 1;
        final ayahCount = isAyahRepeatActive
            ? activeAyahRepeat
            : _cachedAyahRepeat;

        final startSurahName =
            widget.metadataService.getSurahNameArabic(currentRange.startSurah);
        final endSurahName =
            widget.metadataService.getSurahNameArabic(currentRange.endSurah);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 6.h),
                  // Sheet Drag Handle Indicator
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // 1. Top Title (Ref 40)
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
                    child: Text(
                      AppStrings.tr(AppStrings.recitationSettings),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // 2. Section: نطاق التلاوة (Ref 40)
                  _buildSectionHeader(AppStrings.tr(AppStrings.recitationRange)),

                  // "من" Row
                  _buildRangeRow(
                    label: AppStrings.tr(AppStrings.fromAyah),
                    surahName: startSurahName,
                    ayahNumber: currentRange.startAyah,
                    onTap: () => _pickFromAyah(currentRange),
                  ),

                  _buildDivider(),

                  // "إلى" Row
                  _buildRangeRow(
                    label: AppStrings.tr(AppStrings.toAyah),
                    surahName: endSurahName,
                    ayahNumber: currentRange.endAyah,
                    onTap: () => _pickToAyah(currentRange),
                  ),

                  // 3. Section: التكرار (Ref 40)
                  _buildSectionHeader(AppStrings.tr(AppStrings.repeatSection)),

                  // "تكرار النطاق" Switch & Stepper
                  _buildRepeatBlock(
                    title: AppStrings.tr(AppStrings.repeatRange),
                    isActive: isRangeRepeatActive,
                    count: rangeCount,
                    onToggle: (val) => _onToggleRangeRepeat(val, repeatSettings),
                    onIncrement: () => _onIncrementRangeRepeat(repeatSettings),
                    onDecrement: () => _onDecrementRangeRepeat(repeatSettings),
                  ),

                  _buildDivider(),

                  // "تكرار الآية" Switch & Stepper
                  _buildRepeatBlock(
                    title: AppStrings.tr(AppStrings.repeatAyah),
                    isActive: isAyahRepeatActive,
                    count: ayahCount,
                    onToggle: (val) => _onToggleAyahRepeat(val, repeatSettings),
                    onIncrement: () => _onIncrementAyahRepeat(repeatSettings),
                    onDecrement: () => _onDecrementAyahRepeat(repeatSettings),
                  ),

                  SizedBox(height: 28.h + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a full-width sand/beige banner header matching Reference 40.
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4EFE6),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// Builds a range endpoint selector row ("من" or "إلى") with chevron left.
  Widget _buildRangeRow({
    required String label,
    required String surahName,
    required int ayahNumber,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  formatAyahLabel(surahName, ayahNumber),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds repetition toggle switch and stepper counter matching Reference 40.
  Widget _buildRepeatBlock({
    required String title,
    required bool isActive,
    required int count,
    required ValueChanged<bool> onToggle,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          // Row 1: Label on right, Switch on left (in RTL)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onToggle,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primaryLight,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.border,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Row 2: "عدد المرات" + lavender count box on right; stepper buttons (+, -) on left
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stepper buttons on left (Ref 40: [+] circle on left, [-] circle to its right)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular [+] Button
                  Semantics(
                    button: true,
                    label: 'زيادة التكرار',
                    child: InkWell(
                      onTap: onIncrement,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEDE8E1),
                          border: Border.all(
                            color: const Color(0xFF5A5854),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 20.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Circular [-] Button
                  Semantics(
                    button: true,
                    label: 'إنقاص التكرار',
                    child: InkWell(
                      onTap: isActive ? onDecrement : null,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: isActive
                                ? AppColors.border
                                : AppColors.border.withOpacity(0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove_rounded,
                            size: 20.sp,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // "عدد المرات" + Lavender Box on right
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lavender Badge with Arabic numeral (Ref 40)
                  Container(
                    width: 42.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5F0),
                      borderRadius: BorderRadius.circular(6.r),
                      border: const Border(
                        bottom: BorderSide(
                          color: Color(0xFF5A5854),
                          width: 1.5,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      toArabicDigits(count),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    AppStrings.tr(AppStrings.repeatCount),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: AppColors.divider,
      indent: 20.w,
      endIndent: 20.w,
    );
  }
}
