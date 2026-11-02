import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import '../models/quran_search_result.dart';

class QuranSearchRepository {
  final QuranMetadataService _metadataService;
  List<Map<String, dynamic>>? _cachedIndex;

  QuranSearchRepository({
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) : _metadataService = metadataService;

  /// Initializes the search index by applying normalization to all verses.
  /// This is called once and the result is cached in memory.
  Future<void> init() async {
    if (_cachedIndex != null) return;

    _cachedIndex = _metadataService.allVersesRawData.map((verse) {
      final emlaey = (verse['aya_text_emlaey'] ?? '').toString();
      final surahNumber = verse['sora'] as int;
      final verseNumber = verse['aya_no'] as int;
      final originalText = (verse['aya_text'] ?? '').toString().replaceAll('۩', '').trim();

      return {
        'surah_number': surahNumber,
        'verse_number': verseNumber,
        'searchable_text': normalizeArabicText(emlaey),
        'original_text': originalText,
      };
    }).toList();
  }

  /// Normalizes Arabic text by removing tashkeel and standardizing specific letters
  /// to make search more robust (handles different Hamza forms, Alif Maqsura, etc.)
  static String normalizeArabicText(String text) {
    return text
        // Remove diacritics (tashkeel) and Quranic annotation marks
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        // Normalize Alef (أ إ آ ٱ) to bare Alef (ا)
        .replaceAll(RegExp(r'[إأآٱ\u0671]'), 'ا')
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
            pageNumber: _metadataService.getPageNumber(surahNumber, verseNumber),
            originalText: verse['original_text'] as String,
            surahName: _metadataService.getSurahNameArabic(surahNumber),
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
