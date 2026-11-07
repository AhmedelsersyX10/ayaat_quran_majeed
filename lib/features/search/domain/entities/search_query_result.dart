import 'page_search_result.dart';
import 'verse_search_result.dart';

/// Aggregates results of a search query including verse matches and optional page match.
class SearchQueryResult {
  final List<VerseSearchResult> verses;
  final PageSearchResult? pageResult;
  final String query;

  const SearchQueryResult({
    required this.verses,
    this.pageResult,
    required this.query,
  });

  const SearchQueryResult.empty({this.query = ''})
      : verses = const [],
        pageResult = null;

  int get totalOccurrences => verses.length;
  bool get isEmpty => verses.isEmpty && pageResult == null;
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchQueryResult &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          pageResult == other.pageResult &&
          verses.length == other.verses.length;

  @override
  int get hashCode => query.hashCode ^ pageResult.hashCode ^ verses.length.hashCode;
}
