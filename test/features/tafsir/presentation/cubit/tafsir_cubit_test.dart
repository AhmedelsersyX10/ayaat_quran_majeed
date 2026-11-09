import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/ayah_tafsir.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_available_tafsir_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_page_tafsir_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/set_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGetPageTafsirUseCase implements GetPageTafsirUseCase {
  List<AyahTafsir> nextResult = [];
  bool shouldThrow = false;

  @override
  Future<List<AyahTafsir>> call({required int pageNumber, String? bookId}) async {
    if (shouldThrow) throw Exception('Disk read error');
    return nextResult;
  }
}

class _FakeGetSelectedTafsirBookUseCase implements GetSelectedTafsirBookUseCase {
  TafsirBook currentBook;

  _FakeGetSelectedTafsirBookUseCase(this.currentBook);

  @override
  Future<TafsirBook> call() async => currentBook;
}

class _FakeSetSelectedTafsirBookUseCase implements SetSelectedTafsirBookUseCase {
  String? selectedId;

  @override
  Future<void> call(String bookId) async {
    selectedId = bookId;
  }
}

class _FakeGetAvailableTafsirBooksUseCase implements GetAvailableTafsirBooksUseCase {
  List<TafsirBook> books = [];

  @override
  Future<List<TafsirBook>> call() async => books;
}

void main() {
  group('TafsirCubit Tests', () {
    late _FakeGetPageTafsirUseCase fakeGetPage;
    late _FakeGetSelectedTafsirBookUseCase fakeGetSelected;
    late _FakeSetSelectedTafsirBookUseCase fakeSetSelected;
    late _FakeGetAvailableTafsirBooksUseCase fakeGetAvailable;
    late TafsirCubit cubit;

    const testBook = TafsirBook(
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

    const testVerse = AyahTafsir(
      surahNumber: 1,
      ayahNumber: 1,
      pageNumber: 1,
      ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      ayahEndSymbol: ' ﴿١﴾ ',
      surahName: 'الفَاتِحة',
      isFirstAyahOfSurah: true,
      tafsirText: 'أبتدئ قراءة القرآن باسم الله مستعينا به...',
      bookId: 'ar_muyassar',
      bookName: 'التفسير الميسر',
    );

    setUp(() {
      fakeGetPage = _FakeGetPageTafsirUseCase();
      fakeGetSelected = _FakeGetSelectedTafsirBookUseCase(testBook);
      fakeSetSelected = _FakeSetSelectedTafsirBookUseCase();
      fakeGetAvailable = _FakeGetAvailableTafsirBooksUseCase();
      fakeGetAvailable.books = [testBook];

      cubit = TafsirCubit(
        getPageTafsirUseCase: fakeGetPage,
        getSelectedTafsirBookUseCase: fakeGetSelected,
        setSelectedTafsirBookUseCase: fakeSetSelected,
        getAvailableTafsirBooksUseCase: fakeGetAvailable,
        initialPage: 1,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has correct defaults', () {
      expect(cubit.state.status, equals(TafsirStatus.initial));
      expect(cubit.state.pageNumber, equals(1));
      expect(cubit.state.verses, isEmpty);
      expect(cubit.state.selectedBook, isNull);
    });

    test('loadPageTafsir emits [loading, loaded] on success', () async {
      fakeGetPage.nextResult = [testVerse];

      final expectedStates = [
        predicate<TafsirState>((s) => s.status == TafsirStatus.loading && s.pageNumber == 1),
        predicate<TafsirState>((s) =>
            s.status == TafsirStatus.loaded &&
            s.verses.length == 1 &&
            s.selectedBook?.id == 'ar_muyassar'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.loadPageTafsir(1);
    });

    test('loadPageTafsir emits [loading, empty] when verses are empty', () async {
      fakeGetPage.nextResult = [];

      final expectedStates = [
        predicate<TafsirState>((s) => s.status == TafsirStatus.loading),
        predicate<TafsirState>((s) => s.status == TafsirStatus.empty && s.verses.isEmpty),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.loadPageTafsir(1);
    });

    test('loadPageTafsir emits [loading, failure] when use case throws', () async {
      fakeGetPage.shouldThrow = true;

      final expectedStates = [
        predicate<TafsirState>((s) => s.status == TafsirStatus.loading),
        predicate<TafsirState>((s) =>
            s.status == TafsirStatus.failure &&
            s.errorMessage != null &&
            s.errorMessage!.contains('1')),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.loadPageTafsir(1);
    });

    test('selectBook updates active book and reloads current page', () async {
      const newBook = TafsirBook(
        id: 'en_sahih',
        name: 'Sahih International',
        author: 'Saheeh',
        description: 'English translation',
        language: 'en',
        languageName: 'English',
        category: TafsirCategory.englishTranslation,
        isBundled: true,
        isDownloaded: true,
        attribution: TafsirSourceAttribution(
          provider: 'Tanzil',
          sourceProject: 'Tanzil',
          sourceUrl: 'https://tanzil.net',
          licenseNotes: 'Open',
        ),
      );

      fakeGetSelected.currentBook = newBook;
      fakeGetPage.nextResult = [testVerse.copyWith(bookId: 'en_sahih', bookName: 'Sahih International')];

      await cubit.selectBook('en_sahih');

      expect(fakeSetSelected.selectedId, equals('en_sahih'));
      expect(cubit.state.status, equals(TafsirStatus.loaded));
      expect(cubit.state.selectedBook?.id, equals('en_sahih'));
      expect(cubit.state.verses.first.bookId, equals('en_sahih'));
    });

    test('loadAvailableBooks populates availableBooks in state', () async {
      await cubit.loadAvailableBooks();
      expect(cubit.state.availableBooks.length, equals(1));
      expect(cubit.state.availableBooks.first.id, equals('ar_muyassar'));
    });

    test('retry re-runs loadPageTafsir with forceReload: true', () async {
      fakeGetPage.shouldThrow = true;
      await cubit.loadPageTafsir(1);
      expect(cubit.state.status, equals(TafsirStatus.failure));

      fakeGetPage.shouldThrow = false;
      fakeGetPage.nextResult = [testVerse];
      await cubit.retry();

      expect(cubit.state.status, equals(TafsirStatus.loaded));
      expect(cubit.state.verses.length, equals(1));
    });
  });
}

