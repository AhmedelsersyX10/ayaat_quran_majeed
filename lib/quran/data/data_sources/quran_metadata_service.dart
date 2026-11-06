import 'package:qcf_quran_plus/qcf_quran_plus.dart' as qp;
// ignore: implementation_imports
import 'package:qcf_quran_plus/src/data/quran_data.dart' as qd;

/// Central service providing Quran text, metadata, page mappings,
/// and helper methods by wrapping `qcf_quran_plus`.
///
/// This isolates the rest of the application from directly importing
/// the Quran engine library.
class QuranMetadataService {
  const QuranMetadataService();

  /// Raw verse metadata list from Quran dataset.
  List<Map<String, dynamic>> get allVersesRawData =>
      List<Map<String, dynamic>>.from(qd.quran);

  /// Total number of pages in the Madani Mushaf layout.
  int get totalPagesCount => qp.totalPagesCount;

  /// Total number of Surahs in the Quran.
  int get totalSurahCount => qp.totalSurahCount;

  /// Total number of Juz in the Quran.
  int get totalJuzCount => qp.totalJuzCount;

  /// Retrieves the raw page data mapping for a specific [pageNumber] (1 to 604).
  /// Returns a list of segments containing `surah`, `start`, and `end`.
  List<dynamic> getPageData(int pageNumber) {
    return qp.getPageData(pageNumber);
  }

  /// Returns the Mushaf page number (1-604) where [surahNumber] and [ayahNumber] reside.
  int getPageNumber(int surahNumber, int ayahNumber) {
    return qp.getPageNumber(surahNumber, ayahNumber);
  }

  /// Returns the Juz number (1-30) for [surahNumber] and [ayahNumber].
  int getJuzNumber(int surahNumber, int ayahNumber) {
    return qp.getJuzNumber(surahNumber, ayahNumber);
  }

  /// Returns the total verse count for [surahNumber] (1-114).
  int getVerseCount(int surahNumber) {
    return qp.getVerseCount(surahNumber);
  }

  /// Returns the Arabic name of the Surah (e.g. "الفَاتِحة").
  String getSurahNameArabic(int surahNumber) {
    return qp.getSurahNameArabic(surahNumber);
  }

  /// Returns the Hizb/Quarter text if a new quarter starts exactly on [pageNumber];
  /// returns an empty string otherwise.
  String getHizbTextByPage(int pageNumber, {bool isArabic = true}) {
    return qp.getHizbTextByPage(pageNumber, isArabic: isArabic);
  }

  /// Returns the Arabic ordinal name for [juzNumber] (e.g. "الأول" for 1).
  String getJuzNameArabic(int juzNumber) {
    const arabicOrdinals = [
      'الأول',
      'الثاني',
      'الثالث',
      'الرابع',
      'الخامس',
      'السادس',
      'السابع',
      'الثامن',
      'التاسع',
      'العاشر',
      'الحادي عشر',
      'الثاني عشر',
      'الثالث عشر',
      'الرابع عشر',
      'الخامس عشر',
      'السادس عشر',
      'السابع عشر',
      'الثامن عشر',
      'التاسع عشر',
      'العشرون',
      'الحادي والعشرون',
      'الثاني والعشرون',
      'الثالث والعشرون',
      'الرابع والعشرون',
      'الخامس والعشرون',
      'السادس والعشرون',
      'السابع والعشرون',
      'الثامن والعشرون',
      'التاسع والعشرون',
      'الثلاثون',
    ];

    if (juzNumber >= 1 && juzNumber <= 30) {
      return arabicOrdinals[juzNumber - 1];
    }
    return juzNumber.toString();
  }

  /// Returns the Juz number for the beginning of [pageNumber].
  int getJuzNumberForPage(int pageNumber) {
    final pageData = getPageData(pageNumber);
    if (pageData.isEmpty) return 1;
    final first = pageData[0];
    return getJuzNumber(first['surah'] as int, first['start'] as int);
  }

  /// Returns the Arabic name of the first Surah appearing on [pageNumber].
  String getSurahNameArabicForPage(int pageNumber) {
    final pageData = getPageData(pageNumber);
    if (pageData.isEmpty) return '';
    final first = pageData[0];
    return getSurahNameArabic(first['surah'] as int);
  }

  /// Returns the transliterated name of the Surah (e.g. "Al-Fatihah").
  String getSurahName(int surahNumber) {
    return qp.getSurahName(surahNumber);
  }

  /// Returns the English translated name of the Surah.
  String getSurahNameEnglish(int surahNumber) {
    return qp.getSurahNameEnglish(surahNumber);
  }

  /// Returns the plain Arabic text of a specific verse.
  String getVerse(int surahNumber, int ayahNumber, {bool verseEndSymbol = false}) {
    return qp.getVerse(surahNumber, ayahNumber, verseEndSymbol: verseEndSymbol);
  }

  /// Returns the verse-end symbol with the ayah number enclosed.
  String getVerseEndSymbol(int ayahNumber, {bool arabicNumeral = true}) {
    return qp.getVerseEndSymbol(ayahNumber, arabicNumeral: arabicNumeral);
  }

