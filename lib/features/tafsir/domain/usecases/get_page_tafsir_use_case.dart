import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

import '../entities/ayah_tafsir.dart';
import '../repositories/tafsir_repository.dart';

/// Business use case retrieving all Quran verses and their corresponding Tafsir
/// for a specific Mushaf page (1 to 604).
///
/// Combines canonical Quran text and metadata from [QuranMetadataService]
/// with tafsir explanations from [TafsirRepository].
/// Pure Dart — no Flutter framework dependencies.
class GetPageTafsirUseCase {
  final TafsirRepository _repository;
  final QuranMetadataService _metadataService;

  const GetPageTafsirUseCase({
    required TafsirRepository repository,
    QuranMetadataService metadataService = const QuranMetadataService(),
  })  : _repository = repository,
        _metadataService = metadataService;

  /// Executes page tafsir retrieval for [pageNumber].
  ///
  /// If [bookId] is provided, uses that specific book; otherwise resolves the
  /// user's currently selected book from [TafsirRepository.getSelectedBook].
  Future<List<AyahTafsir>> call({
    required int pageNumber,
    String? bookId,
  }) async {
    final safePage = pageNumber.clamp(1, 604);

    final activeBook = bookId != null
        ? (await _repository.getAvailableBooks()).firstWhere(
            (b) => b.id == bookId,
            orElse: () => throw ArgumentError('Book $bookId not found in catalog'),
          )
        : await _repository.getSelectedBook();

    final pageSegments = _metadataService.getPageData(safePage);
    if (pageSegments.isEmpty) {
      return const [];
    }

    final results = <AyahTafsir>[];

    for (final segment in pageSegments) {
      final int surah = (segment['surah'] as num).toInt();
      final int start = (segment['start'] as num).toInt();
      final int end = (segment['end'] as num).toInt();
      final String surahName = _metadataService.getSurahNameArabic(surah);

      for (int ayah = start; ayah <= end; ayah++) {
        final verseText = _metadataService.getVerse(surah, ayah);
        final endSymbol = _metadataService.getVerseEndSymbol(ayah);
        final isFirst = ayah == 1;

        String tafsirText = '';
        try {
          final tafsirVerse = await _repository.getAyahTafsir(
            bookId: activeBook.id,
            surahNumber: surah,
            ayahNumber: ayah,
          );
          tafsirText = tafsirVerse.text;
        } catch (_) {
          tafsirText = '';
        }

        results.add(
          AyahTafsir(
            surahNumber: surah,
            ayahNumber: ayah,
            pageNumber: safePage,
            ayahText: verseText,
            ayahEndSymbol: endSymbol,
            surahName: surahName,
            isFirstAyahOfSurah: isFirst,
            tafsirText: tafsirText,
            bookId: activeBook.id,
            bookName: activeBook.name,
          ),
        );
      }
    }

    return List<AyahTafsir>.unmodifiable(results);
  }
}

