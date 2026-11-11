import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_dialog_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/views/khatma_all_wirds_page.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_confetti_widget.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_time_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Active Khatma dashboard view matching Reference Screenshots 26 and 31.
///
/// Features:
/// - Current active wird portion with exact Quran verse quotes and page numbers.
/// - Relative day label ("اليوم", "بعد يومين", etc.).
/// - Primary completion CTA button ("أكملت هذا الورد") with checkmark.
/// - Confetti burst animation upon wird completion without duplicate triggers.
/// - Daily reminder toggle and time picker dialog (Reference 23).
/// - "جميع الأوراد" navigation card.
/// - "حذف الختمة" card with confirmation dialog.
class KhatmaActiveView extends StatefulWidget {
  final KhatmaLoaded loadedState;

  const KhatmaActiveView({super.key, required this.loadedState});

  @override
  State<KhatmaActiveView> createState() => _KhatmaActiveViewState();
}

class _KhatmaActiveViewState extends State<KhatmaActiveView> {
  final GlobalKey<KhatmaConfettiWidgetState> _confettiKey = GlobalKey();
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final khatma = widget.loadedState.khatma;
    final currentWird = widget.loadedState.currentWird;
    final relativeLabel = widget.loadedState.relativeDayLabel;

    return BlocListener<KhatmaCubit, KhatmaState>(
      listenWhen: (previous, current) =>
          current is KhatmaLoaded &&
          ((current.justCompletedWird &&
                  (previous is! KhatmaLoaded || !previous.justCompletedWird)) ||
              (current.permissionDeniedNotice &&
                  (previous is! KhatmaLoaded ||
                      !previous.permissionDeniedNotice))),
      listener: (context, state) {
        if (state is KhatmaLoaded) {
          if (state.justCompletedWird) {
            _confettiKey.currentState?.play();
            context.read<KhatmaCubit>().resetCompletionFeedback();
          }
          if (state.permissionDeniedNotice) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.tr(AppStrings.notificationPermissionRequired),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<KhatmaCubit>().resetCompletionFeedback();
          }
        }
      },
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: colors.scaffoldBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: Text(
            AppStrings.tr(AppStrings.khatmaTitle),
            style: AppTypography.displayLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sub-header row: Day Title and Relative Day Label
                  _buildHeaderRow(context, currentWird, relativeLabel),
                  SizedBox(height: AppSpacing.md),

                  // Quran Verse Card: Start and End Ayah portions
                  _buildWirdCard(context, currentWird),
                  SizedBox(height: AppSpacing.xl),

                  // Primary CTA Button: "أكملت هذا الورد"
                  _buildCompletionButton(context, khatma, currentWird),
                  SizedBox(height: AppSpacing.xxl),

                  // Section header: "تذكير"
                  Text(
                    AppStrings.tr(AppStrings.reminder),
                    style: AppTypography.labelLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Reminder Card (Switch & Time)
                  _buildReminderCard(context, khatma),
                  SizedBox(height: AppSpacing.md),

                  // "جميع الأوراد" Navigation Card
                  _buildAllWirdsCard(context, khatma),
                  SizedBox(height: AppSpacing.md),

                  // "حذف الختمة" Card
                  _buildDeleteCard(context),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),

            // Non-blocking Confetti Overlay
            Positioned.fill(child: KhatmaConfettiWidget(key: _confettiKey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    KhatmaWird wird,
    String relativeLabel,
  ) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          wird.dayTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        Text(
          relativeLabel,
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWirdCard(BuildContext context, KhatmaWird wird) {
    final colors = context.colors;

    return AppCard.standard(
      padding: EdgeInsets.all(AppSpacing.lg),
      onTap: () {
        try {
          context.push('${AppRoutes.reader}?page=${wird.startPageNumber}');
        } catch (_) {}
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Start Ayah Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'من ${wird.startSurahName}: ${toArabicDigits(wird.startAyahNumber)}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                toArabicDigits(wird.startPageNumber),
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            wird.firstVerseText,
            textAlign: TextAlign.right,
            style: AppTypography.quranText.copyWith(
              fontSize: 18.sp,
              color: colors.textPrimary,
              height: 1.8,
            ),
          ),
          SizedBox(height: 20.h),

          // End Ayah Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إلى ${wird.endSurahName}: ${toArabicDigits(wird.endAyahNumber)}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                toArabicDigits(wird.endPageNumber),
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            wird.lastVerseText,
            textAlign: TextAlign.right,
            style: AppTypography.quranText.copyWith(
              fontSize: 18.sp,
              color: colors.textPrimary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionButton(
    BuildContext context,
    Khatma khatma,
    KhatmaWird currentWird,
  ) {
    final colors = context.colors;
    final isDone = khatma.isCompleted;

    return InkWell(
      onTap: (_isCompleting || isDone)
          ? null
          : () async {
              setState(() => _isCompleting = true);
              try {
                await context.read<KhatmaCubit>().completeCurrentWird();
              } finally {
                if (mounted) setState(() => _isCompleting = false);
              }
            },
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: isDone ? colors.primary.withOpacity(0.8) : colors.primary,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isDone
                  ? AppStrings.tr(AppStrings.khatmaCompleted)
                  : AppStrings.tr(AppStrings.completedWird),
              style: AppTypography.titleSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Khatma khatma) {
    final colors = context.colors;

    return AppCard.standard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      onTap: () async {
        final initialTime = TimeOfDay(
          hour: khatma.reminderTimeHour,
          minute: khatma.reminderTimeMinute,
        );
        final picked = await showKhatmaTimePicker(
          context: context,
          initialTime: initialTime,
        );
        if (picked != null && context.mounted) {
          context.read<KhatmaCubit>().updateReminderTime(
            picked.hour,
            picked.minute,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.tr(AppStrings.dailyWird),
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                khatma.formattedReminderTime,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          AppSwitch(
            value: khatma.reminderEnabled,
            onChanged: (enabled) {
              context.read<KhatmaCubit>().toggleReminder(enabled);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllWirdsCard(BuildContext context, Khatma khatma) {
    final colors = context.colors;

    return AppCard.standard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      onTap: () {
        try {
          context.push(AppRoutes.khatmaAllWirds);
        } catch (_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => KhatmaAllWirdsPage(khatma: khatma),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.tr(AppStrings.allWirds),
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          Text(
            toArabicDigits(khatma.totalDays),
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteCard(BuildContext context) {
    final colors = context.colors;

    return AppCard.standard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      onTap: () => _confirmDelete(context),
      child: Center(
        child: Text(
          AppStrings.tr(AppStrings.deleteKhatma),
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.error,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colors = context.colors;

    return AppDialogShell.show<void>(
      context: context,
      title: AppStrings.tr(AppStrings.deleteKhatma),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.tr(AppStrings.cancel)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<KhatmaCubit>().deleteKhatma();
          },
          child: Text(
            AppStrings.tr(AppStrings.delete),
            style: TextStyle(color: colors.error),
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          AppStrings.tr(AppStrings.deleteKhatmaConfirm),
          style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }
}
