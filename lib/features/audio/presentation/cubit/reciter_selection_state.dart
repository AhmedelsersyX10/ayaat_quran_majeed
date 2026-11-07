import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';

/// States for the Reciter Selection sheet matching reference 18.
abstract class ReciterSelectionState {
  const ReciterSelectionState();
}

/// Initial uninitialized state.
class ReciterSelectionInitial extends ReciterSelectionState {
  const ReciterSelectionInitial();
}

/// Loading state while fetching and verifying reciters.
class ReciterSelectionLoading extends ReciterSelectionState {
  const ReciterSelectionLoading();
}

/// Success state with qualified reciters (meeting timing policy) and current selection.
class ReciterSelectionSuccess extends ReciterSelectionState {
  final List<Reciter> reciters;
  final Reciter selectedReciter;
  final Moshaf selectedMoshaf;

  const ReciterSelectionSuccess({
    required this.reciters,
    required this.selectedReciter,
    required this.selectedMoshaf,
  });

  ReciterSelectionSuccess copyWith({
    List<Reciter>? reciters,
    Reciter? selectedReciter,
    Moshaf? selectedMoshaf,
  }) {
    return ReciterSelectionSuccess(
      reciters: reciters ?? this.reciters,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      selectedMoshaf: selectedMoshaf ?? this.selectedMoshaf,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterSelectionSuccess &&
          runtimeType == other.runtimeType &&
          selectedReciter == other.selectedReciter &&
          selectedMoshaf == other.selectedMoshaf &&
          _listEquals(reciters, other.reciters);

  @override
  int get hashCode => Object.hash(
        selectedReciter,
        selectedMoshaf,
        Object.hashAll(reciters),
      );

  static bool _listEquals(List<Reciter> a, List<Reciter> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Empty state when no qualified reciters are available.
class ReciterSelectionEmpty extends ReciterSelectionState {
  const ReciterSelectionEmpty();
}

/// Failure state when an error occurs during loading or persistence.
class ReciterSelectionFailure extends ReciterSelectionState {
  final String message;

  const ReciterSelectionFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterSelectionFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
