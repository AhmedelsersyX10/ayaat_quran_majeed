import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_clock.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_reminder_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'khatma_state.dart';

/// Cubit orchestrating active Khatma lifecycle, progress, and scheduling state.
class KhatmaCubit extends Cubit<KhatmaState> {
  final KhatmaRepository _repository;
  final KhatmaReminderService _reminderService;
  final KhatmaClock _clock;

  KhatmaCubit({
    required KhatmaRepository repository,
    KhatmaReminderService? reminderService,
    KhatmaClock clock = defaultKhatmaClock,
  }) : _repository = repository,
       _reminderService = reminderService ?? const _NoOpReminderService(),
       _clock = clock,
       super(const KhatmaInitial());

  /// Loads the active Khatma. Emits [KhatmaEmpty] if none exists, or [KhatmaLoaded].
  Future<void> loadKhatma({DateTime? currentDate}) async {
    emit(const KhatmaLoading());
    try {
      final khatma = await _repository.getActiveKhatma();
      if (khatma == null) {
        emit(const KhatmaEmpty());
        return;
      }
      _emitLoaded(khatma, currentDate: currentDate);
    } catch (e) {
      emit(KhatmaFailure('فشل تحميل الختمة: $e'));
    }
  }

  /// Begins the new Khatma setup wizard flow (Reference 06).
  void startCreation() {
    emit(const KhatmaCreating(step: KhatmaCreationStep.menu));
  }

  /// Selects a specific program for the Khatma without persisting yet.
  /// Advances wizard step to [KhatmaCreationStep.startFrom].
  void selectProgram(KhatmaProgram program) {
    if (state is KhatmaCreating) {
      emit(
        (state as KhatmaCreating).copyWith(
          selectedProgram: program,
          step: KhatmaCreationStep.startFrom,
        ),
      );
    } else {
      emit(
        KhatmaCreating(
          selectedProgram: program,
          step: KhatmaCreationStep.startFrom,
        ),
      );
    }
  }

  /// Selects a category for custom programs (meaning or parts/quarters).
  /// Advances wizard step to [KhatmaCreationStep.programPicker].
  void selectCategory(KhatmaProgramCategory category) {
    if (state is KhatmaCreating) {
      emit(
        (state as KhatmaCreating).copyWith(
          customProgramCategory: category,
          step: KhatmaCreationStep.programPicker,
        ),
      );
    } else {
      emit(
        KhatmaCreating(
          customProgramCategory: category,
          step: KhatmaCreationStep.programPicker,
        ),
      );
    }
  }

  /// Navigates to a specific step in the Khatma creation wizard.
  void goToStep(KhatmaCreationStep step) {
    if (state is KhatmaCreating) {
      emit((state as KhatmaCreating).copyWith(step: step));
    } else {
      emit(KhatmaCreating(step: step));
    }
  }

  /// Cancels the Khatma creation wizard and resets state to [KhatmaEmpty].
  void cancelCreation() {
    emit(const KhatmaEmpty());
  }

