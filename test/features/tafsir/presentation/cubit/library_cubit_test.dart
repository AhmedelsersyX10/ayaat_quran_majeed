import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/add_to_my_library_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/delete_downloaded_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/download_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_all_catalog_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_my_library_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/remove_from_my_library_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/update_my_library_order_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/library_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/library_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockGetMyLibraryBooksUseCase implements GetMyLibraryBooksUseCase {
  List<TafsirBook> result = [];
  bool shouldThrow = false;
  @override
  Future<List<TafsirBook>> call() async {
    if (shouldThrow) throw Exception('Storage error');
    return result;
  }
}

class _MockGetAllCatalogBooksUseCase implements GetAllCatalogBooksUseCase {
  List<TafsirBook> result = [];
  bool shouldThrow = false;
  @override
  Future<List<TafsirBook>> call() async {
    if (shouldThrow) throw Exception('Catalog error');
    return result;
  }
}

class _MockUpdateMyLibraryOrderUseCase implements UpdateMyLibraryOrderUseCase {
  List<String>? lastOrder;
  @override
  Future<void> call(List<String> bookIds) async {
    lastOrder = bookIds;
  }
}

class _MockAddToMyLibraryUseCase implements AddToMyLibraryUseCase {
  String? addedId;
  @override
  Future<void> call(String bookId) async {
    addedId = bookId;
  }
}

class _MockRemoveFromMyLibraryUseCase implements RemoveFromMyLibraryUseCase {
  String? removedId;
  @override
  Future<void> call(String bookId) async {
    removedId = bookId;
  }
}

