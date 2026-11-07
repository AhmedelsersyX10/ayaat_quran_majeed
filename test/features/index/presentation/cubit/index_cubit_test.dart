import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/quarter_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/surah_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockIndexRepository implements IndexRepository {
  IndexTab activeTab = IndexTab.surahs;
  bool shouldThrow = false;
  List<JuzGroup> groupsToReturn = [
    const JuzGroup(
      juzNumber: 1,
      nameArabic: 'الأول',
      startPage: 1,
      surahs: [
        SurahIndexItem(
          number: 1,
          nameArabic: 'الفاتحة',
          pageNumber: 1,
          verseCount: 7,
          isMakki: true,
          startJuz: 1,
        ),
      ],
    ),
  ];
  int currentSurahToReturn = 2;
  List<QuarterIndexItem> quartersToReturn = [
    const QuarterIndexItem(
      quarterNumber: 1,
      hizbNumber: 1,
      quarterInHizb: 1,
      surahNumber: 1,
      surahNameArabic: 'الفاتحة',
      ayahNumber: 1,
      pageNumber: 1,
      ayahText: 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ',
    ),
  ];
  int currentQuarterToReturn = 1;

  @override
  Future<IndexTab> getActiveTab() async {
    if (shouldThrow) throw Exception('Storage error');
    return activeTab;
  }

  @override
  Future<void> setActiveTab(IndexTab tab) async {
    if (shouldThrow) throw Exception('Storage error');
    activeTab = tab;
  }

  @override
  Future<List<JuzGroup>> getSurahsGroupedByJuz() async {
    if (shouldThrow) throw Exception('Metadata error');
    return groupsToReturn;
  }

  @override
  Future<int> getCurrentReadingSurah() async {
    if (shouldThrow) throw Exception('Reading error');
    return currentSurahToReturn;
  }

  @override
  Future<List<QuarterIndexItem>> getQuarters() async {
    if (shouldThrow) throw Exception('Quarters error');
    return quartersToReturn;
  }

  @override
  Future<int> getCurrentReadingQuarter() async {
    if (shouldThrow) throw Exception('Reading quarter error');
    return currentQuarterToReturn;
  }
}

void main() {
  late MockIndexRepository repository;
  late IndexCubit cubit;

  setUp(() {
    repository = MockIndexRepository();
    cubit = IndexCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('IndexCubit Unit Tests', () {
    test('initial state defaults to IndexTab.surahs with IndexStatus.initial', () {
      expect(cubit.state.selectedTab, equals(IndexTab.surahs));
      expect(cubit.state.status, equals(IndexStatus.initial));
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isSuccess, isFalse);
      expect(cubit.state.isFailure, isFalse);
      expect(cubit.state.isEmpty, isFalse);
      expect(cubit.state.juzGroups, isEmpty);
      expect(cubit.state.currentReadingSurah, equals(1));
      expect(cubit.state.quarters, isEmpty);
      expect(cubit.state.currentReadingQuarter, equals(1));
    });

    test('loadState loads saved tab, groups, quarters, and reading position then emits success', () async {
      repository.activeTab = IndexTab.quarters;
      repository.currentSurahToReturn = 2;
      repository.currentQuarterToReturn = 5;

      final states = <IndexState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadState();
      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0].status, equals(IndexStatus.loading));
      expect(states[1].status, equals(IndexStatus.success));
      expect(states[1].selectedTab, equals(IndexTab.quarters));
      expect(states[1].juzGroups.length, equals(1));
      expect(states[1].currentReadingSurah, equals(2));
      expect(states[1].quarters.length, equals(1));
      expect(states[1].currentReadingQuarter, equals(5));

      await subscription.cancel();
    });

    test('loadState emits empty status when both juzGroups and quarters are empty', () async {
      repository.groupsToReturn = [];
      repository.quartersToReturn = [];

      final states = <IndexState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadState();
      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0].status, equals(IndexStatus.loading));
      expect(states[1].status, equals(IndexStatus.empty));

      await subscription.cancel();
    });

    test('loadState emits failure when repository throws', () async {
      repository.shouldThrow = true;

      final states = <IndexState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadState();
      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0].status, equals(IndexStatus.loading));
      expect(states[1].status, equals(IndexStatus.failure));
      expect(states[1].errorMessage, equals(AppStrings.indexLoadFailed));

      await subscription.cancel();
    });

    test('selectTab changes selected tab and persists to repository', () async {
      await cubit.selectTab(IndexTab.quarters);

      expect(cubit.state.selectedTab, equals(IndexTab.quarters));
      expect(cubit.state.status, equals(IndexStatus.success));
      expect(repository.activeTab, equals(IndexTab.quarters));

      await cubit.selectTab(IndexTab.surahs);
      expect(cubit.state.selectedTab, equals(IndexTab.surahs));
      expect(repository.activeTab, equals(IndexTab.surahs));
    });

    test('selectTab ignores redundant selection if tab is already active', () async {
      await cubit.selectTab(IndexTab.surahs);
      final initialStatesCount = cubit.state;

      // Select same tab again
      await cubit.selectTab(IndexTab.surahs);
      expect(cubit.state, equals(initialStatesCount));
    });

    test('refreshReadingPosition updates current reading position when changed', () async {
      await cubit.loadState();
      expect(cubit.state.currentReadingSurah, equals(2));
      expect(cubit.state.currentReadingQuarter, equals(1));

      repository.currentSurahToReturn = 36;
      repository.currentQuarterToReturn = 145;
      await cubit.refreshReadingPosition();
      expect(cubit.state.currentReadingSurah, equals(36));
      expect(cubit.state.currentReadingQuarter, equals(145));
    });

    test('setStatus updates status and error message cleanly', () {
      cubit.setStatus(IndexStatus.empty);
      expect(cubit.state.isEmpty, isTrue);

      cubit.setStatus(IndexStatus.failure, errorMessage: 'custom_error');
      expect(cubit.state.isFailure, isTrue);
      expect(cubit.state.errorMessage, equals('custom_error'));
    });

    test('retry re-invokes loadState', () async {
      repository.activeTab = IndexTab.quarters;
      await cubit.retry();

      expect(cubit.state.selectedTab, equals(IndexTab.quarters));
      expect(cubit.state.status, equals(IndexStatus.success));
    });
  });
}
