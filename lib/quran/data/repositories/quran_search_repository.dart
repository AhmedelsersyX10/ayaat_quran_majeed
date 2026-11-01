import 'package:quran/quran.dart' as quran;
import 'package:quran/quran_text_normal.dart';
import '../models/quran_search_result.dart';

class QuranSearchRepository {
  List<Map<String, dynamic>>? _cachedIndex;

  /// Initializes the search index by applying normalization to all verses.
  /// This is called once and the result is cached in memory.
  Future<void> init() async {
    if (_cachedIndex != null) return;

    _cachedIndex = quran_text_normal.map((verse) {
      final text = verse['content'] as String;
      return {
        'surah_number': verse['surah_number'] as int,
        'verse_number': verse['verse_number'] as int,
        'searchable_text': normalizeArabicText(text),
        'original_text': quran.getVerse(
          verse['surah_number'] as int,
          verse['verse_number'] as int,
          verseEndSymbol: false,
        ),
      };
    }).toList();
  }

  /// Normalizes Arabic text by removing tashkeel and standardizing specific letters
  /// to make search more robust (handles different Hamza forms, Alif Maqsura, etc.)
  static String normalizeArabicText(String text) {
    return text
        // Remove diacritics (tashkeel)
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        // Normalize Alef (أ إ آ) to bare Alef (ا)
        .replaceAll(RegExp(r'[إأآ]'), 'ا')
        // Normalize Yaa (ي ى) to standard Yaa (ي)
        .replaceAll(RegExp(r'[ى]'), 'ي')
        // Normalize Taa Marbutah (ة) to Haa (ه)
        .replaceAll('ة', 'ه')
        // Remove extra spaces
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  /// Searches the cached index for the given query.
  Future<List<QuranSearchResult>> search(String query) async {
    if (_cachedIndex == null) {
      await init();
    }

    final normalizedQuery = normalizeArabicText(query);
    if (normalizedQuery.isEmpty) return [];

    final queryWords = normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();
    if (queryWords.isEmpty) return [];

    final results = <QuranSearchResult>[];

    for (final verse in _cachedIndex!) {
      final searchableText = verse['searchable_text'] as String;

      // 1. Boolean AND: Must contain all query words
      bool containsAllWords = true;
      for (final word in queryWords) {
        if (!searchableText.contains(word)) {
          containsAllWords = false;
          break;
        }
      }

      if (containsAllWords) {
        int score = 10; // Base score for containing all words

        // 2. Exact phrase match
        if (searchableText.contains(normalizedQuery)) {
          score += 50;

          // 3. Starts with exact phrase
          if (searchableText.startsWith(normalizedQuery)) {
            score += 20;
          }
        }

        // 4. Exact word match (bonus points)
        final verseWords = searchableText.split(' ');
        for (final qWord in queryWords) {
          if (verseWords.contains(qWord)) {
            score += 5;
          }
        }

        final surahNumber = verse['surah_number'] as int;
        final verseNumber = verse['verse_number'] as int;
        
        results.add(
          QuranSearchResult(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            pageNumber: quran.getPageNumber(surahNumber, verseNumber),
            originalText: verse['original_text'] as String,
            surahName: quran.getSurahNameArabic(surahNumber),
            score: score,
          ),
        );
      }
    }

    // Sort results: highest score first, then by Surah, then by Ayah
    results.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;

      final surahComparison = a.surahNumber.compareTo(b.surahNumber);
      if (surahComparison != 0) return surahComparison;

      return a.verseNumber.compareTo(b.verseNumber);
    });

    return results;
  }
}
