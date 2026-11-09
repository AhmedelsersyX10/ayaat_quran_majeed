import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_verse.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/add_to_my_library_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/delete_downloaded_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/download_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_all_catalog_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_my_library_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/remove_from_my_library_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/update_my_library_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTafsirRepository implements TafsirRepository {
  List<TafsirBook> catalogBooks = [];
  List<TafsirBook> myLibraryBooks = [];
  List<String> lastUpdatedOrder = [];
  String? lastAddedBookId;
  String? lastRemovedBookId;
  String? lastDownloadedBookId;
  String? lastDeletedBookId;

  @override
  Future<List<TafsirBook>> getAvailableBooks() async => catalogBooks;

  @override
  Future<List<TafsirBook>> getMyLibraryBooks() async => myLibraryBooks;

  @override
  Future<void> updateMyLibraryOrder(List<String> bookIds) async {
    lastUpdatedOrder = List<String>.from(bookIds);
  }

  @override
  Future<void> addToMyLibrary(String bookId) async {
    lastAddedBookId = bookId;
  }

  @override
  Future<void> removeFromMyLibrary(String bookId) async {
    if (bookId == 'ar_muyassar') {
      throw const CacheException('The default Tafsir book cannot be removed from My Library');
    }
    lastRemovedBookId = bookId;
  }

  @override
  Future<void> downloadBook(
    String bookId, {
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    lastDownloadedBookId = bookId;
    if (onProgress != null) {
      onProgress(50, 100);
      onProgress(100, 100);
    }
  }

  @override
  Future<void> deleteDownloadedBook(String bookId) async {
    lastDeletedBookId = bookId;
  }

  @override
  Future<TafsirVerse> getAyahTafsir({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<TafsirVerse>> getSurahTafsir({
    required String bookId,
    required int surahNumber,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TafsirBook> getSelectedBook() async => throw UnimplementedError();

  @override
  Future<void> setSelectedBook(String bookId) async => throw UnimplementedError();

  @override
  Future<bool> isBookAvailableLocally(String bookId) async => true;

  @override
  void clearMemoryCache() {}
}

void main() {
  group('Library Use Cases Tests', () {
    late _FakeTafsirRepository fakeRepo;

    const testBook1 = TafsirBook(
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
        sourceUrl: '',
        licenseNotes: '',
      ),
    );

    const testBook2 = TafsirBook(
      id: 'sa3dy',
      name: 'تفسير السعدي',
      author: 'السعدي',
      description: 'تيسير الكريم الرحمن',
      language: 'ar',
      languageName: 'العربية',
      category: TafsirCategory.arabicTafsir,
      isBundled: false,
      isDownloaded: false,
      attribution: TafsirSourceAttribution(
        provider: 'KSU',
        sourceProject: 'Ayah',
        sourceUrl: '',
        licenseNotes: '',
      ),
    );

    setUp(() {
      fakeRepo = _FakeTafsirRepository();
      fakeRepo.catalogBooks = [testBook1, testBook2];
      fakeRepo.myLibraryBooks = [testBook1];
    });

    test('GetMyLibraryBooksUseCase returns pinned books', () async {
      final useCase = GetMyLibraryBooksUseCase(fakeRepo);
      final result = await useCase();

      expect(result.length, equals(1));
      expect(result.first.id, equals('ar_muyassar'));
    });

    test('GetAllCatalogBooksUseCase returns complete catalog', () async {
      final useCase = GetAllCatalogBooksUseCase(fakeRepo);
      final result = await useCase();

      expect(result.length, equals(2));
      expect(result[0].id, equals('ar_muyassar'));
      expect(result[1].id, equals('sa3dy'));
    });

    test('UpdateMyLibraryOrderUseCase passes reordered ids to repository', () async {
      final useCase = UpdateMyLibraryOrderUseCase(fakeRepo);
      await useCase(['sa3dy', 'ar_muyassar']);

      expect(fakeRepo.lastUpdatedOrder, equals(['sa3dy', 'ar_muyassar']));
    });

    test('AddToMyLibraryUseCase delegates book addition to repository', () async {
      final useCase = AddToMyLibraryUseCase(fakeRepo);
      await useCase('sa3dy');

      expect(fakeRepo.lastAddedBookId, equals('sa3dy'));
    });

    test('RemoveFromMyLibraryUseCase delegates removal for non-default book', () async {
      final useCase = RemoveFromMyLibraryUseCase(fakeRepo);
      await useCase('sa3dy');

      expect(fakeRepo.lastRemovedBookId, equals('sa3dy'));
    });

    test('RemoveFromMyLibraryUseCase throws CacheException when targeting default book', () async {
      final useCase = RemoveFromMyLibraryUseCase(fakeRepo);

      expect(
        () => useCase('ar_muyassar'),
        throwsA(isA<CacheException>()),
      );
    });

    test('DownloadTafsirBookUseCase invokes repository download with progress', () async {
      final useCase = DownloadTafsirBookUseCase(fakeRepo);
      final progressList = <int>[];

      await useCase(
        'sa3dy',
        onProgress: (received, total) {
          progressList.add(received);
        },
      );

      expect(fakeRepo.lastDownloadedBookId, equals('sa3dy'));
      expect(progressList, equals([50, 100]));
    });

    test('DeleteDownloadedBookUseCase delegates deletion to repository', () async {
      final useCase = DeleteDownloadedBookUseCase(fakeRepo);
      await useCase('sa3dy');

      expect(fakeRepo.lastDeletedBookId, equals('sa3dy'));
    });
  });
}

