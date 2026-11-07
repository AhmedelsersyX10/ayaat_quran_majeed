import 'package:ayaat_quran_majeed/features/search/domain/entities/page_search_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/search_query_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/verse_search_result.dart';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSearchRepository implements SearchRepository {
  bool initCalled = false;
  int searchCalls = 0;
  String? lastQuery;
  bool shouldThrow = false;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  Future<SearchQueryResult> search(String query) async {
    searchCalls++;
    lastQuery = query;

    if (shouldThrow) {
      throw Exception('Search failure');
    }

    if (query == '20') {
      return SearchQueryResult(
        verses: const [],
        pageResult: const PageSearchResult(
          pageNumber: 20,
          surahNumber: 2,
          verseNumber: 127,
          surahName: 'البقرة',
        ),
        query: query,
      );
    }

    if (query == 'الحمد') {
      return SearchQueryResult(
        verses: const [
          VerseSearchResult(
            surahNumber: 1,
            verseNumber: 2,
            pageNumber: 1,
            originalText: 'الحمد لله رب العالمين',
            surahName: 'الفاتحة',
            score: 70,
          ),
        ],
        query: query,
      );
    }

    return SearchQueryResult.empty(query: query);
  }
}

void main() {
  group('SearchCubit Tests', () {
    late FakeSearchRepository repository;
    late SearchCubit cubit;

    setUp(() {
      repository = FakeSearchRepository();
      cubit = SearchCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('Initial state is SearchInitial and warms up index', () {
      expect(cubit.state, isA<SearchInitial>());
      expect(repository.initCalled, isTrue);
    });

    test('Empty query resets to SearchInitial without calling search', () async {
      cubit.onQueryChanged('   ');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(cubit.state, isA<SearchInitial>());
      expect(repository.searchCalls, 0);
    });

    test('Debounce collapses rapid typing into single search invocation', () async {
      cubit.onQueryChanged('ا');
      cubit.onQueryChanged('ال');
      cubit.onQueryChanged('الح');
      cubit.onQueryChanged('الحمد');

      expect(repository.searchCalls, 0);

      // Wait past the 300ms debounce
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(repository.searchCalls, 1);
      expect(repository.lastQuery, 'الحمد');
      expect(cubit.state, isA<SearchLoaded>());
      final loaded = cubit.state as SearchLoaded;
      expect(loaded.result.verses, hasLength(1));
    });

    test('searchImmediate executes synchronously without debounce delay', () async {
      cubit.searchImmediate('20');
      expect(cubit.state, isA<SearchLoading>());

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repository.searchCalls, 1);
      expect(cubit.state, isA<SearchLoaded>());
      final loaded = cubit.state as SearchLoaded;
      expect(loaded.result.pageResult?.pageNumber, 20);
    });

    test('clearSearch cancels active debounce and emits SearchInitial', () async {
      cubit.onQueryChanged('الحمد');
      cubit.clearSearch();

      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(repository.searchCalls, 0);
      expect(cubit.state, isA<SearchInitial>());
    });

    test('Emits SearchError when repository throws', () async {
      repository.shouldThrow = true;
      cubit.searchImmediate('test');

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<SearchError>());
      final errorState = cubit.state as SearchError;
      expect(errorState.message, contains('Search failure'));
    });
  });
}
