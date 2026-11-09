import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
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

/// State emitted when an active Khatma exists.
/// Matches reference screenshots 26 and 31.
class KhatmaLoaded extends KhatmaState {
  final Khatma khatma;
  final KhatmaWird currentWird;
  final String relativeDayLabel;
  final bool justCompletedWird;

  const KhatmaLoaded({
    required this.khatma,
    required this.currentWird,
    required this.relativeDayLabel,
    this.justCompletedWird = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhatmaLoaded &&
        other.khatma == khatma &&
        other.currentWird == currentWird &&
        other.relativeDayLabel == relativeDayLabel &&
        other.justCompletedWird == justCompletedWird;
  }

  @override
  int get hashCode => Object.hash(
        khatma,
        currentWird,
        relativeDayLabel,
        justCompletedWird,
      );

  @override
  String toString() =>
      'KhatmaLoaded(day: ${currentWird.dayNumber}, label: $relativeDayLabel, justCompleted: $justCompletedWird)';
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

