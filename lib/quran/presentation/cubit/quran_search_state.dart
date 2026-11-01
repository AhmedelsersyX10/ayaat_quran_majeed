part of 'quran_search_cubit.dart';

@immutable
abstract class QuranSearchState {}

class QuranSearchInitial extends QuranSearchState {}

class QuranSearchLoading extends QuranSearchState {}

class QuranSearchLoaded extends QuranSearchState {
  final List<QuranSearchResult> results;

  QuranSearchLoaded(this.results);
}

class QuranSearchError extends QuranSearchState {
  final String message;

  QuranSearchError(this.message);
}
