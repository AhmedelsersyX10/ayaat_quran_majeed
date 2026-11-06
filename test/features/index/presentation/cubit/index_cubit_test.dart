import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockIndexRepository implements IndexRepository {
  IndexTab activeTab = IndexTab.surahs;
  bool shouldThrow = false;

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
    });

    test('loadState loads saved tab and emits success', () async {
      repository.activeTab = IndexTab.quarters;

      final states = <IndexState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadState();
      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0].status, equals(IndexStatus.loading));
      expect(states[1].status, equals(IndexStatus.success));
      expect(states[1].selectedTab, equals(IndexTab.quarters));

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

