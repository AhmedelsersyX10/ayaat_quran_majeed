import '../../domain/entities/reciter.dart';
import 'moshaf_model.dart';

/// Data model for Reciter JSON serialization.
///
/// Maps response from `https://www.mp3quran.net/api/v3/reciters?language=ar`.
class ReciterModel {
  final int id;
  final String name;
  final String letter;
  final List<MoshafModel> moshafs;

  const ReciterModel({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshafs,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    final rawMoshafs = json['moshaf'] as List<dynamic>? ?? const [];
    
    // Parse moshafs and filter out any audio-tafsir / "المختصر الصوتي" per owner binding rules
    final parsedMoshafs = rawMoshafs
        .map((m) => MoshafModel.fromJson(m as Map<String, dynamic>))
        .where((m) => !_isAudioTafsir(m.name))
        .toList();

    return ReciterModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      letter: json['letter']?.toString() ?? '',
      moshafs: parsedMoshafs,
    );
  }

  factory ReciterModel.fromEntity(Reciter entity) {
    return ReciterModel(
      id: entity.id,
      name: entity.name,
      letter: entity.letter,
      moshafs: entity.moshafs.map((m) => MoshafModel.fromEntity(m)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'letter': letter,
      'moshaf': moshafs.map((m) => m.toJson()).toList(),
    };
  }

  Reciter toEntity({Set<int>? timingSupportedMoshafIds}) {
    return Reciter(
      id: id,
      name: name,
      letter: letter,
      moshafs: moshafs
          .map((m) => m.toEntity(
                hasTiming: timingSupportedMoshafIds?.contains(m.id) ?? false,
              ))
          .toList(),
    );
  }

  /// Checks if a moshaf name designates an audio-tafsir track (e.g. المختصر الصوتي).
  static bool _isAudioTafsir(String name) {
    final lower = name.toLowerCase();
    return lower.contains('المختصر الصوتي') ||
        lower.contains('مختصر تفسير') ||
        lower.contains('تفسير صوتي');
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
