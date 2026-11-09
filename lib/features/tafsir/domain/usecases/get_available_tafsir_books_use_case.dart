import '../entities/tafsir_book.dart';
import '../repositories/tafsir_repository.dart';

/// Business use case retrieving the list of locally available / library Tafsir books
/// that the user can immediately select and read.
/// Pure Dart — no Flutter framework dependencies.
class GetAvailableTafsirBooksUseCase {
  final TafsirRepository _repository;

  const GetAvailableTafsirBooksUseCase(this._repository);

  /// Returns books in the user's library that are downloaded or bundled.
  Future<List<TafsirBook>> call() async {
    final libraryBooks = await _repository.getMyLibraryBooks();
    // Return books ready for reading
    return libraryBooks.where((b) => b.isBundled || b.isDownloaded).toList();
  }
}

