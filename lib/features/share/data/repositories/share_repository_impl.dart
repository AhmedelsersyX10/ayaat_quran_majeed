import 'dart:typed_data';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import '../../domain/entities/share_params.dart';
import '../../domain/repositories/share_repository.dart';
import '../datasources/share_local_data_source.dart';

/// Implementation of [ShareRepository] orchestrating formatting, file caching,
/// gallery persistence, and platform share sheets.
class ShareRepositoryImpl implements ShareRepository {
  final ShareLocalDataSource _localDataSource;
  final QuranMetadataService _metadataService;

  const ShareRepositoryImpl({
    required ShareLocalDataSource localDataSource,
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) : _localDataSource = localDataSource,
       _metadataService = metadataService;

  @override
  String formatShareText(ShareParams params) {
    final buffer = StringBuffer();

    // 1. Quoted note text if present (Ref 29)
    if (params.noteText != null && params.noteText!.trim().isNotEmpty) {
      buffer.writeln(params.noteText!.trim());
      buffer.writeln();
    }

    // 2. Exact Quranic verse text with Arabic-Indic verse symbols
    final ayahSpans = <String>[];
    for (int i = params.fromAyah; i <= params.toAyah; i++) {
      var verseText = _metadataService.getVerse(params.surahNumber, i);
      if (params.withoutTashkeel) {
        verseText = _metadataService.removeDiacritics(verseText);
      }
      final ayahNumber = toArabicDigits(i);
      ayahSpans.add('$verseText ($ayahNumber)');
    }

    buffer.writeln('﴿${ayahSpans.join(' ')}﴾');
    buffer.writeln();

    // 3. Surah and Ayah reference badge
    final surahRef = params.fromAyah == params.toAyah
        ? '[سورة ${params.surahName}: ${toArabicDigits(params.fromAyah)}]'
        : '[سورة ${params.surahName}: ${toArabicDigits(params.fromAyah)} - ${toArabicDigits(params.toAyah)}]';
    buffer.writeln(surahRef);

    // 4. Optional Tafsir explanation
    if (params.includeTafsir &&
        params.tafsirText != null &&
        params.tafsirText!.trim().isNotEmpty) {
      buffer.writeln();
      final tafsirTitle = params.tafsirBookName ?? 'التفسير الميسر';
      buffer.writeln('$tafsirTitle:');
      buffer.writeln(params.tafsirText!.trim());
    }

    // 5. App attribution branding
    if (params.includeAppBranding) {
      buffer.writeln();
      buffer.write('تمت المشاركة من تطبيق «آيات - تطبيق القرآن الكريم»');
    }

    return buffer.toString().trim();
  }

  @override
  Future<void> shareText({required String text, String? subject}) async {
    try {
      await _localDataSource.sharePlainText(text, subject: subject);
    } catch (e) {
      throw ShareFailure('فشل مشاركة النص: $e');
    }
  }

  @override
  Future<String> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async {
    try {
      // Clean up stale share files before saving new one
      await _localDataSource.cleanOldShareFiles();

      final file = await _localDataSource.saveImageToTemporaryFile(
        imageBytes,
        fileName,
      );

      await _localDataSource.shareFile(file.path, text: text);
      return file.path;
    } catch (e) {
      throw ShareFailure('فشل مشاركة صورة الآية: $e');
    }
  }

  @override
  Future<void> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final success = await _localDataSource.saveImageToGallery(
        imageBytes,
        fileName,
      );
      if (!success) {
        throw const ShareFailure('فشل حفظ الصورة في الاستوديو');
      }
    } catch (e) {
      if (e is ShareFailure) rethrow;
      throw ShareFailure('حدث خطأ أثناء حفظ الصورة: $e');
    }
  }

  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {
    await _localDataSource.cleanOldShareFiles(olderThan: olderThan);
  }
}
