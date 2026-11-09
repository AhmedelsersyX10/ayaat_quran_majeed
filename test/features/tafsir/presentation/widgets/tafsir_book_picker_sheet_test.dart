import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/ayah_tafsir.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_available_tafsir_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_page_tafsir_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/set_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/widgets/tafsir_book_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGetPageTafsirUseCase implements GetPageTafsirUseCase {
  @override
  Future<List<AyahTafsir>> call({required int pageNumber, String? bookId}) async => [];
}

class _FakeGetSelectedTafsirBookUseCase implements GetSelectedTafsirBookUseCase {
  TafsirBook book;
  _FakeGetSelectedTafsirBookUseCase(this.book);
  @override
  Future<TafsirBook> call() async => book;
}

class _FakeSetSelectedTafsirBookUseCase implements SetSelectedTafsirBookUseCase {
  String? lastSelected;
  @override
  Future<void> call(String bookId) async {
    lastSelected = bookId;
  }
}

class _FakeGetAvailableTafsirBooksUseCase implements GetAvailableTafsirBooksUseCase {
  List<TafsirBook> books;
  _FakeGetAvailableTafsirBooksUseCase(this.books);
  @override
  Future<List<TafsirBook>> call() async => books;
}

void main() {
  const muyassar = TafsirBook(
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

  const sahih = TafsirBook(
    id: 'en_sahih',
    name: 'English - Sahih International',
    author: 'Saheeh International',
    description: 'English Translation',
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

  group('TafsirBookPickerSheet Widget Tests', () {
    late _FakeSetSelectedTafsirBookUseCase fakeSetSelected;
    late TafsirCubit cubit;

    setUp(() {
      fakeSetSelected = _FakeSetSelectedTafsirBookUseCase();
      cubit = TafsirCubit(
        getPageTafsirUseCase: _FakeGetPageTafsirUseCase(),
        getSelectedTafsirBookUseCase: _FakeGetSelectedTafsirBookUseCase(muyassar),
        setSelectedTafsirBookUseCase: fakeSetSelected,
        getAvailableTafsirBooksUseCase: _FakeGetAvailableTafsirBooksUseCase([muyassar, sahih]),
      );
    });

    tearDown(() {
      cubit.close();
    });

    Widget createTestWidget() {
      return ScreenUtilInit(
        designSize: const Size(392, 852),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const TafsirBookPickerSheet(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders available books and indicates active selection', (tester) async {
      await cubit.loadAvailableBooks();
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('كتب التفسير والترجمة'), findsOneWidget);
      expect(find.text('تعديل'), findsOneWidget);
      expect(find.text('التفسير الميسر'), findsOneWidget);
      expect(find.text('English - Sahih International'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('tapping a book selects it and closes the sheet', (tester) async {
      await cubit.loadAvailableBooks();
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('English - Sahih International'));
      await tester.pumpAndSettle();

      expect(fakeSetSelected.lastSelected, equals('en_sahih'));
    });
  });
}
