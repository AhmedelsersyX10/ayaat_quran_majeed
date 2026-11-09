import '../repositories/tafsir_repository.dart';

/// Business use case for switching the currently active Tafsir book by ID.
/// Pure Dart — no Flutter framework dependencies.
class SetSelectedTafsirBookUseCase {
  final TafsirRepository _repository;

  const SetSelectedTafsirBookUseCase(this._repository);

  Future<void> call(String bookId) => _repository.setSelectedBook(bookId);
}

