import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';

/// Sealed base state for Khatma feature.
sealed class KhatmaState {
  const KhatmaState();
}

/// Initial state before active khatma is checked or loaded.
class KhatmaInitial extends KhatmaState {
  const KhatmaInitial();
}

/// State emitted while loading active khatma or executing an asynchronous operation.
class KhatmaLoading extends KhatmaState {
  const KhatmaLoading();
}

/// State emitted when there is no active Khatma.
/// Matches reference screenshot 10 (Empty State).
class KhatmaEmpty extends KhatmaState {
  const KhatmaEmpty();
}

/// Enum representing sequential steps in the new Khatma setup wizard.
enum KhatmaCreationStep {
  /// Reference 06: New Khatma Menu (suggested / other)
  menu,

  /// Reference 07: Starting point selection (beginning / custom wird)
  startFrom,

  /// Reference 08: Specific wird selection list
  selectWird,

  /// Reference 09 / 14 / 32: Program duration pickers
  programPicker,
}

/// State emitted during the interactive Khatma creation wizard (References 06, 07, 08, 09, 14).
///
/// Holds in-memory choices without persisting them to storage until the user completes the flow.
class KhatmaCreating extends KhatmaState {
  final KhatmaCreationStep step;
  final KhatmaProgram? selectedProgram;
  final KhatmaProgramCategory? customProgramCategory;
  final int startWirdNumber;

  const KhatmaCreating({
    this.step = KhatmaCreationStep.menu,
    this.selectedProgram,
    this.customProgramCategory,
    this.startWirdNumber = 1,
  });

  KhatmaCreating copyWith({
    KhatmaCreationStep? step,
    KhatmaProgram? selectedProgram,
    KhatmaProgramCategory? customProgramCategory,
    int? startWirdNumber,
  }) {
    return KhatmaCreating(
      step: step ?? this.step,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      customProgramCategory: customProgramCategory ?? this.customProgramCategory,
      startWirdNumber: startWirdNumber ?? this.startWirdNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhatmaCreating &&
        other.step == step &&
        other.selectedProgram == selectedProgram &&
        other.customProgramCategory == customProgramCategory &&
        other.startWirdNumber == startWirdNumber;
  }

  @override
  int get hashCode => Object.hash(
        step,
        selectedProgram,
        customProgramCategory,
        startWirdNumber,
      );

  @override
  String toString() =>
      'KhatmaCreating(step: $step, program: ${selectedProgram?.id}, category: $customProgramCategory, startWird: $startWirdNumber)';
}

/// State emitted when an active Khatma exists.
/// Matches reference screenshots 26 and 31.
class KhatmaLoaded extends KhatmaState {
  final Khatma khatma;
  final KhatmaWird currentWird;
  final String relativeDayLabel;
  final bool justCompletedWird;
  final bool permissionDeniedNotice;

  const KhatmaLoaded({
    required this.khatma,
    required this.currentWird,
    required this.relativeDayLabel,
    this.justCompletedWird = false,
    this.permissionDeniedNotice = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhatmaLoaded &&
        other.khatma == khatma &&
        other.currentWird == currentWird &&
        other.relativeDayLabel == relativeDayLabel &&
        other.justCompletedWird == justCompletedWird &&
        other.permissionDeniedNotice == permissionDeniedNotice;
  }

  @override
  int get hashCode => Object.hash(
        khatma,
        currentWird,
        relativeDayLabel,
        justCompletedWird,
        permissionDeniedNotice,
      );

  @override
  String toString() =>
      'KhatmaLoaded(day: ${currentWird.dayNumber}, label: $relativeDayLabel, justCompleted: $justCompletedWird, permissionDenied: $permissionDeniedNotice)';
}

/// State emitted when a Khatma operation encounters an error.
class KhatmaFailure extends KhatmaState {
  final String message;

  const KhatmaFailure(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhatmaFailure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'KhatmaFailure(message: $message)';
}

