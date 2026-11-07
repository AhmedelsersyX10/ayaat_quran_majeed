import '../../domain/entities/ayah_timing.dart';

/// Data model for ayah timing interval JSON serialization.
///
/// Maps response from `https://www.mp3quran.net/api/v3/ayat_timing`.
class AyahTimingModel {
  final int ayah;
  final int startTime;
  final int endTime;

  const AyahTimingModel({
    required this.ayah,
    required this.startTime,
    required this.endTime,
  });

  factory AyahTimingModel.fromJson(Map<String, dynamic> json) {
    return AyahTimingModel(
      ayah: _parseInt(json['ayah']),
      startTime: _parseInt(json['start_time']),
      endTime: _parseInt(json['end_time']),
    );
  }

  factory AyahTimingModel.fromEntity(AyahTiming entity) {
    return AyahTimingModel(
      ayah: entity.ayah,
      startTime: entity.startTimeMs,
      endTime: entity.endTimeMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah': ayah,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  AyahTiming toEntity() {
    return AyahTiming(
      ayah: ayah,
      startTimeMs: startTime,
      endTimeMs: endTime,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
