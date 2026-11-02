// ignore_for_file: file_names

import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';

initHiveValues() async {
  nullValidator("headerPhotoIndex", 0);
  nullValidator("quranPageolorsIndex", 0);
  nullValidator("selectedFontFamily", "AmiriQuran");

  nullValidator("pageViewFontSize", 23);
  nullValidator("verseByVerseFontSize", 24);
  nullValidator("verticalViewFontSize", 22);

  nullValidator("currentHeight", 2.0);
  nullValidator("currentLetterSpacing", 0.0);
  nullValidator("lastRead", "non");
  nullValidator("alignmentType", "pageview");
  nullValidator("addAppSlogan", true);
  nullValidator("showSuraHeader", true);
  nullValidator("textWithoutDiacritics", false);
  nullValidator("selectedShareTypeIndex", 0);
  nullValidator("showTafseerOrTranslation", true);
  nullValidator("translationName", "enSaheeh");
  nullValidator("reciterIndex", 0);
  nullValidator("favoriteRecitersList", "[]");
  nullValidator("favoriteSurahList", "[]");
  nullValidator("downloadedSurahs", "[]");

  nullValidator("addTafseerValue", 0);
  nullValidator("addTafseer", false);
  nullValidator("showBottomBar", false);

  nullValidator("indexOfTranslation", 0);
  nullValidator("indexOfTranslationInVerseByVerse", 1);
  nullValidator("darkMode", false);

  nullValidator("bookmarks", "[]");

  nullValidator("timesOfAppOpen", 0);
  nullValidator("showedDialog", false);
}
