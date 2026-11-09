import '../repositories/tafsir_repository.dart';

/// Business use case adding a book to the user's pinned library ("مكتبتي").
/// Pure Dart — no Flutter framework dependencies.
class AddToMyLibraryUseCase {
  final TafsirRepository _repository;

  const AddToMyLibraryUseCase(this._repository);

  Future<void> call(String bookId) => _repository.addToMyLibrary(bookId);
}

