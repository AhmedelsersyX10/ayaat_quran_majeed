import 'dart:typed_data';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/save_ayah_image_to_gallery_use_case.dart';

Future<void> saveImageToGallery(Uint8List capturedImage) async {
  try {
    if (sl.isRegistered<SaveAyahImageToGalleryUseCase>()) {
      await sl<SaveAyahImageToGalleryUseCase>()(
        imageBytes: capturedImage,
        fileName: 'ayah_save_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  } catch (e) {
    // Safely handled
  }
}
