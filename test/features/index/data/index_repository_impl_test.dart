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

    test('getSurahsGroupedByJuz returns 30 groups covering all 114 surahs deterministically', () async {
      final groups = await repository.getSurahsGroupedByJuz();

      expect(groups.length, equals(30));

      // Juz 1: Al-Fatihah and Al-Baqarah
      expect(groups[0].juzNumber, equals(1));
      expect(groups[0].nameArabic, equals('الأول'));
      expect(groups[0].startPage, equals(1));
      expect(groups[0].surahs.length, equals(2));
      expect(groups[0].surahs[0].number, equals(1));
      expect(groups[0].surahs[0].nameArabic, equals('الفاتحة'));
      expect(groups[0].surahs[0].isMakki, isTrue);
      expect(groups[0].surahs[1].number, equals(2));
      expect(groups[0].surahs[1].nameArabic, equals('البقرة'));
      expect(groups[0].surahs[1].isMakki, isFalse);

      // Juz 2: 0 surahs start in Juz 2 (spanned by Al-Baqarah)
      expect(groups[1].juzNumber, equals(2));
      expect(groups[1].nameArabic, equals('الثاني'));
      expect(groups[1].startPage, equals(22));
      expect(groups[1].surahs, isEmpty);

      // Juz 3: Al-Imran starts here
      expect(groups[2].juzNumber, equals(3));
      expect(groups[2].nameArabic, equals('الثالث'));
      expect(groups[2].startPage, equals(42));
      expect(groups[2].surahs.length, equals(1));
      expect(groups[2].surahs[0].number, equals(3));
      expect(groups[2].surahs[0].nameArabic, equals('آل عمران'));
      expect(groups[2].surahs[0].pageNumber, equals(50));

      // Juz 4: An-Nisa starts here
      expect(groups[3].juzNumber, equals(4));
      expect(groups[3].nameArabic, equals('الرابع'));
      expect(groups[3].startPage, equals(62));
      expect(groups[3].surahs.length, equals(1));
      expect(groups[3].surahs[0].number, equals(4));
      expect(groups[3].surahs[0].nameArabic, equals('النساء'));
      expect(groups[3].surahs[0].pageNumber, equals(77));

      // Juz 5: 0 surahs start in Juz 5 (spanned by An-Nisa)
      expect(groups[4].juzNumber, equals(5));
      expect(groups[4].nameArabic, equals('الخامس'));
      expect(groups[4].startPage, equals(82));
      expect(groups[4].surahs, isEmpty);

      // Juz 6: Al-Ma'idah starts here
      expect(groups[5].juzNumber, equals(6));
      expect(groups[5].nameArabic, equals('السادس'));
      expect(groups[5].startPage, equals(102));
      expect(groups[5].surahs.length, equals(1));
      expect(groups[5].surahs[0].number, equals(5));
      expect(groups[5].surahs[0].nameArabic, equals('المائدة'));
      expect(groups[5].surahs[0].pageNumber, equals(106));

      // Juz 30: 37 surahs from 78 to 114
      expect(groups[29].juzNumber, equals(30));
      expect(groups[29].nameArabic, equals('الثلاثون'));
      expect(groups[29].startPage, equals(582));
      expect(groups[29].surahs.length, equals(37));
      expect(groups[29].surahs.first.number, equals(78));
      expect(groups[29].surahs.last.number, equals(114));

      // Verify complete coverage: all 114 surahs present exactly once in sequential order
      final allSurahs = groups.expand((g) => g.surahs).toList();
      expect(allSurahs.length, equals(114));
      for (int i = 0; i < 114; i++) {
        expect(allSurahs[i].number, equals(i + 1));
      }
    });

    test('getCurrentReadingSurah returns 1 when storage is empty', () async {
      final currentSurah = await repository.getCurrentReadingSurah();
      expect(currentSurah, equals(1));
    });
  });
}

