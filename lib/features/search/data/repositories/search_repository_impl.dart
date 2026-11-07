import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/page_search_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/search_query_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/verse_search_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Clean Architecture Data implementation of [SearchRepository].
class SearchRepositoryImpl implements SearchRepository {
  final QuranMetadataService _metadataService;
  List<Map<String, dynamic>>? _cachedIndex;

  SearchRepositoryImpl({
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) : _metadataService = metadataService;

  @override
  Future<void> init() async {
    if (_cachedIndex != null) return;

    _cachedIndex = _metadataService.allVersesRawData.map((verse) {
      final emlaey = (verse['aya_text_emlaey'] ?? '').toString();
      final surahNumber = verse['sora'] as int;
      final verseNumber = verse['aya_no'] as int;
      final originalText =
          (verse['aya_text'] ?? '').toString().replaceAll('۩', '').trim();

      return {
        'surah_number': surahNumber,
        'verse_number': verseNumber,
        'searchable_text': normalizeArabicText(emlaey),
        'original_text': originalText,
      };
    }).toList();
  }

  /// Normalizes Arabic text by removing tashkeel/diacritics and unifying variant letters.
  static String normalizeArabicText(String text) {
    if (text.isEmpty) return '';
    return text
        // Remove diacritics (tashkeel), Quranic annotation marks, and small signs
        .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        // Normalize Alef forms (أ إ آ ٱ \u0671) to bare Alef (ا)
        .replaceAll(RegExp(r'[إأآٱ\u0671]'), 'ا')
        // Normalize Yaa forms (ي ى) to standard Yaa (ي)
        .replaceAll(RegExp(r'[ى]'), 'ي')
        // Normalize Taa Marbutah (ة) to Haa (ه)
        .replaceAll('ة', 'ه')
        // Collapse whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  @override
  Future<SearchQueryResult> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return SearchQueryResult.empty(query: query);
    }

    if (_cachedIndex == null) {
      await init();
    }

    // 1. Check for page number search (e.g. "20" or "۲۰")
    PageSearchResult? pageResult;
    final parsedPage = parseArabicInt(trimmed);
    if (parsedPage != null) {
      // Validate page bounds (1 to totalPagesCount = 604)
      if (parsedPage >= 1 && parsedPage <= _metadataService.totalPagesCount) {
        final pageData = _metadataService.getPageData(parsedPage);
        if (pageData.isNotEmpty) {
          final firstSection = pageData.first;
          final surahNumber = firstSection['surah'] as int;
          final verseNumber = firstSection['start'] as int;
          final surahName = _metadataService.getSurahNameArabic(surahNumber);

          pageResult = PageSearchResult(
            pageNumber: parsedPage,
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            surahName: surahName,
          );
        }
      }
    }

    // 2. Perform Quranic verse text search
    final normalizedQuery = normalizeArabicText(trimmed);
    if (normalizedQuery.isEmpty) {
      return SearchQueryResult(
        verses: const [],
        pageResult: pageResult,
        query: query,
      );
    }

    final queryWords =
        normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();
    if (queryWords.isEmpty) {
      return SearchQueryResult(
        verses: const [],
        pageResult: pageResult,
        query: query,
      );
    }

    final matchedVerses = <VerseSearchResult>[];

    for (final verse in _cachedIndex!) {
      final searchableText = verse['searchable_text'] as String;

      // Boolean AND: Must contain all query words
      bool containsAllWords = true;
      for (final word in queryWords) {
        if (!searchableText.contains(word)) {
          containsAllWords = false;
          break;
        }
      }

      if (containsAllWords) {
        int score = 10; // Base score for containing all query words

        // Exact phrase match bonus
        if (searchableText.contains(normalizedQuery)) {
          score += 50;

          // Starts with exact phrase bonus
          if (searchableText.startsWith(normalizedQuery)) {
            score += 20;
          }
        }

        // Exact individual word match bonus
        final verseWords = searchableText.split(' ');
        for (final qWord in queryWords) {
          if (verseWords.contains(qWord)) {
            score += 5;
          }
        }

        final surahNumber = verse['surah_number'] as int;
        final verseNumber = verse['verse_number'] as int;

        matchedVerses.add(
          VerseSearchResult(
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

    // Sort: highest score first, then surah ascending, then verse ascending
    matchedVerses.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;

      final surahComparison = a.surahNumber.compareTo(b.surahNumber);
      if (surahComparison != 0) return surahComparison;

      return a.verseNumber.compareTo(b.verseNumber);
    });

    return SearchQueryResult(
      verses: matchedVerses,
      pageResult: pageResult,
      query: query,
    );
  }
}
