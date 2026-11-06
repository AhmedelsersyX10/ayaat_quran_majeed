import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';

/// Domain repository contract for managing Index tab selection and state persistence.
/// Pure Dart — no Flutter framework dependencies.
abstract class IndexRepository {
  /// Retrieves the persisted active index tab.
  /// Defaults to [IndexTab.surahs] if no tab has been persisted yet.
  Future<IndexTab> getActiveTab();

  /// Persists the selected active index tab.
  Future<void> setActiveTab(IndexTab tab);
}

