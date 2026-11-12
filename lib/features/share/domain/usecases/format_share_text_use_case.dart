import '../entities/share_params.dart';
import '../repositories/share_repository.dart';

/// Formats the verses, metadata, optional note, and optional tafsir into a standardized share string.
class FormatShareTextUseCase {
  final ShareRepository _repository;

  const FormatShareTextUseCase(this._repository);

  String call(ShareParams params) {
    return _repository.formatShareText(params);
  }
}
