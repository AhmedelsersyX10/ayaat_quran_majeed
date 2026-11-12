import 'dart:typed_data';
import '../repositories/share_repository.dart';

/// Saves captured Ayah card image bytes directly to the device photo library / gallery.
class SaveAyahImageToGalleryUseCase {
  final ShareRepository _repository;

  const SaveAyahImageToGalleryUseCase(this._repository);

  Future<void> call({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    await _repository.saveImageToGallery(
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }
}