  /// Creates and starts a new Khatma.
  Future<void> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  }) async {
    emit(const KhatmaLoading());
    try {
      final khatma = await _repository.createKhatma(
        program: program,
        startDate: startDate,
        startWirdNumber: startWirdNumber,
        reminderEnabled: reminderEnabled,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      );

      if (reminderEnabled) {
        final granted = await _reminderService.requestPermission();
        if (granted) {
          await _scheduleReminderForKhatma(khatma);
        }
      }

      _emitLoaded(khatma, currentDate: startDate);
    } catch (e) {
      emit(KhatmaFailure('فشل إنشاء الختمة: $e'));
    }
  }

  /// Marks the current active uncompleted wird as completed.
  Future<void> completeCurrentWird({DateTime? completionDate}) async {
    try {
      final updated = await _repository.completeCurrentWird(
        completionDate: completionDate,
      );
      if (updated.isCompleted) {
        await _reminderService.cancelDailyReminder();
      } else if (updated.reminderEnabled) {
        await _scheduleReminderForKhatma(updated);
      }
      _emitLoaded(
        updated,
        currentDate: completionDate,
        justCompletedWird: true,
      );
    } catch (e) {
      emit(KhatmaFailure('فشل تسجيل إكمال الورد: $e'));
    }
  }

  /// Marks a specific wird by [wirdNumber] as completed.
  Future<void> completeWird(int wirdNumber, {DateTime? completionDate}) async {
    try {
      final updated = await _repository.completeWird(
        wirdNumber,
        completionDate: completionDate,
      );
      if (updated.isCompleted) {
        await _reminderService.cancelDailyReminder();
      } else if (updated.reminderEnabled) {
        await _scheduleReminderForKhatma(updated);
      }
      _emitLoaded(
        updated,
        currentDate: completionDate,
        justCompletedWird: true,
      );
    } catch (e) {
      emit(KhatmaFailure('فشل تسجيل إكمال الورد: $e'));
    }
  }

  /// Reverts completion status for a specific wird (undo).
  Future<void> uncompleteWird(int wirdNumber) async {
    try {
      final updated = await _repository.uncompleteWird(wirdNumber);
      if (updated.reminderEnabled) {
        await _scheduleReminderForKhatma(updated);
      }
      _emitLoaded(updated);
    } catch (e) {
      emit(KhatmaFailure('فشل تعديل حالة الورد: $e'));
    }
  }

  /// Deletes the active Khatma and returns state to [KhatmaEmpty].
  Future<void> deleteKhatma() async {
    emit(const KhatmaLoading());
    try {
      await _reminderService.cancelDailyReminder();
      await _repository.deleteKhatma();
      emit(const KhatmaEmpty());
    } catch (e) {
      emit(KhatmaFailure('فشل حذف الختمة: $e'));
    }
  }

  /// Toggles the daily wird reminder switch on or off.
  Future<void> toggleReminder(bool enabled) async {
    try {
      if (enabled) {
        final granted = await _reminderService.requestPermission();
        if (!granted) {
          final current = state is KhatmaLoaded
              ? (state as KhatmaLoaded)
              : null;
          if (current != null) {
            emit(
              KhatmaLoaded(
                khatma: current.khatma.copyWith(reminderEnabled: false),
                currentWird: current.currentWird,
                relativeDayLabel: current.relativeDayLabel,
                permissionDeniedNotice: true,
              ),
            );
          }
          return;
        }
      }

      final updated = await _repository.updateReminder(enabled: enabled);
      if (enabled) {
        await _scheduleReminderForKhatma(updated);
      } else {
        await _reminderService.cancelDailyReminder();
      }
      _emitLoaded(updated);
    } catch (e) {
      emit(KhatmaFailure('فشل تحديث التنبيه: $e'));
    }
  }

  /// Updates the daily reminder scheduled time.
  Future<void> updateReminderTime(int hour, int minute) async {
    try {
      final current = state is KhatmaLoaded
          ? (state as KhatmaLoaded).khatma
          : null;
      final isEnabled = current?.reminderEnabled ?? true;
      final updated = await _repository.updateReminder(
        enabled: isEnabled,
        hour: hour,
        minute: minute,
      );
      if (updated.reminderEnabled) {
        await _scheduleReminderForKhatma(updated);
      }
      _emitLoaded(updated);
    } catch (e) {
      emit(KhatmaFailure('فشل تحديث وقت التنبيه: $e'));
    }
  }

  /// Helper to schedule or update the daily local notification.
  Future<void> _scheduleReminderForKhatma(Khatma khatma) async {
    if (!khatma.reminderEnabled || khatma.isCompleted) {
      await _reminderService.cancelDailyReminder();
      return;
    }

    final currentWird = khatma.currentWird;
    const title = 'تذكير الورد اليومي';
    final body =
        'حان وقت قراءة ${currentWird.dayTitle}: من ${currentWird.startSurahName} إلى ${currentWird.endSurahName}';
    final payload = '${AppRoutes.reader}?page=${currentWird.startPageNumber}';

    await _reminderService.scheduleDailyReminder(
      hour: khatma.reminderTimeHour,
      minute: khatma.reminderTimeMinute,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Clears one-shot feedback flags ([justCompletedWird] and [permissionDeniedNotice])
  /// to prevent re-triggering animations or snackbars on rebuilds.
  void resetCompletionFeedback() {
    if (state is KhatmaLoaded) {
      final current = state as KhatmaLoaded;
      if (current.justCompletedWird || current.permissionDeniedNotice) {
        emit(
          KhatmaLoaded(
            khatma: current.khatma,
            currentWird: current.currentWird,
            relativeDayLabel: current.relativeDayLabel,
            justCompletedWird: false,
            permissionDeniedNotice: false,
          ),
        );
      }
    }
  }

  /// Helper to calculate relative day label and emit [KhatmaLoaded].
  void _emitLoaded(
    Khatma khatma, {
    DateTime? currentDate,
    bool justCompletedWird = false,
  }) {
    final now = currentDate ?? _clock();
    final currentWird = khatma.currentWird;
    final relativeLabel = khatma.isCompleted
        ? 'مكتملة'
        : currentWird.relativeDayLabel(now);

    emit(
      KhatmaLoaded(
        khatma: khatma,
        currentWird: currentWird,
        relativeDayLabel: relativeLabel,
        justCompletedWird: justCompletedWird,
      ),
    );
  }
}

/// Fallback reminder service that performs no operations (used when no service is injected).
class _NoOpReminderService implements KhatmaReminderService {
  const _NoOpReminderService();

  @override
  Future<void> init({
    void Function(String? payload)? onNotificationTap,
  }) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {}

  @override
  Future<void> cancelDailyReminder() async {}
}
