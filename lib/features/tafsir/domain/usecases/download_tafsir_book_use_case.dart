import 'package:ayaat_quran_majeed/core/network/cancellation_token.dart';

import '../repositories/tafsir_repository.dart';

/// Business use case downloading a remote Tafsir dataset with progress reporting and cancellation.
/// Pure Dart — no Flutter framework dependencies.
class DownloadTafsirBookUseCase {
  final TafsirRepository _repository;

  const DownloadTafsirBookUseCase(this._repository);

  Future<void> call(
    String bookId, {
    void Function(int received, int total)? onProgress,
    AppCancellationToken? cancelToken,
  }) => _repository.downloadBook(
    bookId,
    onProgress: onProgress,
    cancelToken: cancelToken,
  );
}
