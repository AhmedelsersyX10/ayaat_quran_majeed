import 'dart:convert';
import 'dart:io';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translation_info.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translations/muyassar.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translations/sahih_english.dart';
import 'package:path_provider/path_provider.dart';

const _metadataService = QuranMetadataService();

String getVerseTranslationForVerseByVerse(
    var data, int surahNumber, int verseNumber, TranslationData translation,
    {bool verseEndSymbol = false}) {
  List<dynamic> translationDataList = [];
  if (translation.typeAsEnumValue == Translation.ar_muyassar) {
    translationDataList = muyassar;
  } else if (translation.typeAsEnumValue == Translation.en_sahih) {
    translationDataList = en_sahih;
  } else {
    // File file = File("${appDir.path}/${translation.typeText}.json");

    // String jsonData = await file.readAsString();
    // translationDataList = json.decode(jsonData);
    if (data == null) return "";
    translationDataList = data;
  }
  String verse = "";
  for (var item in translationDataList) {
    if (item['sura'].toString() == surahNumber.toString() &&
        item['aya'].toString() == verseNumber.toString()) {
      verse = item['text'];
      break;
    }
  }

  if (verse == "") {
    return "";
  }
  print(verse);
  return verse.replaceAll("<br>", "\n") +
      (verseEndSymbol ? _metadataService.getVerseEndSymbol(verseNumber, arabicNumeral: false) : "");
}

Future<String> getVerseTranslation(int surahNumber, int verseNumber, TranslationData translation,
    {bool verseEndSymbol = false}) async {
  List<dynamic> translationDataList = [];
  Directory appDir = await getTemporaryDirectory();
  if (translation.typeAsEnumValue == Translation.ar_muyassar) {
    translationDataList = muyassar;
  } else if (translation.typeAsEnumValue == Translation.en_sahih) {
    translationDataList = en_sahih;
  } else {
    File file = File("${appDir.path}/${translation.typeText}.json");

    String jsonData = await file.readAsString();
    translationDataList = json.decode(jsonData);
  }
  String verse = "";
  for (var item in translationDataList) {
    if (item['sura'].toString() == surahNumber.toString() &&
        item['aya'].toString() == verseNumber.toString()) {
      verse = item['text'];
      break;
    }
  }

  if (verse == "") {
    return "";
  }
  return verse + (verseEndSymbol ? _metadataService.getVerseEndSymbol(verseNumber, arabicNumeral: false) : "");
}
