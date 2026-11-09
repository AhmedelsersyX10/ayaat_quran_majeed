import '../repositories/tafsir_repository.dart';

/// Business use case deleting a downloaded Tafsir dataset from local storage.
/// Bundled books cannot be deleted.
/// Pure Dart — no Flutter framework dependencies.
class DeleteDownloadedBookUseCase {
  final TafsirRepository _repository;

  const DeleteDownloadedBookUseCase(this._repository);

  Future<void> call(String bookId) => _repository.deleteDownloadedBook(bookId);
}

