import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

Future<File> saveImageToTempDirectory(Uint8List imageBytes) async {
  final tempDir = await getTemporaryDirectory();
  final tempFilePath = '${tempDir.path}/temp_image.png';

  final file = File(tempFilePath);
  await file.writeAsBytes(imageBytes);

  return file;
}

Future<void> saveImageToGallery(Uint8List capturedImage) async {
  try {
    final result = await ImageGallerySaverPlus.saveImage(
      capturedImage,
      quality: 100,
    );

    if (result != null && result['isSuccess']) {
      print('Image saved to gallery successfully');
    } else {
      print('Failed to save image to gallery');
    }
  } catch (e) {
    print('Error saving image to gallery: $e');
  }
}
