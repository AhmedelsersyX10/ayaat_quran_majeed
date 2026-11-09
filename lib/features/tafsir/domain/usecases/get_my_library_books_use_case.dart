import '../entities/tafsir_book.dart';
import '../repositories/tafsir_repository.dart';

/// Business use case retrieving the user's pinned library books ("مكتبتي").
/// Guaranteed to include the default readable book (Al-Tafsir Al-Muyassar).
/// Pure Dart — no Flutter framework dependencies.
class GetMyLibraryBooksUseCase {
  final TafsirRepository _repository;

  const GetMyLibraryBooksUseCase(this._repository);

  Future<List<TafsirBook>> call() => _repository.getMyLibraryBooks();
}

