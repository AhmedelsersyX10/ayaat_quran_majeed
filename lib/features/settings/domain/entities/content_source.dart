/// Categorization of content sources and attributions in the application.
enum ContentSourceCategory {
  /// Quran text engine, Uthmanic font glyphs, and verse metadata.
  quranEngine,

  /// Tafsir commentaries and translations of meanings.
  tafsir,

  /// Recitations audio, reciters list, and verse timing sync data.
  audio,

  /// Astronomical calculation calendar and Hijri date providers.
  calendar,

  /// Open-source packages, Flutter community libraries, and datasets.
  openSource,
}

/// Entity representing an attributed content source or data provider.
class ContentSource {
  final String title;
  final String provider;
  final String description;
  final ContentSourceCategory category;
  final String? url;

  const ContentSource({
    required this.title,
    required this.provider,
    required this.description,
    required this.category,
    this.url,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSource &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          provider == other.provider &&
          description == other.description &&
          category == other.category &&
          url == other.url;

  @override
  int get hashCode =>
      title.hashCode ^
      provider.hashCode ^
      description.hashCode ^
      category.hashCode ^
      url.hashCode;

  @override
  String toString() {
    return 'ContentSource('
        'title: $title, '
        'provider: $provider, '
        'description: $description, '
        'category: $category, '
        'url: $url)';
  }
}
