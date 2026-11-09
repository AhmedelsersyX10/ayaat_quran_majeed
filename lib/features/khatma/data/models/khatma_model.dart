import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

import 'khatma_wird_model.dart';

/// Serializable data model for the active Khatma aggregate root.
class KhatmaModel {
  final String id;
  final String programId;
  final String programTitle;
  final int totalDays;
  final DateTime startDate;
  final List<KhatmaWirdModel> wirds;
  final bool reminderEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;
  final int completedWirdsCount;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const KhatmaModel({
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

  factory KhatmaModel.fromEntity(Khatma entity) {
    return KhatmaModel(
      id: entity.id,
      programId: entity.programId,
      programTitle: entity.programTitle,
      totalDays: entity.totalDays,
      startDate: entity.startDate,
      wirds: entity.wirds.map((w) => KhatmaWirdModel.fromEntity(w)).toList(),
      reminderEnabled: entity.reminderEnabled,
      reminderTimeHour: entity.reminderTimeHour,
      reminderTimeMinute: entity.reminderTimeMinute,
      completedWirdsCount: entity.completedWirdsCount,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
    );
  }

  factory KhatmaModel.fromMap(Map<dynamic, dynamic> map) {
    final rawWirds = map['wirds'] as List<dynamic>? ?? [];
    final parsedWirds = rawWirds
        .map((w) => KhatmaWirdModel.fromMap(w as Map<dynamic, dynamic>))
        .toList();

    return KhatmaModel(
      id: map['id'] as String,
      programId: map['programId'] as String,
      programTitle: map['programTitle'] as String,
      totalDays: map['totalDays'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      wirds: parsedWirds,
      reminderEnabled: (map['reminderEnabled'] ?? false) as bool,
      reminderTimeHour: (map['reminderTimeHour'] ?? 19) as int,
      reminderTimeMinute: (map['reminderTimeMinute'] ?? 0) as int,
      completedWirdsCount: (map['completedWirdsCount'] ?? 0) as int,
      isCompleted: (map['isCompleted'] ?? false) as bool,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'programId': programId,
      'programTitle': programTitle,
      'totalDays': totalDays,
      'startDate': startDate.toIso8601String(),
      'wirds': wirds.map((w) => w.toMap()).toList(),
      'reminderEnabled': reminderEnabled,
      'reminderTimeHour': reminderTimeHour,
      'reminderTimeMinute': reminderTimeMinute,
      'completedWirdsCount': completedWirdsCount,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Khatma toEntity(QuranMetadataService metadataService) {
    return Khatma(
      id: id,
      programId: programId,
      programTitle: programTitle,
      totalDays: totalDays,
      startDate: startDate,
      wirds: wirds.map((w) => w.toEntity(metadataService)).toList(),
      reminderEnabled: reminderEnabled,
      reminderTimeHour: reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute,
      completedWirdsCount: completedWirdsCount,
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }
}

