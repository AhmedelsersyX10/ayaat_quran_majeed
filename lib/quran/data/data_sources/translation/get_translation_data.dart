import 'dart:convert';
import 'dart:io';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translation_info.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translations/muyassar.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translations/sahih_english.dart';
import 'package:path_provider/path_provider.dart';

const _metadataService = QuranMetadataService();

Map<int, String>? _muyassarMap;
Map<int, String>? _enSahihMap;

int _key(int surah, int ayah) => (surah << 16) | ayah;

Map<int, String> _buildTranslationMap(List list) {
  final map = <int, String>{};
  for (final item in list) {
    if (item is Map) {
      final sura = int.tryParse(item['sura'].toString());
      final aya = int.tryParse(item['aya'].toString());
      final text = item['text']?.toString() ?? '';
      if (sura != null && aya != null) {
        map[_key(sura, aya)] = text;
      }
    }
  }
  return map;
}

Map<int, String> get _cachedMuyassarMap =>
    _muyassarMap ??= _buildTranslationMap(muyassar);

Map<int, String> get _cachedEnSahihMap =>
    _enSahihMap ??= _buildTranslationMap(en_sahih);

String getVerseTranslationForVerseByVerse(
  dynamic data,
  int surahNumber,
  int verseNumber,
  TranslationData translation, {
  bool verseEndSymbol = false,
}) {
  String verse = "";
  if (translation.typeAsEnumValue == Translation.ar_muyassar) {
    verse = _cachedMuyassarMap[_key(surahNumber, verseNumber)] ?? "";
  } else if (translation.typeAsEnumValue == Translation.en_sahih) {
    verse = _cachedEnSahihMap[_key(surahNumber, verseNumber)] ?? "";
  } else if (data is List) {
    final suraStr = surahNumber.toString();
    final ayaStr = verseNumber.toString();
    for (final item in data) {
      if (item is Map &&
          item['sura'].toString() == suraStr &&
          item['aya'].toString() == ayaStr) {
        verse = item['text']?.toString() ?? '';
        break;
      }
    }
  }

  if (verse.isEmpty) {
    return "";
  }
  return verse.replaceAll("<br>", "\n") +
      (verseEndSymbol
          ? _metadataService.getVerseEndSymbol(
              verseNumber,
              arabicNumeral: false,
            )
          : "");
}

Future<String> getVerseTranslation(
  int surahNumber,
  int verseNumber,
  TranslationData translation, {
  bool verseEndSymbol = false,
}) async {
  String verse = "";
  if (translation.typeAsEnumValue == Translation.ar_muyassar) {
    verse = _cachedMuyassarMap[_key(surahNumber, verseNumber)] ?? "";
  } else if (translation.typeAsEnumValue == Translation.en_sahih) {
    verse = _cachedEnSahihMap[_key(surahNumber, verseNumber)] ?? "";
  } else {
    final Directory appDir = await getTemporaryDirectory();
    final File file = File("${appDir.path}/${translation.typeText}.json");
    if (await file.exists()) {
      final String jsonData = await file.readAsString();
      final List<dynamic> translationDataList = json.decode(jsonData);
      final suraStr = surahNumber.toString();
      final ayaStr = verseNumber.toString();
      for (final item in translationDataList) {
        if (item is Map &&
            item['sura'].toString() == suraStr &&
            item['aya'].toString() == ayaStr) {
          verse = item['text']?.toString() ?? '';
          break;
        }
      }
    }
  }

  if (verse.isEmpty) {
    return "";
  }
  return verse +
      (verseEndSymbol
          ? _metadataService.getVerseEndSymbol(
              verseNumber,
              arabicNumeral: false,
            )
          : "");
}
