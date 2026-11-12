import 'dart:typed_data';
import 'package:ayaat_quran_majeed/features/share/presentation/theme/share_card_theme.dart';
import 'package:ayaat_quran_majeed/features/share/domain/entities/share_params.dart';
import 'package:ayaat_quran_majeed/features/share/domain/repositories/share_repository.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/format_share_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/save_ayah_image_to_gallery_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_image_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/cubit/share_cubit.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/cubit/share_state.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_verse.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeShareRepository implements ShareRepository {
  bool shouldFail = false;
  String? lastSharedText;
  Uint8List? lastSharedBytes;
  Uint8List? lastSavedBytes;

  @override
  String formatShareText(ShareParams params) => 'نص الآية المنسق';

  @override
  Future<void> shareText({required String text, String? subject}) async {
    if (shouldFail) throw Exception('Share failed');
    lastSharedText = text;
  }

  @override
  Future<String> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async {
    if (shouldFail) throw Exception('Image share failed');
    lastSharedBytes = imageBytes;
    return '/fake/path/$fileName';
  }

  @override
  Future<void> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (shouldFail) throw Exception('Gallery save failed');
    lastSavedBytes = imageBytes;
  }

  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {}
}

class _FakeTafsirRepository implements TafsirRepository {
  @override
  Future<TafsirBook> getSelectedBook() async => const TafsirBook(
    id: 'ar_muyassar',
    name: 'التفسير الميسر',
    language: 'ar',
    languageName: 'العربية',
    author: 'مجمع الملك فهد',
    description: 'تفسير ميسر',
    category: TafsirCategory.arabicTafsir,
    attribution: TafsirSourceAttribution(
      provider: 'مجمع الملك فهد',
      sourceProject: 'آيات',
      sourceUrl: '',
      licenseNotes: '',
    ),
    isDownloaded: true,
    isBundled: true,
  );

  @override
  Future<TafsirVerse> getAyahTafsir({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  }) async => TafsirVerse(
    bookId: bookId,
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    text: 'تفسير الآية $ayahNumber',
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeShareRepository fakeRepo;
  late _FakeTafsirRepository fakeTafsirRepo;
  late ShareCubit cubit;

  setUp(() {
    fakeRepo = _FakeShareRepository();
    fakeTafsirRepo = _FakeTafsirRepository();
    cubit = ShareCubit(
      formatShareTextUseCase: FormatShareTextUseCase(fakeRepo),
      shareAyahTextUseCase: ShareAyahTextUseCase(fakeRepo),
      shareAyahImageUseCase: ShareAyahImageUseCase(fakeRepo),
      saveAyahImageToGalleryUseCase: SaveAyahImageToGalleryUseCase(fakeRepo),
      metadataService: const QuranMetadataService(),
      tafsirRepository: fakeTafsirRepo,
    );
  });

  group('ShareCubit Unit Tests', () {
    test('initializes state with Al-Fatihah default params', () {
      expect(cubit.state.params.surahNumber, 1);
      expect(cubit.state.params.fromAyah, 1);
      expect(cubit.state.params.toAyah, 1);
      expect(cubit.state.totalVersesInSurah, 7);
      expect(cubit.state.status, ShareActionStatus.idle);
    });

    test('init reconfigures cubit for specific surah and verse', () {
      cubit.init(surahNumber: 2, verseNumber: 255, noteText: 'ملاحظة');

      expect(cubit.state.params.surahNumber, 2);
      expect(cubit.state.params.surahName, 'البقرة');
      expect(cubit.state.params.fromAyah, 255);
      expect(cubit.state.params.toAyah, 255);
      expect(cubit.state.params.noteText, 'ملاحظة');
      expect(cubit.state.totalVersesInSurah, 286);
    });

    test('updateRange clamps values within valid surah bounds', () async {
      cubit.init(surahNumber: 1, verseNumber: 1); // 7 verses

      await cubit.updateRange(2, 5);
      expect(cubit.state.params.fromAyah, 2);
      expect(cubit.state.params.toAyah, 5);

      // Attempt out-of-bounds
      await cubit.updateRange(-5, 99);
      expect(cubit.state.params.fromAyah, 1);
      expect(cubit.state.params.toAyah, 7);
    });

    test(
      'toggleTafsir fetches and populates tafsir text when enabled',
      () async {
        cubit.init(surahNumber: 1, verseNumber: 1);

        await cubit.toggleTafsir(true);

        expect(cubit.state.params.includeTafsir, isTrue);
        expect(cubit.state.params.tafsirText, contains('تفسير الآية 1'));
        expect(cubit.state.params.tafsirBookName, 'التفسير الميسر');

        await cubit.toggleTafsir(false);
        expect(cubit.state.params.includeTafsir, isFalse);
      },
    );

    test(
      'updateTheme, updateFontSize, updateAlignment, toggleWithoutTashkeel, and toggleBranding update state and params',
      () {
        cubit.updateTheme(ShareCardTheme.royalDark);
        expect(cubit.state.cardTheme, ShareCardTheme.royalDark);

        cubit.updateFontSize(28.0);
        expect(cubit.state.fontSize, 28.0);

        cubit.updateAlignment(TextAlign.right);
        expect(cubit.state.alignment, TextAlign.right);

        cubit.toggleWithoutTashkeel(true);
        expect(cubit.state.params.withoutTashkeel, isTrue);

        cubit.toggleBranding(false);
        expect(cubit.state.params.includeAppBranding, isFalse);
      },
    );

    test(
      'shareAsText emits sharingText then shareSuccess on success',
      () async {
        await cubit.shareAsText();

        expect(cubit.state.status, ShareActionStatus.shareSuccess);
        expect(fakeRepo.lastSharedText, 'نص الآية المنسق');
      },
    );

    test('shareAsText emits failure on exception', () async {
      fakeRepo.shouldFail = true;
      await cubit.shareAsText();

      expect(cubit.state.status, ShareActionStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('getFormattedText delegates to FormatShareTextUseCase', () {
      final formatted = cubit.getFormattedText();
      expect(formatted, 'نص الآية المنسق');
    });

    test('resetStatus restores idle status and clears messages', () async {
      fakeRepo.shouldFail = true;
      await cubit.shareAsText();
      expect(cubit.state.status, ShareActionStatus.failure);

      cubit.resetStatus();
      expect(cubit.state.status, ShareActionStatus.idle);
      expect(cubit.state.errorMessage, isNull);
    });
  });
}
