import '../entities/tafsir_book.dart';
import '../repositories/tafsir_repository.dart';

/// Business use case retrieving the currently active Tafsir book.
/// Pure Dart — no Flutter framework dependencies.
class GetSelectedTafsirBookUseCase {
  final TafsirRepository _repository;

  const GetSelectedTafsirBookUseCase(this._repository);

  Future<TafsirBook> call() => _repository.getSelectedBook();
}

