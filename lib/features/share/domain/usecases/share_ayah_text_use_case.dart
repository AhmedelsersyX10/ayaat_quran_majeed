import '../entities/share_params.dart';
import '../repositories/share_repository.dart';

/// Shares formatted Quran text via native platform share sheet.
class ShareAyahTextUseCase {
  final ShareRepository _repository;

  const ShareAyahTextUseCase(this._repository);

  Future<void> call(ShareParams params) async {
    final formattedText = _repository.formatShareText(params);
    final subject =
        'سورة ${params.surahName} [${params.fromAyah} - ${params.toAyah}]';
    await _repository.shareText(text: formattedText, subject: subject);
  }
}
