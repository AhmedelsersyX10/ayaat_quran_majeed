import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Contract for interacting with the platform's share sheets, temp storage, and photo gallery.
abstract class ShareLocalDataSource {
  /// Writes [imageBytes] into `${tempDir}/ayaat_share/[fileName]` and returns the saved file.
  Future<File> saveImageToTemporaryFile(Uint8List imageBytes, String fileName);

  /// Triggers the platform share sheet for the file at [filePath] without premature deletion.
  Future<void> shareFile(String filePath, {String? text, String? subject});

  /// Triggers the platform share sheet with plain [text].
  Future<void> sharePlainText(String text, {String? subject});

  /// Saves [imageBytes] directly into the device's photo gallery / library.
  /// Returns `true` if saved successfully, `false` otherwise.
  Future<bool> saveImageToGallery(Uint8List imageBytes, String fileName);

  /// Scans the `ayaat_share` temporary folder and removes any cached export images older than [olderThan].
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  });
}

/// Production implementation of [ShareLocalDataSource].
class ShareLocalDataSourceImpl implements ShareLocalDataSource {
  const ShareLocalDataSourceImpl();

  static const String _shareDirectoryName = 'ayaat_share';

  Future<Directory> _getShareDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final shareDir = Directory('${tempDir.path}/$_shareDirectoryName');
    if (!await shareDir.exists()) {
      await shareDir.create(recursive: true);
    }
    return shareDir;
  }

  @override
  Future<File> saveImageToTemporaryFile(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final dir = await _getShareDirectory();
    final sanitizedName = fileName.endsWith('.png')
        ? fileName
        : '$fileName.png';
    final file = File('${dir.path}/$sanitizedName');
    await file.writeAsBytes(imageBytes, flush: true);
    return file;
  }

  @override
  Future<void> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    final xFile = XFile(filePath);
    await Share.shareXFiles([xFile], text: text, subject: subject);
  }

  @override
  Future<void> sharePlainText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  @override
  Future<bool> saveImageToGallery(Uint8List imageBytes, String fileName) async {
    try {
      final sanitizedName = fileName.endsWith('.png')
          ? fileName.substring(0, fileName.length - 4)
          : fileName;
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: sanitizedName,
      );

      if (result != null && result is Map) {
        final isSuccess = result['isSuccess'];
        return isSuccess == true || isSuccess == 1 || isSuccess == 'true';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {
    try {
      final dir = await _getShareDirectory();
      if (!await dir.exists()) return;

      final now = DateTime.now();
      await for (final entity in dir.list()) {
        if (entity is File) {
          try {
            final lastModified = await entity.lastModified();
            if (now.difference(lastModified) > olderThan) {
              await entity.delete();
            }
          } catch (_) {
            // Ignore single file cleanup errors
          }
        }
      }
    } catch (_) {
      // Ignore directory cleanup failures
    }
  }
}
