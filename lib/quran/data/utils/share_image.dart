import 'dart:typed_data';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_image_use_case.dart';

void shareImage(Uint8List capturedImage) async {
  try {
    if (sl.isRegistered<ShareAyahImageUseCase>()) {
      await sl<ShareAyahImageUseCase>()(
        imageBytes: capturedImage,
        fileName: 'ayah_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }
  } catch (e) {
    // Safely handled
  }
}
