import '../entities/khatma.dart';
import '../entities/khatma_program.dart';

/// Domain repository contract for managing the single active Khatma.
///
/// Pure Dart — no Flutter framework dependencies.
abstract class KhatmaRepository {
  /// Retrieves the single active Khatma, or null if none exists.
  Future<Khatma?> getActiveKhatma();

  /// Creates and persists a new active Khatma.
  /// Overwrites any previous active Khatma (single active khatma rule).
  Future<Khatma> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  });

  /// Marks a specific wird by [wirdNumber] as completed.
  /// If this was the last uncompleted wird, marks the entire khatma as completed.
  Future<Khatma> completeWird(int wirdNumber, {DateTime? completionDate});

  /// Marks the current active uncompleted wird as completed.
  Future<Khatma> completeCurrentWird({DateTime? completionDate});

  /// Marks a specific wird by [wirdNumber] as uncompleted (reverting progress).
  Future<Khatma> uncompleteWird(int wirdNumber);

  /// Deletes the active Khatma.
  Future<void> deleteKhatma();

  /// Updates the daily reminder notification switch and/or scheduled time.
  Future<Khatma> updateReminder({
    required bool enabled,
    int? hour,
    int? minute,
  });
}

