import 'dart:typed_data';
import '../repositories/share_repository.dart';

/// Exports captured Ayah card image bytes to a temp file and shares it via the native share sheet.
class ShareAyahImageUseCase {
  final ShareRepository _repository;

  const ShareAyahImageUseCase(this._repository);

  Future<String> call({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async {
    return _repository.shareImage(
      imageBytes: imageBytes,
      fileName: fileName,
      text: text,
    );
  }
}
