import '../../domain/entities/moshaf.dart';

/// Data model for Moshaf edition JSON serialization.
class MoshafModel {
  final int id;
  final String name;
  final String server;
  final int surahTotal;
  final int moshafType;
  final List<int> surahList;

  const MoshafModel({
    required this.id,
    required this.name,
    required this.server,
    required this.surahTotal,
    required this.moshafType,
    required this.surahList,
  });

  factory MoshafModel.fromJson(Map<String, dynamic> json) {
    return MoshafModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      server: json['server']?.toString() ?? '',
      surahTotal: _parseInt(json['surah_total'], defaultValue: 114),
      moshafType: _parseInt(json['moshaf_type']),
      surahList: _parseSurahList(json['surah_list']),
    );
  }

  factory MoshafModel.fromEntity(Moshaf entity) {
    return MoshafModel(
      id: entity.id,
      name: entity.name,
      server: entity.server,
      surahTotal: entity.surahTotal,
      moshafType: entity.moshafType,
      surahList: entity.surahList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'server': server,
      'surah_total': surahTotal,
      'moshaf_type': moshafType,
      'surah_list': surahList.join(','),
    };
  }

  Moshaf toEntity({bool hasTiming = false}) {
    return Moshaf(
      id: id,
      name: name,
      server: server,
      surahTotal: surahTotal,
      moshafType: moshafType,
      surahList: surahList,
      hasTiming: hasTiming,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static List<int> _parseSurahList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => _parseInt(e))
          .where((e) => e >= 1 && e <= 114)
          .toList();
    }
    if (value is String) {
      if (value.trim().isEmpty) return const [];
      return value
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .where((e) => e >= 1 && e <= 114)
          .toList();
    }
    return const [];
  }
}
