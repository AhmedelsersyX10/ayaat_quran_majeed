import 'dart:typed_data';
import '../entities/share_params.dart';

/// Central domain repository contract for formatting, sharing, and saving Quranic verses.
///
/// Pure Dart — no UI dependencies.
abstract class ShareRepository {
  /// Formats the Quranic verses according to [params] into a clean textual representation.
  String formatShareText(ShareParams params);

  /// Triggers the platform native share sheet with plain formatted [text].
  Future<void> shareText({required String text, String? subject});

  /// Writes [imageBytes] to a dedicated temp directory and triggers the platform share sheet.
  /// Returns the saved temporary file path.
  Future<String> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  });

  /// Saves the captured Ayah card [imageBytes] directly into the user's gallery / photo album.
  Future<void> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  });

  /// Safely removes temporary export images older than [olderThan].
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  });
}
