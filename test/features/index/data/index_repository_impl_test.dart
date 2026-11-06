import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage_impl.dart';
import 'package:ayaat_quran_majeed/features/index/data/repositories/index_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsStorage storage;
  late AppPreferences preferences;
  late IndexRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = SharedPrefsStorage(prefs);
    preferences = AppPreferences(storage);
    repository = IndexRepositoryImpl(preferences: preferences);
  });

  group('IndexRepositoryImpl Unit Tests', () {
    test('returns IndexTab.surahs by default when storage is empty', () async {
      final tab = await repository.getActiveTab();
      expect(tab, equals(IndexTab.surahs));
    });

    test('persists and restores IndexTab.quarters cleanly', () async {
      await repository.setActiveTab(IndexTab.quarters);
      final tab = await repository.getActiveTab();
      expect(tab, equals(IndexTab.quarters));
    });

    test('persists and restores IndexTab.surahs cleanly', () async {
      await repository.setActiveTab(IndexTab.quarters);
      expect(await repository.getActiveTab(), equals(IndexTab.quarters));

      await repository.setActiveTab(IndexTab.surahs);
      expect(await repository.getActiveTab(), equals(IndexTab.surahs));
    });

    test('defaults to IndexTab.surahs when stored value is invalid/corrupted', () async {
      await preferences.setIndexActiveTab(99);
      final tab = await repository.getActiveTab();
      expect(tab, equals(IndexTab.surahs));
    });

    test('defaults to IndexTab.surahs when stored value is negative', () async {
      await preferences.setIndexActiveTab(-1);
      final tab = await repository.getActiveTab();
      expect(tab, equals(IndexTab.surahs));
    });
  });
}

