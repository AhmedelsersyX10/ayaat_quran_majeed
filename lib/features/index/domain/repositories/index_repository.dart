import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';

/// Domain repository contract for managing Index tab selection, Surah lists, and state persistence.
/// Pure Dart — no Flutter framework dependencies.
abstract class IndexRepository {
  /// Retrieves the persisted active index tab.
  /// Defaults to [IndexTab.surahs] if no tab has been persisted yet.
  Future<IndexTab> getActiveTab();

  /// Persists the selected active index tab.
  Future<void> setActiveTab(IndexTab tab);

  /// Retrieves all 114 Surahs grouped strictly by their starting Juz (1 to 30).
  ///
  /// Guarantees deterministic order: Juz 1 to 30, with Surahs ordered 1 to 114.
  Future<List<JuzGroup>> getSurahsGroupedByJuz();

  /// Retrieves the Surah number of the user's current reading position (1 to 114).
  /// Defaults to 1 (Al-Fatihah) if no position is stored yet.
  Future<int> getCurrentReadingSurah();
}

