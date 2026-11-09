import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_verse.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_page_tafsir_use_case.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTafsirRepository implements TafsirRepository {
  TafsirBook selected = const TafsirBook(
    id: 'ar_muyassar',
    name: 'التفسير الميسر',
    author: 'مجمع الملك فهد',
    description: 'تفسير ميسر',
    language: 'ar',
    languageName: 'العربية',
    category: TafsirCategory.arabicTafsir,
    isBundled: true,
    isDownloaded: true,
    attribution: TafsirSourceAttribution(
      provider: 'KSU',
      sourceProject: 'Ayah',
      sourceUrl: 'https://quran.ksu.edu.sa',
      licenseNotes: 'Open',
    ),
  );

  @override
  Future<TafsirBook> getSelectedBook() async => selected;

  @override
  Future<List<TafsirBook>> getAvailableBooks() async => [selected];

  @override
  Future<TafsirVerse> getAyahTafsir({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return TafsirVerse(
      bookId: bookId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: 'تفسير الآية $ayahNumber من سورة $surahNumber',
    );
  }

  @override
  Future<List<TafsirVerse>> getSurahTafsir({
    required String bookId,
    required int surahNumber,
  }) async => [];

  @override
  Future<void> setSelectedBook(String bookId) async {}

  @override
  Future<List<TafsirBook>> getMyLibraryBooks() async => [selected];

  @override
  Future<void> addToMyLibrary(String bookId) async {}

  @override
  Future<void> removeFromMyLibrary(String bookId) async {}

  @override
  Future<void> updateMyLibraryOrder(List<String> bookIds) async {}

  @override
  Future<bool> isBookAvailableLocally(String bookId) async => true;

  @override
  Future<void> downloadBook(
    String bookId, {
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {}

  @override
  Future<void> deleteDownloadedBook(String bookId) async {}

  @override
  void clearMemoryCache() {}
}

void main() {
  group('GetPageTafsirUseCase Tests', () {
    late _FakeTafsirRepository fakeRepo;
    late GetPageTafsirUseCase useCase;

    setUp(() {
      fakeRepo = _FakeTafsirRepository();
      useCase = GetPageTafsirUseCase(
        repository: fakeRepo,
        metadataService: const QuranMetadataService(),
      );
    });

    test('retrieves all ayat and their tafsir for page 1 (Al-Fatihah)', () async {
      final ayat = await useCase(pageNumber: 1);

      // Al-Fatihah has 7 ayat on page 1
      expect(ayat.length, equals(7));
      expect(ayat.first.surahNumber, equals(1));
      expect(ayat.first.ayahNumber, equals(1));
      expect(ayat.first.isFirstAyahOfSurah, isTrue);
      expect(ayat.first.surahName, isNotEmpty);
      expect(ayat.first.ayahText, isNotEmpty);
      expect(ayat.first.tafsirText, equals('تفسير الآية 1 من سورة 1'));
      expect(ayat.first.bookId, equals('ar_muyassar'));
      expect(ayat.last.ayahNumber, equals(7));
      expect(ayat.last.isFirstAyahOfSurah, isFalse);
    });

    test('retrieves verses on page 3 (Al-Baqarah verses 6 to 16)', () async {
      final ayat = await useCase(pageNumber: 3);

      expect(ayat.length, equals(11));
      expect(ayat.first.surahNumber, equals(2));
      expect(ayat.first.ayahNumber, equals(6));
      expect(ayat.first.isFirstAyahOfSurah, isFalse);
      expect(ayat.last.surahNumber, equals(2));
      expect(ayat.last.ayahNumber, equals(16));
    });

    test('clamps out-of-range pages defensively (e.g. 0 -> 1, 999 -> 604)', () async {
      final page0 = await useCase(pageNumber: 0);
      expect(page0.first.pageNumber, equals(1));

      final page1000 = await useCase(pageNumber: 1000);
      expect(page1000.first.pageNumber, equals(604));
    });
  });
}
