import 'package:ayaat_quran_majeed/features/starred/data/repositories/starred_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/starred_repository_impl_test.dart';

void main() {
  group('StarredCubit Unit Tests', () {
    late FakeStarredLocalDataSource localDataSource;
    late StarredRepositoryImpl repository;
    late StarredCubit cubit;

    setUp(() {
      localDataSource = FakeStarredLocalDataSource();
      repository = StarredRepositoryImpl(localDataSource: localDataSource);
      cubit = StarredCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state has isLoading true and empty collections', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.groups, isEmpty);
      expect(cubit.state.starredKeys, isEmpty);
    });

    test('loadStarredVerses emits success with empty state when no items', () async {
      await cubit.loadStarredVerses();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.groups, isEmpty);
    });

    test('loadStarredVerses emits populated items and deterministic groups', () async {
      await repository.addStarred(2, 4);
      await repository.addStarred(2, 2);
      await repository.addStarred(1, 1);

      await cubit.loadStarredVerses();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isEmpty, isFalse);
      expect(cubit.state.items.length, equals(3));
      expect(cubit.state.groups.length, equals(2));

      // Surahs sorted ascending: 1 (الفاتحة), then 2 (البقرة)
      expect(cubit.state.groups[0].surahNumber, equals(1));
      expect(cubit.state.groups[1].surahNumber, equals(2));

      // Verses inside Al-Baqarah sorted: 2, then 4
      expect(cubit.state.groups[1].items[0].verseNumber, equals(2));
      expect(cubit.state.groups[1].items[1].verseNumber, equals(4));

      expect(cubit.isStarred(1, 1), isTrue);
      expect(cubit.isStarred(2, 2), isTrue);
      expect(cubit.isStarred(2, 4), isTrue);
      expect(cubit.isStarred(2, 3), isFalse);
    });

    test('toggleStarred toggles verse and updates groups and keys', () async {
      await cubit.loadStarredVerses();
      expect(cubit.isStarred(2, 255), isFalse);

      await cubit.toggleStarred(2, 255);
      expect(cubit.isStarred(2, 255), isTrue);
      expect(cubit.state.items.length, equals(1));
      expect(cubit.state.groups.length, equals(1));

      await cubit.toggleStarred(2, 255);
      expect(cubit.isStarred(2, 255), isFalse);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.groups, isEmpty);
      expect(cubit.state.isEmpty, isTrue);
    });

    test('addStarred and removeStarred are idempotent', () async {
      await cubit.loadStarredVerses();

      await cubit.addStarred(2, 10);
      expect(cubit.isStarred(2, 10), isTrue);
      expect(cubit.state.items.length, equals(1));

      // Repeating add is no-op
      await cubit.addStarred(2, 10);
      expect(cubit.state.items.length, equals(1));

      await cubit.removeStarred(2, 10);
      expect(cubit.isStarred(2, 10), isFalse);
      expect(cubit.state.items, isEmpty);

      // Repeating remove is no-op
      await cubit.removeStarred(2, 10);
      expect(cubit.state.items, isEmpty);
    });
  });
}

