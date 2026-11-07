/// Domain value object passed when navigating from search results to reader.
class SearchNavigationTarget {
  final int pageNumber;
  final int? surahNumber;
  final int? ayahNumber;

  const SearchNavigationTarget({
    required this.pageNumber,
    this.surahNumber,
    this.ayahNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchNavigationTarget &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode =>
      pageNumber.hashCode ^ surahNumber.hashCode ^ ayahNumber.hashCode;
}
