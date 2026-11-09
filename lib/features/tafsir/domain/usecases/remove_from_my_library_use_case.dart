import '../repositories/tafsir_repository.dart';

/// Business use case removing a book from the user's pinned library ("مكتبتي").
/// Guaranteed to throw if the default book (Al-Tafsir Al-Muyassar) is targeted.
/// Pure Dart — no Flutter framework dependencies.
class RemoveFromMyLibraryUseCase {
  final TafsirRepository _repository;

  const RemoveFromMyLibraryUseCase(this._repository);

  Future<void> call(String bookId) => _repository.removeFromMyLibrary(bookId);
}

