import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/surah_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';

/// Data layer implementation of [IndexRepository] persisting tab preferences
/// and deriving canonical Quran indexing data directly from the Quran engine.
/// Pure Dart — no Flutter framework dependencies.
class IndexRepositoryImpl implements IndexRepository {
  final AppPreferences _preferences;
  final QuranMetadataService _metadataService;
  final QuranReadingRepository _readingRepository;

  const IndexRepositoryImpl({
    required AppPreferences preferences,
    QuranMetadataService metadataService = const QuranMetadataService(),
    QuranReadingRepository readingRepository = const QuranReadingRepository(),
  })  : _preferences = preferences,
        _metadataService = metadataService,
        _readingRepository = readingRepository;

  @override
  Future<IndexTab> getActiveTab() async {
    final storedIndex = _preferences.indexActiveTab;
    if (storedIndex >= 0 && storedIndex < IndexTab.values.length) {
      return IndexTab.values[storedIndex];
    }
    return IndexTab.surahs;
  }

  @override
  Future<void> setActiveTab(IndexTab tab) async {
    await _preferences.setIndexActiveTab(tab.index);
  }

  @override
  Future<List<JuzGroup>> getSurahsGroupedByJuz() async {
    final Map<int, List<SurahIndexItem>> juzSurahsMap = {};
    for (int j = 1; j <= 30; j++) {
      juzSurahsMap[j] = [];
    }

    // Group each of the 114 Surahs by its starting Juz (verse 1)
    for (int s = 1; s <= 114; s++) {
      final startJuz = _metadataService.getJuzNumber(s, 1);
      final surahItem = SurahIndexItem(
        number: s,
        nameArabic: _metadataService.getSurahNameArabic(s),
        pageNumber: _metadataService.getPageNumber(s, 1),
        verseCount: _metadataService.getVerseCount(s),
        isMakki: _metadataService.isMakki(s),
        startJuz: startJuz,
      );
      juzSurahsMap[startJuz]?.add(surahItem);
    }

    final List<JuzGroup> groups = [];
    for (int j = 1; j <= 30; j++) {
      groups.add(
        JuzGroup(
          juzNumber: j,
          nameArabic: _metadataService.getJuzNameArabic(j),
          startPage: _metadataService.getJuzStartPage(j),
          surahs: List<SurahIndexItem>.unmodifiable(juzSurahsMap[j] ?? const []),
        ),
      );
    }

    return List<JuzGroup>.unmodifiable(groups);
  }

  @override
  Future<int> getCurrentReadingSurah() async {
    try {
      final position = await _readingRepository.loadLastPosition();
      return position.surahNumber.clamp(1, 114);
    } catch (_) {
      return 1;
    }
  }
}

