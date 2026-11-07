import '../entities/search_query_result.dart';

/// Contract for search repository (Clean Architecture Domain).
abstract class SearchRepository {
  /// Prepares the in-memory search index.
  Future<void> init();

  /// Executes search by page number or Quranic text.
  Future<SearchQueryResult> search(String query);
}
