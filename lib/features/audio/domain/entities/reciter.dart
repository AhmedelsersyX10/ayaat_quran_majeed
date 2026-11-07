import 'moshaf.dart';

/// Represents a Quran reciter (Qari) from mp3quran.net.
///
/// Pure Dart — no Flutter framework dependencies.
class Reciter {
  /// Unique reciter identifier.
  final int id;

  /// Reciter display name in Arabic (e.g. "محمود خليل الحصري").
  final String name;

  /// Alphabetical grouping letter in Arabic (e.g. "م", "أ").
  final String letter;

  /// Available moshaf editions recorded by this reciter.
  final List<Moshaf> moshafs;

  const Reciter({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshafs,
  });

  /// Whether at least one moshaf edition for this reciter has verified timing support.
  bool get hasAnyTimingSupport => moshafs.any((m) => m.hasTiming);

  /// List of moshaf editions for this reciter that have verified ayah timing support.
  List<Moshaf> get qualifiedMoshafs =>
      moshafs.where((m) => m.hasTiming).toList();

  /// Default moshaf edition for this reciter.
  ///
  /// Prioritizes the first edition with verified timing support; falls back
  /// to the first available edition if none have timing.
  Moshaf? get defaultMoshaf {
    if (moshafs.isEmpty) return null;
    for (final m in moshafs) {
      if (m.hasTiming) return m;
    }
    return moshafs.first;
  }

  Reciter copyWith({
    int? id,
    String? name,
    String? letter,
    List<Moshaf>? moshafs,
  }) {
    return Reciter(
      id: id ?? this.id,
      name: name ?? this.name,
      letter: letter ?? this.letter,
      moshafs: moshafs ?? this.moshafs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reciter &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          letter == other.letter &&
          _listEquals(moshafs, other.moshafs);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        letter,
        Object.hashAll(moshafs),
      );

  static bool _listEquals(List<Moshaf> a, List<Moshaf> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'Reciter(id: $id, name: $name, moshafs: ${moshafs.length})';
}
