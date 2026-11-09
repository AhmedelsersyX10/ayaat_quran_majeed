import '../entities/tafsir_book.dart';
import '../repositories/tafsir_repository.dart';

/// Business use case retrieving the entire catalog of available books
/// with their current local download status.
/// Pure Dart — no Flutter framework dependencies.
class GetAllCatalogBooksUseCase {
  final TafsirRepository _repository;

  const GetAllCatalogBooksUseCase(this._repository);

  Future<List<TafsirBook>> call() => _repository.getAvailableBooks();
}

