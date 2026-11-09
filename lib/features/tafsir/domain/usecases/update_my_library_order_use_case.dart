import '../repositories/tafsir_repository.dart';

/// Business use case updating the order of pinned books in "مكتبتي".
/// Pure Dart — no Flutter framework dependencies.
class UpdateMyLibraryOrderUseCase {
  final TafsirRepository _repository;

  const UpdateMyLibraryOrderUseCase(this._repository);

  Future<void> call(List<String> bookIds) => _repository.updateMyLibraryOrder(bookIds);
}

