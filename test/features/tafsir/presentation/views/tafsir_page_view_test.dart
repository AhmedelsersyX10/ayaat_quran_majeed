import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/ayah_tafsir.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_available_tafsir_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_page_tafsir_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/set_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/views/tafsir_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAudioPlaybackCubit extends Cubit<AudioPlaybackState>
    implements AudioPlaybackCubit {
  _FakeAudioPlaybackCubit() : super(const AudioPlaybackIdle());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetPageTafsirUseCase implements GetPageTafsirUseCase {
  List<AyahTafsir> verses = [];
  bool shouldThrow = false;

  @override
  Future<List<AyahTafsir>> call({required int pageNumber, String? bookId}) async {
    if (shouldThrow) throw Exception('Load failed');
    return verses;
  }
}

class _FakeGetSelectedTafsirBookUseCase implements GetSelectedTafsirBookUseCase {
  TafsirBook book;
  _FakeGetSelectedTafsirBookUseCase(this.book);
  @override
  Future<TafsirBook> call() async => book;
}

class _FakeSetSelectedTafsirBookUseCase implements SetSelectedTafsirBookUseCase {
  @override
  Future<void> call(String bookId) async {}
}

class _FakeGetAvailableTafsirBooksUseCase implements GetAvailableTafsirBooksUseCase {
  @override
  Future<List<TafsirBook>> call() async => [];
}

void main() {
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

  const testVerse6 = AyahTafsir(
    surahNumber: 2,
    ayahNumber: 6,
    pageNumber: 3,
    ayahText: 'إِنَّ الَّذِينَ كَفَرُوا سَوَاءٌ عَلَيْهِمْ',
    ayahEndSymbol: ' ﴿٦﴾ ',
    surahName: 'البَقَرَة',
    isFirstAyahOfSurah: false,
    tafsirText: 'إن الذين حقت عليهم كلمة الله بعدم الإيمان...',
    bookId: 'ar_muyassar',
    bookName: 'التفسير الميسر',
  );

  const testVerse1 = AyahTafsir(
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

  group('TafsirPageView Widget Tests (Reference 17)', () {
    late _FakeGetPageTafsirUseCase fakeGetPage;
    late TafsirCubit tafsirCubit;
    late _FakeAudioPlaybackCubit audioCubit;

    setUp(() {
      fakeGetPage = _FakeGetPageTafsirUseCase();
      tafsirCubit = TafsirCubit(
        getPageTafsirUseCase: fakeGetPage,
        getSelectedTafsirBookUseCase: _FakeGetSelectedTafsirBookUseCase(testBook),
        setSelectedTafsirBookUseCase: _FakeSetSelectedTafsirBookUseCase(),
        getAvailableTafsirBooksUseCase: _FakeGetAvailableTafsirBooksUseCase(),
        initialPage: 3,
      );
      audioCubit = _FakeAudioPlaybackCubit();
    });

    tearDown(() {
      tafsirCubit.close();
      audioCubit.close();
    });

    Widget createTestWidget({
      required int initialPage,
      ValueChanged<int>? onPageChanged,
      VoidCallback? onToggleChrome,
    }) {
      return ScreenUtilInit(
        designSize: const Size(392, 852),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<TafsirCubit>.value(value: tafsirCubit),
                BlocProvider<AudioPlaybackCubit>.value(value: audioCubit),
              ],
              child: TafsirPageView(
                initialPage: initialPage,
                onPageChanged: onPageChanged ?? (_) {},
                onToggleChrome: onToggleChrome ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders Quran text and Tafsir card matching Reference 17', (tester) async {
      fakeGetPage.verses = [testVerse6];

      await tester.pumpWidget(createTestWidget(initialPage: 3));
      await tester.pumpAndSettle();

      expect(find.textContaining('إِنَّ الَّذِينَ كَفَرُوا'), findsOneWidget);
      expect(find.textContaining('﴿٦﴾'), findsOneWidget);
      expect(find.textContaining('إن الذين حقت عليهم كلمة الله'), findsOneWidget);
    });

    testWidgets('renders Surah header banner on first ayah of surah', (tester) async {
      fakeGetPage.verses = [testVerse1];

      await tester.pumpWidget(createTestWidget(initialPage: 1));
      await tester.pumpAndSettle();

      expect(find.text('سُورَةُ الفَاتِحة'), findsOneWidget);
      expect(find.textContaining('أبتدئ قراءة القرآن'), findsOneWidget);
    });

    testWidgets('renders error state and retry button on failure', (tester) async {
      fakeGetPage.shouldThrow = true;

      await tester.pumpWidget(createTestWidget(initialPage: 3));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      // Tap retry with fixed data
      fakeGetPage.shouldThrow = false;
      fakeGetPage.verses = [testVerse6];

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.textContaining('إِنَّ الَّذِينَ كَفَرُوا'), findsOneWidget);
    });

    testWidgets('tapping page content triggers onToggleChrome', (tester) async {
      fakeGetPage.verses = [testVerse6];
      bool chromeToggled = false;

      await tester.pumpWidget(
        createTestWidget(
          initialPage: 3,
          onToggleChrome: () => chromeToggled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListView));
      await tester.pumpAndSettle();

      expect(chromeToggled, isTrue);
    });
  });
}
