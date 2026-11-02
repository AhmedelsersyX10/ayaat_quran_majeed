import 'package:ayaat_quran_majeed/GlobalHelpers/arabic_text_helper.dart';
import 'package:ayaat_quran_majeed/quran/data/models/mushaf_entity.dart';
import 'package:azlistview/azlistview.dart';

class ReciterEntity extends ISuspensionBean {
  final dynamic id;
  final dynamic name;
  final dynamic letter;
  final List<MushafEntity> mushafs;

  ReciterEntity({
    required this.id,
    required this.name,
    required this.letter,
    required this.mushafs,
  });

  @override
  String getSuspensionTag() {
    return normalizeArabic(letter.toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
