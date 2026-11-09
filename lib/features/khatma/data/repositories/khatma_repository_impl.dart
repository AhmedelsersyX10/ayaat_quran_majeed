import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/datasources/khatma_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/models/khatma_model.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_clock.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Implementation of [KhatmaRepository] coordinating storage, calculation,
/// metadata resolution, and deterministic clock evaluation.
///
/// Pure Dart — no Flutter framework dependencies.
class KhatmaRepositoryImpl implements KhatmaRepository {
  final KhatmaLocalDataSource _localDataSource;
  final QuranMetadataService _metadataService;
  final KhatmaWirdCalculator _calculator;
  final KhatmaClock _clock;

  const KhatmaRepositoryImpl({
    required KhatmaLocalDataSource localDataSource,
    required QuranMetadataService metadataService,
    required KhatmaWirdCalculator calculator,
    KhatmaClock clock = defaultKhatmaClock,
  })  : _localDataSource = localDataSource,
        _metadataService = metadataService,
        _calculator = calculator,
        _clock = clock;

  @override
  Future<Khatma?> getActiveKhatma() async {
    final model = await _localDataSource.getActiveKhatma();
    if (model == null) return null;
    return model.toEntity(_metadataService);
  }

  @override
  Future<Khatma> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  }) async {
    final wirds = _calculator.calculateWirds(
      program: program,
      startDate: startDate,
      startWirdNumber: startWirdNumber,
    );

    final completedCount = wirds.where((w) => w.isCompleted).length;
    final allCompleted = completedCount == program.totalDays && program.totalDays > 0;
    final now = _clock();

    final khatma = Khatma(
      id: 'khatma_${now.millisecondsSinceEpoch}',
      programId: program.id,
      programTitle: program.title,
      totalDays: program.totalDays,
      startDate: startDate,
      wirds: wirds,
      reminderEnabled: reminderEnabled,
      reminderTimeHour: reminderHour,
      reminderTimeMinute: reminderMinute,
      completedWirdsCount: completedCount,
      isCompleted: allCompleted,
      completedAt: allCompleted ? now : null,
      createdAt: now,
    );

    final model = KhatmaModel.fromEntity(khatma);
    await _localDataSource.saveActiveKhatma(model);
    return khatma;
  }

  @override
  Future<Khatma> completeWird(int wirdNumber, {DateTime? completionDate}) async {
    final khatma = await getActiveKhatma();
    if (khatma == null) {
      throw const KhatmaException('لا توجد ختمة نشطة لإكمال الورد فيها');
    }

    final effectiveDate = completionDate ?? _clock();
    final updatedWirds = khatma.wirds.map((w) {
      if (w.dayNumber == wirdNumber) {
        return w.copyWith(
          isCompleted: true,
          completedAt: effectiveDate,
        );
      }
      return w;
    }).toList();

    final completedCount = updatedWirds.where((w) => w.isCompleted).length;
    final isAllCompleted = completedCount == khatma.totalDays;

    final updatedKhatma = khatma.copyWith(
      wirds: updatedWirds,
      completedWirdsCount: completedCount,
      isCompleted: isAllCompleted,
      completedAt: isAllCompleted ? effectiveDate : null,
    );

    await _localDataSource.saveActiveKhatma(KhatmaModel.fromEntity(updatedKhatma));
    return updatedKhatma;
  }

  @override
  Future<Khatma> completeCurrentWird({DateTime? completionDate}) async {
    final khatma = await getActiveKhatma();
    if (khatma == null) {
      throw const KhatmaException('لا توجد ختمة نشطة لإكمال الورد فيها');
    }
    return completeWird(khatma.currentWird.dayNumber, completionDate: completionDate);
  }

  @override
  Future<Khatma> uncompleteWird(int wirdNumber) async {
    final khatma = await getActiveKhatma();
    if (khatma == null) {
      throw const KhatmaException('لا توجد ختمة نشطة لتعديل الورد فيها');
    }

    final updatedWirds = khatma.wirds.map((w) {
      if (w.dayNumber == wirdNumber) {
        return w.copyWith(
          isCompleted: false,
          clearCompletedAt: true,
        );
      }
      return w;
    }).toList();

    final completedCount = updatedWirds.where((w) => w.isCompleted).length;

    final updatedKhatma = khatma.copyWith(
      wirds: updatedWirds,
      completedWirdsCount: completedCount,
      isCompleted: false,
      clearCompletedAt: true,
    );

    await _localDataSource.saveActiveKhatma(KhatmaModel.fromEntity(updatedKhatma));
    return updatedKhatma;
  }

  @override
  Future<void> deleteKhatma() async {
    await _localDataSource.deleteActiveKhatma();
  }

  @override
  Future<Khatma> updateReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    final khatma = await getActiveKhatma();
    if (khatma == null) {
      throw const KhatmaException('لا توجد ختمة نشطة لتحديث التنبيه لها');
    }

    final updatedKhatma = khatma.copyWith(
      reminderEnabled: enabled,
      reminderTimeHour: hour ?? khatma.reminderTimeHour,
      reminderTimeMinute: minute ?? khatma.reminderTimeMinute,
    );

    await _localDataSource.saveActiveKhatma(KhatmaModel.fromEntity(updatedKhatma));
    return updatedKhatma;
  }
}
