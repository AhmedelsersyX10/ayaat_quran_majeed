import 'package:ayaat_quran_majeed/features/search/domain/entities/search_query_result.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class SearchState {
  const SearchState();
}

/// Initial state when search is opened or query is empty.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// State while search is running.
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// State when search completes with results (verses and/or page).
class SearchLoaded extends SearchState {
  final SearchQueryResult result;

  const SearchLoaded(this.result);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchLoaded &&
          runtimeType == other.runtimeType &&
          result == other.result;

  @override
  int get hashCode => result.hashCode;
}

/// State when search encountered an error.
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
