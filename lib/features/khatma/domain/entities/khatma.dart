import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'khatma_wird.dart';

/// Aggregate root domain entity for an active Khatma.
///
/// Pure Dart — no Flutter framework dependencies.
class Khatma {
  final String id;
  final String programId;
  final String programTitle;
  final int totalDays;
  final DateTime startDate;
  final List<KhatmaWird> wirds;
  final bool reminderEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;
  final int completedWirdsCount;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Khatma({
    required this.id,
    required this.programId,
    required this.programTitle,
    required this.totalDays,
    required this.startDate,
    required this.wirds,
    this.reminderEnabled = false,
    this.reminderTimeHour = 19,
    this.reminderTimeMinute = 0,
    this.completedWirdsCount = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  /// Returns the current active uncompleted wird.
  /// If all wirds are completed, returns the last wird.
  KhatmaWird get currentWird {
    if (wirds.isEmpty) {
      throw StateError('Khatma contains no wirds.');
    }
    for (final wird in wirds) {
      if (!wird.isCompleted) return wird;
    }
    return wirds.last;
  }

  /// Completion progress ratio from 0.0 to 1.0.
  double get progress => totalDays > 0 ? (completedWirdsCount / totalDays).clamp(0.0, 1.0) : 0.0;

  /// Number of remaining uncompleted days/wirds.
  int get remainingDays => (totalDays - completedWirdsCount).clamp(0, totalDays);

  /// Formatted reminder time in Arabic numerals and markers (e.g. `07:00 م` / `٠٧:٠٠ م`).
  String get formattedReminderTime => formatArabicTime(
        hour: reminderTimeHour,
        minute: reminderTimeMinute,
      );

  Khatma copyWith({
    String? id,
    String? programId,
    String? programTitle,
    int? totalDays,
    DateTime? startDate,
    List<KhatmaWird>? wirds,
    bool? reminderEnabled,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    int? completedWirdsCount,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? createdAt,
  }) {
    return Khatma(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      programTitle: programTitle ?? this.programTitle,
      totalDays: totalDays ?? this.totalDays,
      startDate: startDate ?? this.startDate,
      wirds: wirds ?? this.wirds,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      completedWirdsCount: completedWirdsCount ?? this.completedWirdsCount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Khatma &&
        other.id == id &&
        other.programId == programId &&
        other.programTitle == programTitle &&
        other.totalDays == totalDays &&
        other.startDate == startDate &&
        other.reminderEnabled == reminderEnabled &&
        other.reminderTimeHour == reminderTimeHour &&
        other.reminderTimeMinute == reminderTimeMinute &&
        other.completedWirdsCount == completedWirdsCount &&
        other.isCompleted == isCompleted &&
        other.completedAt == completedAt &&
        other.createdAt == createdAt &&
        _listEquals(other.wirds, wirds);
  }

  static bool _listEquals(List<KhatmaWird> a, List<KhatmaWird> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        programId,
        programTitle,
        totalDays,
        startDate,
        reminderEnabled,
        reminderTimeHour,
        reminderTimeMinute,
        completedWirdsCount,
        isCompleted,
        completedAt,
        createdAt,
      );

  @override
  String toString() => 'Khatma(id: $id, program: $programTitle, progress: $completedWirdsCount/$totalDays)';
}
