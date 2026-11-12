import 'dart:typed_data';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import '../theme/share_card_theme.dart';
import '../../domain/entities/share_params.dart';
import '../../domain/usecases/format_share_text_use_case.dart';
import '../../domain/usecases/save_ayah_image_to_gallery_use_case.dart';
import '../../domain/usecases/share_ayah_image_use_case.dart';
import '../../domain/usecases/share_ayah_text_use_case.dart';
import 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  final FormatShareTextUseCase _formatShareTextUseCase;
  final ShareAyahTextUseCase _shareAyahTextUseCase;
  final ShareAyahImageUseCase _shareAyahImageUseCase;
  final SaveAyahImageToGalleryUseCase _saveAyahImageToGalleryUseCase;
  final QuranMetadataService _metadataService;
  final TafsirRepository? _tafsirRepository;

  ShareCubit({
    required FormatShareTextUseCase formatShareTextUseCase,
    required ShareAyahTextUseCase shareAyahTextUseCase,
    required ShareAyahImageUseCase shareAyahImageUseCase,
    required SaveAyahImageToGalleryUseCase saveAyahImageToGalleryUseCase,
    QuranMetadataService metadataService = const QuranMetadataService(),
    TafsirRepository? tafsirRepository,
    ShareParams? initialParams,
  }) : _formatShareTextUseCase = formatShareTextUseCase,
       _shareAyahTextUseCase = shareAyahTextUseCase,
       _shareAyahImageUseCase = shareAyahImageUseCase,
       _saveAyahImageToGalleryUseCase = saveAyahImageToGalleryUseCase,
       _metadataService = metadataService,
       _tafsirRepository = tafsirRepository,
       super(
         ShareState(
           params:
               initialParams ??
               const ShareParams(
                 surahNumber: 1,
                 surahName: 'الفاتحة',
                 fromAyah: 1,
                 toAyah: 1,
               ),
           totalVersesInSurah: initialParams != null
               ? metadataService.getVerseCount(initialParams.surahNumber)
               : 7,
         ),
       );

  /// Initializes or updates parameters for a specific surah and verse.
  void init({
    required int surahNumber,
    required int verseNumber,
    int? pageNumber,
    String? noteText,
  }) {
    final surahName = _metadataService.getSurahNameArabic(surahNumber);
    final totalVerses = _metadataService.getVerseCount(surahNumber);
    final resolvedPage =
        pageNumber ?? _metadataService.getPageNumber(surahNumber, verseNumber);

    final newParams = ShareParams(
      surahNumber: surahNumber,
      surahName: surahName,
      fromAyah: verseNumber,
      toAyah: verseNumber,
      pageNumber: resolvedPage,
      noteText: noteText,
      withoutTashkeel: state.params.withoutTashkeel,
      includeAppBranding: state.params.includeAppBranding,
      includeTafsir: false,
    );

    emit(
      state.copyWith(
        params: newParams,
        totalVersesInSurah: totalVerses,
        status: ShareActionStatus.idle,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  /// Updates the verse range [from] to [to].
  Future<void> updateRange(int from, int to) async {
    final total = state.totalVersesInSurah;
    final clampedFrom = from.clamp(1, total);
    final clampedTo = to.clamp(clampedFrom, total);

    final updated = state.params.copyWith(
      fromAyah: clampedFrom,
      toAyah: clampedTo,
    );

    emit(state.copyWith(params: updated));

    if (updated.includeTafsir) {
      await _fetchTafsirForRange(clampedFrom, clampedTo);
    }
  }

  /// Toggles whether tafsir is included.
  Future<void> toggleTafsir(bool include) async {
    final updated = state.params.copyWith(includeTafsir: include);
    emit(state.copyWith(params: updated));

    if (include &&
        (updated.tafsirText == null || updated.tafsirText!.isEmpty)) {
      await _fetchTafsirForRange(updated.fromAyah, updated.toAyah);
    }
  }

  /// Toggles whether text is shared without tashkeel (diacritics).
  void toggleWithoutTashkeel(bool value) {
    emit(state.copyWith(params: state.params.copyWith(withoutTashkeel: value)));
  }

  /// Toggles app branding attribution.
  void toggleBranding(bool include) {
    emit(
      state.copyWith(
        params: state.params.copyWith(includeAppBranding: include),
      ),
    );
  }

  /// Updates card color theme.
  void updateTheme(ShareCardTheme theme) {
    emit(state.copyWith(cardTheme: theme));
  }

  /// Updates font size.
  void updateFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  /// Updates text alignment.
  void updateAlignment(TextAlign alignment) {
    emit(state.copyWith(alignment: alignment));
  }

  /// Fetches tafsir text for the current range.
  Future<void> _fetchTafsirForRange(int from, int to) async {
    if (_tafsirRepository == null) return;

    emit(state.copyWith(status: ShareActionStatus.loadingTafsir));
    try {
      final selectedBook = await _tafsirRepository.getSelectedBook();
      final tafsirSpans = <String>[];

      for (int i = from; i <= to; i++) {
        final tafsirVerse = await _tafsirRepository.getAyahTafsir(
          bookId: selectedBook.id,
          surahNumber: state.params.surahNumber,
          ayahNumber: i,
        );
        if (from == to) {
          tafsirSpans.add(tafsirVerse.text);
        } else {
          tafsirSpans.add('(${toArabicDigits(i)}): ${tafsirVerse.text}');
        }
      }

      final joinedText = tafsirSpans.join('\n\n');
      emit(
        state.copyWith(
          params: state.params.copyWith(
            tafsirText: joinedText,
            tafsirBookName: selectedBook.name,
          ),
          status: ShareActionStatus.idle,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          params: state.params.copyWith(tafsirText: null),
          status: ShareActionStatus.idle,
        ),
      );
    }
  }

  /// Shares formatted text.
  Future<void> shareAsText() async {
    emit(
      state.copyWith(status: ShareActionStatus.sharingText, errorMessage: null),
    );

    try {
      await _shareAyahTextUseCase(state.params);
      emit(
        state.copyWith(
          status: ShareActionStatus.shareSuccess,
          successMessage: 'تمت المشاركة بنجاح',
        ),
      );
    } catch (e) {
      final msg = e is Failure ? e.message : 'فشل مشاركة النص';
      emit(
        state.copyWith(status: ShareActionStatus.failure, errorMessage: msg),
      );
    }
  }

  /// Shares captured image card.
  Future<void> shareAsImage(ScreenshotController controller) async {
    emit(
      state.copyWith(
        status: ShareActionStatus.sharingImage,
        errorMessage: null,
      ),
    );

    try {
      final Uint8List? imageBytes = await controller.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 20),
      );

      if (imageBytes == null || imageBytes.isEmpty) {
        emit(
          state.copyWith(
            status: ShareActionStatus.failure,
            errorMessage: 'فشل التقاط صورة البطاقة',
          ),
        );
        return;
      }

      final fileName =
          'ayah_${state.params.surahNumber}_${state.params.fromAyah}_${state.params.toAyah}_${DateTime.now().millisecondsSinceEpoch}.png';
      await _shareAyahImageUseCase(imageBytes: imageBytes, fileName: fileName);

      emit(
        state.copyWith(
          status: ShareActionStatus.shareSuccess,
          successMessage: 'تمت مشاركة الصورة بنجاح',
        ),
      );
    } catch (e) {
      final msg = e is Failure ? e.message : 'فشل مشاركة صورة الآية';
      emit(
        state.copyWith(status: ShareActionStatus.failure, errorMessage: msg),
      );
    }
  }

  /// Saves captured image card directly to user gallery.
  Future<void> saveToGallery(ScreenshotController controller) async {
    emit(
      state.copyWith(
        status: ShareActionStatus.savingToGallery,
        errorMessage: null,
      ),
    );

    try {
      final Uint8List? imageBytes = await controller.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 20),
      );

      if (imageBytes == null || imageBytes.isEmpty) {
        emit(
          state.copyWith(
            status: ShareActionStatus.failure,
            errorMessage: 'فشل التقاط صورة البطاقة',
          ),
        );
        return;
      }

      final fileName =
          'ayah_${state.params.surahNumber}_${state.params.fromAyah}_${state.params.toAyah}_${DateTime.now().millisecondsSinceEpoch}';
      await _saveAyahImageToGalleryUseCase(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      emit(
        state.copyWith(
          status: ShareActionStatus.saveSuccess,
          successMessage: 'تم حفظ الصورة في الاستوديو بنجاح',
        ),
      );
    } catch (e) {
      final msg = e is Failure ? e.message : 'فشل حفظ الصورة في الاستوديو';
      emit(
        state.copyWith(status: ShareActionStatus.failure, errorMessage: msg),
      );
    }
  }

  /// Returns formatted Quran text according to the current state parameters.
  String getFormattedText() => _formatShareTextUseCase(state.params);

  void resetStatus() {
    emit(
      state.copyWith(
        status: ShareActionStatus.idle,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }
}