  /// Returns the specific QCF glyph data for a verse.
  String getVerseQCF(int surahNumber, int ayahNumber) {
    for (final item in qd.quran) {
      if (item['sora'] == surahNumber && item['aya_no'] == ayahNumber) {
        return (item['qcfData'] ?? '').toString();
      }
    }
    return '';
  }

  /// Returns the QCF glyph representing the verse end number.
  String getAyaNoQCF(int surahNumber, int ayahNumber) {
    return qp.getAyaNoQCF(surahNumber, ayahNumber);
  }

  /// Removes basic Arabic diacritics (tashkeel) from the input text.
  String removeDiacritics(String input) {
    return qp.removeDiacritics(input);
  }

  /// Returns `true` if [surahNumber] was revealed in Makkah (Makki),
  /// and `false` if revealed in Madinah (Madani).
  bool isMakki(int surahNumber) {
    return qp.getPlaceOfRevelation(surahNumber).toLowerCase() == 'makkah';
  }

  /// Returns the starting page number (1-604) for [juzNumber] (1-30).
  int getJuzStartPage(int juzNumber) {
    if (juzNumber < 1 || juzNumber > 30) {
      throw ArgumentError.value(juzNumber, 'juzNumber', 'Must be between 1 and 30');
    }
    final versesMap = getSurahAndVersesFromJuz(juzNumber);
    final firstSurah = versesMap.keys.first;
    final firstAyah = versesMap[firstSurah]!.first;
    return getPageNumber(firstSurah, firstAyah);
  }

  /// Returns the surahs and their ayah ranges for a given [juzNumber] (1-30).
  ///
  /// Maps each surah number to a 2-element list `[startAyah, endAyah]`.
  Map<int, List<int>> getSurahAndVersesFromJuz(int juzNumber) {
    if (juzNumber < 1 || juzNumber > 30) {
      throw ArgumentError.value(juzNumber, 'juzNumber', 'Must be between 1 and 30');
    }
    final raw = qp.juz[juzNumber - 1]['verses'] as Map<dynamic, dynamic>;
    return raw.map((key, value) => MapEntry(
          key as int,
          (value as List<dynamic>).cast<int>(),
        ));
  }

  /// Converts a [surahNumber] and [verseNumber] into an audio URL for [reciterIdentifier].
  ///
  /// Uses the Islamic Network CDN verse-by-verse endpoint with the absolute ayah index.
  String getAudioURLByVerse(int surahNumber, int verseNumber, String reciterIdentifier) {
    int absoluteIndex = 1;
    for (final item in qd.quran) {
      if (item['sora'] == surahNumber && item['aya_no'] == verseNumber) {
        final id = item['id'];
        if (id is int) {
          absoluteIndex = id;
        } else if (id != null) {
          absoluteIndex = int.tryParse(id.toString()) ?? 1;
        }
        break;
      }
    }

    const highBitrateReciters = {
      'ar.parhizgar',
      'ar.muhammadjibreel',
      'ar.muhammadayyoub',
      'ar.ibrahimakhbar',
      'ar.minshawi',
    };

    final bitrate = highBitrateReciters.contains(reciterIdentifier) ? 128 : 64;
    return 'https://cdn.islamic.network/quran/audio/$bitrate/$reciterIdentifier/$absoluteIndex.mp3';
  }

  /// Default reciters list for audio playback.
  List<Map<String, dynamic>> get reciters => const [
        {
          'identifier': 'ar.abdulbasitmurattal',
          'language': 'ar',
          'name': 'عبد الباسط عبد الصمد المرتل',
          'englishName': 'Abdul Basit (muratal)',
          'format': 'audio',
          'type': 'translation',
        },
        {
          'identifier': 'ar.abdulsamad',
          'language': 'ar',
          'name': 'عبدالباسط عبدالصمد',
          'englishName': 'Abdul Basit (Mujawwad)',
          'format': 'audio',
          'type': 'versebyverse',
        },
        {
          'identifier': 'ar.abdullahbasfar',
          'language': 'ar',
          'name': 'عبد الله بصفر',
          'englishName': 'Abdullah Basfar',
          'format': 'audio',
          'type': 'versebyverse',
        },
        {
          'identifier': 'ar.minshawi',
          'language': 'ar',
          'name': 'محمد صديق المنشاوي',
          'englishName': 'Minshawi',
          'format': 'audio',
          'type': 'translation',
        },
        {
          'identifier': 'ar.alafasy',
          'language': 'ar',
          'name': 'مشاري العفاسي',
          'englishName': 'Mishary Rashid Alafasy',
          'format': 'audio',
          'type': 'versebyverse',
        },
        {
          'identifier': 'ar.husary',
          'language': 'ar',
          'name': 'محمود خليل الحصري',
          'englishName': 'Mahmoud Khalil Al-Husary',
          'format': 'audio',
          'type': 'versebyverse',
        },
        {
          'identifier': 'ar.hudhaify',
          'language': 'ar',
          'name': 'علي بن عبد الرحمن الحذيفي',
          'englishName': 'Ali Al-Hudhaify',
          'format': 'audio',
          'type': 'versebyverse',
        },
      ];

  /// Find a reciter map by [identifier].
  Map<String, dynamic>? getReciter(String identifier) {
    for (final r in reciters) {
      if (r['identifier'] == identifier) {
        return r;
      }
    }
    return null;
  }
}