class _MockDownloadTafsirBookUseCase implements DownloadTafsirBookUseCase {
  bool shouldThrow = false;
  @override
  Future<void> call(
    String bookId, {
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    if (shouldThrow) throw Exception('Network timeout');
    if (onProgress != null) {
      onProgress(50, 100);
      onProgress(100, 100);
    }
  }
}

class _MockDeleteDownloadedBookUseCase implements DeleteDownloadedBookUseCase {
  String? deletedId;
  @override
  Future<void> call(String bookId) async {
    deletedId = bookId;
  }
}

void main() {
  group('LibraryCubit Tests', () {
    late _MockGetMyLibraryBooksUseCase mockGetMyLib;
    late _MockGetAllCatalogBooksUseCase mockGetAllCatalog;
    late _MockUpdateMyLibraryOrderUseCase mockUpdateOrder;
    late _MockAddToMyLibraryUseCase mockAddToLib;
    late _MockRemoveFromMyLibraryUseCase mockRemoveFromLib;
    late _MockDownloadTafsirBookUseCase mockDownload;
    late _MockDeleteDownloadedBookUseCase mockDelete;
    late LibraryCubit cubit;

    const testBookMuyassar = TafsirBook(
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

    const testBookSaady = TafsirBook(
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

    const testBookEnglish = TafsirBook(
      id: 'en_sahih',
      name: 'Sahih International',
      author: 'Saheeh',
      description: 'The Quran',
      language: 'en',
      languageName: 'English',
      category: TafsirCategory.englishTranslation,
      isBundled: true,
      isDownloaded: true,
      attribution: TafsirSourceAttribution(
        provider: 'Tanzil',
        sourceProject: 'Tanzil',
        sourceUrl: '',
        licenseNotes: '',
      ),
    );

    setUp(() {
      mockGetMyLib = _MockGetMyLibraryBooksUseCase();
      mockGetAllCatalog = _MockGetAllCatalogBooksUseCase();
      mockUpdateOrder = _MockUpdateMyLibraryOrderUseCase();
      mockAddToLib = _MockAddToMyLibraryUseCase();
      mockRemoveFromLib = _MockRemoveFromMyLibraryUseCase();
      mockDownload = _MockDownloadTafsirBookUseCase();
      mockDelete = _MockDeleteDownloadedBookUseCase();

      mockGetMyLib.result = [testBookMuyassar];
      mockGetAllCatalog.result = [testBookMuyassar, testBookSaady, testBookEnglish];

      cubit = LibraryCubit(
        getMyLibraryBooksUseCase: mockGetMyLib,
        getAllCatalogBooksUseCase: mockGetAllCatalog,
        updateMyLibraryOrderUseCase: mockUpdateOrder,
        addToMyLibraryUseCase: mockAddToLib,
        removeFromMyLibraryUseCase: mockRemoveFromLib,
        downloadTafsirBookUseCase: mockDownload,
        deleteDownloadedBookUseCase: mockDelete,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has correct defaults', () {
      expect(cubit.state.status, equals(LibraryStatus.initial));
      expect(cubit.state.myLibraryBooks, isEmpty);
      expect(cubit.state.availableBooks, isEmpty);
      expect(cubit.state.downloadingProgress, isEmpty);
      expect(cubit.state.failedDownloads, isEmpty);
    });

    test('loadLibrary emits [loading, loaded] and populates books', () async {
      await cubit.loadLibrary();

      expect(cubit.state.status, equals(LibraryStatus.loaded));
      expect(cubit.state.myLibraryBooks.length, equals(1));
      expect(cubit.state.myLibraryBooks.first.id, equals('ar_muyassar'));
      expect(cubit.state.availableBooks.length, equals(3));
      // Categorized available books must exclude ar_muyassar
      final availableArabic = cubit.state.categorizedAvailableBooks[TafsirCategory.arabicTafsir];
      expect(availableArabic?.map((b) => b.id), contains('sa3dy'));
      expect(availableArabic?.map((b) => b.id), isNot(contains('ar_muyassar')));
    });

    test('loadLibrary emits failure when use case throws', () async {
      mockGetMyLib.shouldThrow = true;
      await cubit.loadLibrary();

      expect(cubit.state.status, equals(LibraryStatus.failure));
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('reorderMyLibrary adjusts indices optimistically and calls update order use case', () async {
      mockGetMyLib.result = [testBookMuyassar, testBookEnglish];
      await cubit.loadLibrary();

      await cubit.reorderMyLibrary(0, 2);

      expect(cubit.state.myLibraryBooks.first.id, equals('en_sahih'));
      expect(cubit.state.myLibraryBooks.last.id, equals('ar_muyassar'));
      expect(mockUpdateOrder.lastOrder, equals(['en_sahih', 'ar_muyassar']));
    });

    test('removeFromMyLibrary protects default book ar_muyassar and emits userNotice', () async {
      await cubit.loadLibrary();

      await cubit.removeFromMyLibrary('ar_muyassar');

      expect(cubit.state.userNotice, isNotNull);
      expect(cubit.state.userNotice, contains('الافتراضي'));
      expect(mockRemoveFromLib.removedId, isNull);
    });

    test('removeFromMyLibrary removes non-default book and reloads', () async {
      mockGetMyLib.result = [testBookMuyassar, testBookEnglish];
      await cubit.loadLibrary();

      mockGetMyLib.result = [testBookMuyassar];
      await cubit.removeFromMyLibrary('en_sahih');

      expect(mockRemoveFromLib.removedId, equals('en_sahih'));
      expect(cubit.state.myLibraryBooks.length, equals(1));
    });

    test('addToMyLibrary for already bundled book adds immediately without download', () async {
      await cubit.loadLibrary();

      mockGetMyLib.result = [testBookMuyassar, testBookEnglish];
      await cubit.addToMyLibrary('en_sahih');

      expect(mockAddToLib.addedId, equals('en_sahih'));
      expect(cubit.state.downloadingProgress, isEmpty);
    });

    test('addToMyLibrary for remote non-downloaded book initiates download then adds', () async {
      await cubit.loadLibrary();

      mockGetMyLib.result = [testBookMuyassar, testBookSaady.copyWith(isDownloaded: true)];
      await cubit.addToMyLibrary('sa3dy');

      expect(mockAddToLib.addedId, equals('sa3dy'));
      expect(cubit.state.downloadingProgress, isEmpty);
      expect(cubit.state.failedDownloads, isEmpty);
    });

    test('addToMyLibrary records error in failedDownloads when download fails', () async {
      await cubit.loadLibrary();
      mockDownload.shouldThrow = true;

      await cubit.addToMyLibrary('sa3dy');

      expect(cubit.state.failedDownloads.containsKey('sa3dy'), isTrue);
      expect(cubit.state.downloadingProgress, isEmpty);
      expect(mockAddToLib.addedId, isNull);
    });

    test('deleteDownloadedBook calls delete use case and refreshes', () async {
      await cubit.loadLibrary();
      await cubit.deleteDownloadedBook('sa3dy');

      expect(mockDelete.deletedId, equals('sa3dy'));
    });
  });
}

