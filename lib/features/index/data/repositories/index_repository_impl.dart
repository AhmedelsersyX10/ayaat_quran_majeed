import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';

/// Data layer implementation of [IndexRepository] persisting tab preferences.
/// Pure Dart — no Flutter framework dependencies.
class IndexRepositoryImpl implements IndexRepository {
  final AppPreferences _preferences;

  const IndexRepositoryImpl({required AppPreferences preferences})
      : _preferences = preferences;

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
}

