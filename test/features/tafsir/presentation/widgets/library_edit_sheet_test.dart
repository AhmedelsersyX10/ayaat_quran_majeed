import 'package:ayaat_quran_majeed/core/di/injection.dart';
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
import 'package:ayaat_quran_majeed/features/tafsir/presentation/widgets/library_edit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGetMyLibraryBooksUseCase implements GetMyLibraryBooksUseCase {
  List<TafsirBook> books = [];
  @override
  Future<List<TafsirBook>> call() async => books;
}

class _FakeGetAllCatalogBooksUseCase implements GetAllCatalogBooksUseCase {
  List<TafsirBook> books = [];
  @override
  Future<List<TafsirBook>> call() async => books;
}

class _FakeUpdateMyLibraryOrderUseCase implements UpdateMyLibraryOrderUseCase {
  @override
  Future<void> call(List<String> bookIds) async {}
}

class _FakeAddToMyLibraryUseCase implements AddToMyLibraryUseCase {
  String? addedId;
  @override
  Future<void> call(String bookId) async {
    addedId = bookId;
  }
}

class _FakeRemoveFromMyLibraryUseCase implements RemoveFromMyLibraryUseCase {
  String? removedId;
  @override
  Future<void> call(String bookId) async {
    removedId = bookId;
  }
}

class _FakeDownloadTafsirBookUseCase implements DownloadTafsirBookUseCase {
  @override
  Future<void> call(
    String bookId, {
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {}
}

class _FakeDeleteDownloadedBookUseCase implements DeleteDownloadedBookUseCase {
  @override
  Future<void> call(String bookId) async {}
}

void main() {
  group('LibraryEditSheet Widget Tests (Reference 34)', () {
    late _FakeGetMyLibraryBooksUseCase fakeGetMyLib;
    late _FakeGetAllCatalogBooksUseCase fakeGetAllCatalog;
    late _FakeUpdateMyLibraryOrderUseCase fakeUpdateOrder;
    late _FakeAddToMyLibraryUseCase fakeAddToLib;
    late _FakeRemoveFromMyLibraryUseCase fakeRemoveFromLib;
    late _FakeDownloadTafsirBookUseCase fakeDownload;
    late _FakeDeleteDownloadedBookUseCase fakeDelete;

    const testBookMuyassar = TafsirBook(
      id: 'ar_muyassar',
      name: 'التفسير الميسر',
      author: 'مجمع الملك فهد لطباعة المصحف الشريف',
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
      author: 'عبد الرحمن بن ناصر السعدي (المتوفى ١٣٧٦ هـ)',
      description: 'تيسير الكريم الرحمن في تفسير كلام المنان',
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

    const testBookErab = TafsirBook(
      id: 'e3rab',
      name: 'الإعراب',
      author: 'مركز تفسير للدراسات القرآنية',
      description: 'إعراب القرآن وبيان دلالاته',
      language: 'ar',
      languageName: 'العربية',
      category: TafsirCategory.arabicGrammar,
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
      fakeGetMyLib = _FakeGetMyLibraryBooksUseCase();
      fakeGetAllCatalog = _FakeGetAllCatalogBooksUseCase();
      fakeUpdateOrder = _FakeUpdateMyLibraryOrderUseCase();
      fakeAddToLib = _FakeAddToMyLibraryUseCase();
      fakeRemoveFromLib = _FakeRemoveFromMyLibraryUseCase();
      fakeDownload = _FakeDownloadTafsirBookUseCase();
      fakeDelete = _FakeDeleteDownloadedBookUseCase();

      fakeGetMyLib.books = [testBookMuyassar];
      fakeGetAllCatalog.books = [testBookMuyassar, testBookSaady, testBookErab];

      if (sl.isRegistered<LibraryCubit>()) {
        sl.unregister<LibraryCubit>();
      }
      sl.registerFactory<LibraryCubit>(
        () => LibraryCubit(
          getMyLibraryBooksUseCase: fakeGetMyLib,
          getAllCatalogBooksUseCase: fakeGetAllCatalog,
          updateMyLibraryOrderUseCase: fakeUpdateOrder,
          addToMyLibraryUseCase: fakeAddToLib,
          removeFromMyLibraryUseCase: fakeRemoveFromLib,
          downloadTafsirBookUseCase: fakeDownload,
          deleteDownloadedBookUseCase: fakeDelete,
        ),
      );
    });

    tearDown(() {
      if (sl.isRegistered<LibraryCubit>()) {
        sl.unregister<LibraryCubit>();
      }
    });

    Widget createTestWidget() {
      final cubit = sl<LibraryCubit>()..loadLibrary();

      return ScreenUtilInit(
        designSize: const Size(392, 844),
        builder: (_, __) => MaterialApp(
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: BlocProvider<LibraryCubit>.value(
                value: cubit,
                child: const LibraryEditSheet(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders title "تحرير المكتبة" and close icon button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('تحرير المكتبة'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders "مكتبتي" section with reorder handles and red minus buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('مكتبتي'), findsOneWidget);
      expect(find.text('التفسير الميسر'), findsOneWidget);
      expect(find.text('مجمع الملك فهد لطباعة المصحف الشريف'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle_rounded), findsOneWidget);
    });

    testWidgets('protects Al-Muyassar default book and displays notice when tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap red minus button on Al-Muyassar
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('لا يمكن حذف التفسير الميسر لأنه التفسير الافتراضي للمصحف'), findsOneWidget);
      expect(fakeRemoveFromLib.removedId, isNull);
    });

    testWidgets('renders categories ARABIC and ARABIC: GRAMMAR with green plus buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('ARABIC'), findsOneWidget);
      expect(find.text('تفسير السعدي'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('الإعراب'),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('ARABIC: GRAMMAR'), findsOneWidget);
      expect(find.text('الإعراب'), findsOneWidget);
    });

    testWidgets('tapping green plus button triggers book addition/download', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap green '+' on تفسير السعدي
      final addButtons = find.byIcon(Icons.add);
      await tester.tap(addButtons.first);
      await tester.pump();

      // Should have triggered download and add
      expect(fakeAddToLib.addedId, equals('sa3dy'));
    });
  });
}
