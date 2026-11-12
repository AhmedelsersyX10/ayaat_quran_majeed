import 'package:ayaat_quran_majeed/features/starred/data/datasources/starred_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/starred/data/models/starred_ayah_model.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/repositories/starred_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

class StarredRepositoryImpl implements StarredRepository {
  final StarredLocalDataSource _localDataSource;
  final QuranMetadataService _metadataService;

  StarredRepositoryImpl({
    required StarredLocalDataSource localDataSource,
    QuranMetadataService? metadataService,
  })  : _localDataSource = localDataSource,
        _metadataService = metadataService ?? const QuranMetadataService();

  @override
  Future<List<StarredAyahItem>> getStarredVerses() async {
    final models = await _localDataSource.getStarredVerses();
    return models
        .map((model) => model.toEntity(metadataService: _metadataService))
        .toList(growable: false);
  }

  @override
  Future<void> addStarred(int surahNumber, int verseNumber) async {
    final safeSurah = surahNumber.clamp(1, 114);
    final maxAyah = _metadataService.getVerseCount(safeSurah);
    final safeAyah = verseNumber.clamp(1, maxAyah > 0 ? maxAyah : 286);

    final currentModels = (await _localDataSource.getStarredVerses()).toList();
    final bool alreadyExists = currentModels.any(
      (m) => m.surahNumber == safeSurah && m.verseNumber == safeAyah,
    );

    if (!alreadyExists) {
      currentModels.add(
        StarredAyahModel(
          surahNumber: safeSurah,
          verseNumber: safeAyah,
          createdAt: DateTime.now(),
        ),
      );
      await _localDataSource.saveStarredVerses(currentModels);
    }
  }

  @override
  Future<void> removeStarred(int surahNumber, int verseNumber) async {
    final safeSurah = surahNumber.clamp(1, 114);
    final maxAyah = _metadataService.getVerseCount(safeSurah);
    final safeAyah = verseNumber.clamp(1, maxAyah > 0 ? maxAyah : 286);

    final currentModels = (await _localDataSource.getStarredVerses()).toList();
    final initialLength = currentModels.length;

    currentModels.removeWhere(
      (m) => m.surahNumber == safeSurah && m.verseNumber == safeAyah,
    );

    if (currentModels.length != initialLength) {
      await _localDataSource.saveStarredVerses(currentModels);
    }
  }

  @override
  Future<void> toggleStarred(int surahNumber, int verseNumber) async {
    final safeSurah = surahNumber.clamp(1, 114);
    final maxAyah = _metadataService.getVerseCount(safeSurah);
    final safeAyah = verseNumber.clamp(1, maxAyah > 0 ? maxAyah : 286);

    final isCurrentlyStarred = await isStarred(safeSurah, safeAyah);
    if (isCurrentlyStarred) {
      await removeStarred(safeSurah, safeAyah);
    } else {
      await addStarred(safeSurah, safeAyah);
    }
  }

  @override
  Future<bool> isStarred(int surahNumber, int verseNumber) async {
    final safeSurah = surahNumber.clamp(1, 114);
    final maxAyah = _metadataService.getVerseCount(safeSurah);
    final safeAyah = verseNumber.clamp(1, maxAyah > 0 ? maxAyah : 286);

    final models = await _localDataSource.getStarredVerses();
    return models.any(
      (m) => m.surahNumber == safeSurah && m.verseNumber == safeAyah,
    );
  }
}

