import 'package:ayaat_quran_majeed/GlobalHelpers/arabic_text_helper.dart';
import 'package:ayaat_quran_majeed/quran/data/models/mushaf_model.dart';
import 'package:ayaat_quran_majeed/quran/data/models/reciter_entity.dart';

class ReciterModel extends ReciterEntity {
  ReciterModel({
    required super.id,
    required super.name,
    required super.letter,
    required super.mushafs,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    final rawLetter = json['letter']?.toString() ?? '';
    final normalizedLetter = normalizeArabic(rawLetter);

    return ReciterModel(
      id: json['id'],
      name: json['name'],
      letter: normalizedLetter.isNotEmpty ? normalizedLetter : json['letter'],
      mushafs:
          (json['moshaf'] as List<dynamic>).map((moshaf) => MushafModel.fromJson(moshaf)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'letter': letter,
      'moshaf': mushafs.map((m) => (m as MushafModel).toJson()).toList(),
    };
  }
}
