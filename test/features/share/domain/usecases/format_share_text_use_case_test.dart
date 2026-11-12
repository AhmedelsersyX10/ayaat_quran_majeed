import 'dart:io';
import 'dart:typed_data';
import 'package:ayaat_quran_majeed/features/share/data/repositories/share_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/share/domain/entities/share_params.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/format_share_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/data/datasources/share_local_data_source.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalDataSource implements ShareLocalDataSource {
  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {}
  @override
  Future<File> saveImageToTemporaryFile(
    Uint8List bytes,
    String fileName,
  ) async => throw UnimplementedError();
  @override
  Future<bool> saveImageToGallery(Uint8List bytes, String fileName) async =>
      true;
  @override
  Future<void> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {}
  @override
  Future<void> sharePlainText(String text, {String? subject}) async {}
}

void main() {
  late ShareRepositoryImpl repository;
  late FormatShareTextUseCase useCase;

  setUp(() {
    repository = ShareRepositoryImpl(
      localDataSource: _FakeLocalDataSource(),
      metadataService: const QuranMetadataService(),
    );
    useCase = FormatShareTextUseCase(repository);
  });

  group('FormatShareTextUseCase Unit Tests', () {
    test(
      'formats single ayah with exact text, Arabic-Indic numerals, and reference citation',
      () {
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
          includeTafsir: false,
          includeAppBranding: false,
        );

        final result = useCase(params);

        final ayah1Text = const QuranMetadataService().getVerse(1, 1);
        expect(result, contains(ayah1Text));
        expect(result, contains('(١)'));
        expect(result, contains('[سورة الفاتحة: ١]'));
        expect(result, isNot(contains('تمت المشاركة من تطبيق')));
      },
    );

    test(
      'formats verse range across multiple verses with individual verse numbers',
      () {
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 3,
          includeTafsir: false,
          includeAppBranding: false,
        );

        final result = useCase(params);

        expect(result, contains('(١)'));
        expect(result, contains('(٢)'));
        expect(result, contains('(٣)'));
        expect(result, contains('[سورة الفاتحة: ١ - ٣]'));
      },
    );

    test('prepends quoted note text when present (matching Reference 29)', () {
      const params = ShareParams(
        surahNumber: 2,
        surahName: 'البقرة',
        fromAyah: 255,
        toAyah: 255,
        noteText: 'آية الكرسي أعظم آية في كتاب الله',
        includeTafsir: false,
        includeAppBranding: false,
      );

      final result = useCase(params);

      expect(result.startsWith('آية الكرسي أعظم آية في كتاب الله'), isTrue);
      expect(result, contains('[سورة البقرة: ٢٥٥]'));
    });

    test('appends tafsir section when includeTafsir is true', () {
      const params = ShareParams(
        surahNumber: 112,
        surahName: 'الإخلاص',
        fromAyah: 1,
        toAyah: 1,
        includeTafsir: true,
        tafsirText:
            'قل يا محمد لهؤلاء المشركين: هو الله الأحد المستحق للعبادة وحده',
        tafsirBookName: 'التفسير الميسر',
        includeAppBranding: false,
      );

      final result = useCase(params);

      expect(result, contains('التفسير الميسر:'));
      expect(result, contains('المستحق للعبادة وحده'));
    });

    test('appends app branding when includeAppBranding is true', () {
      const params = ShareParams(
        surahNumber: 1,
        surahName: 'الفاتحة',
        fromAyah: 7,
        toAyah: 7,
        includeTafsir: false,
        includeAppBranding: true,
      );

      final result = useCase(params);

      expect(
        result,
        contains('تمت المشاركة من تطبيق «آيات - تطبيق القرآن الكريم»'),
      );
    });

    test(
      'formats ayah without diacritics/tashkeel when withoutTashkeel is true',
      () {
        const metadataService = QuranMetadataService();
        const params = ShareParams(
          surahNumber: 1,
          surahName: 'الفاتحة',
          fromAyah: 1,
          toAyah: 1,
          withoutTashkeel: true,
          includeTafsir: false,
          includeAppBranding: false,
        );

        final result = useCase(params);
        final rawVerse = metadataService.getVerse(1, 1);
        final expectedNoDiacritics = metadataService.removeDiacritics(rawVerse);

        expect(result, contains(expectedNoDiacritics));
        expect(result, contains('(١)'));
        expect(result, contains('[سورة الفاتحة: ١]'));
        expect(result, isNot(contains(rawVerse)));
      },
    );
  });
}
