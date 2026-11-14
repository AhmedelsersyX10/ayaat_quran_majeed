import 'tafsir_category.dart';
import 'tafsir_source_attribution.dart';

/// Domain entity representing a Tafsir or Translation book.
/// Pure Dart — no Flutter framework dependencies.
class TafsirBook {
  /// Default readable book ID across the application (Al-Tafsir Al-Muyassar).
  static const String defaultBookId = 'ar_muyassar';

  /// Unique identifier (e.g. 'ar_muyassar', 'en_sahih', 'sa3dy').
  final String id;

  /// User-facing localized title (e.g. 'التفسير الميسر', 'تفسير السعدي').
  final String name;

  /// Author or scholar name (e.g. 'مجمع الملك فهد لطباعة المصحف الشريف', 'ابن سعدي').
  final String author;

  /// Detailed subtitle or descriptive summary.
  final String description;

  /// ISO language code (e.g. 'ar', 'en', 'fr').
  final String language;

  /// Localized or native language name (e.g. 'العربية', 'English', 'Français').
  final String languageName;

  /// Category grouping matching Reference 34.
  final TafsirCategory category;

  /// Whether the book is permanently bundled inside the application binary.
  final bool isBundled;

  /// Whether the book data is currently available locally on disk.
  final bool isDownloaded;

  /// Remote URL for downloading the book's JSON dataset (null for bundled books).
  final String? downloadUrl;

  /// Approximate file size in bytes for download progress and UI indication.
  final int? approximateSizeBytes;

  /// Source attribution, project origin, and licensing terms.
  final TafsirSourceAttribution attribution;

  const TafsirBook({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.language,
    required this.languageName,
    required this.category,
    required this.isBundled,
    required this.isDownloaded,
    this.downloadUrl,
    this.approximateSizeBytes,
    required this.attribution,
  });

  /// Creates a copy with optionally overridden properties.
  TafsirBook copyWith({
    String? id,
    String? name,
    String? author,
    String? description,
    String? language,
    String? languageName,
    TafsirCategory? category,
    bool? isBundled,
    bool? isDownloaded,
    String? downloadUrl,
    int? approximateSizeBytes,
    TafsirSourceAttribution? attribution,
  }) {
    return TafsirBook(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      description: description ?? this.description,
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,
      category: category ?? this.category,
      isBundled: isBundled ?? this.isBundled,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      approximateSizeBytes: approximateSizeBytes ?? this.approximateSizeBytes,
      attribution: attribution ?? this.attribution,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafsirBook &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          author == other.author &&
          description == other.description &&
          language == other.language &&
          languageName == other.languageName &&
          category == other.category &&
          isBundled == other.isBundled &&
          isDownloaded == other.isDownloaded &&
          downloadUrl == other.downloadUrl &&
          approximateSizeBytes == other.approximateSizeBytes &&
          attribution == other.attribution;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      author.hashCode ^
      description.hashCode ^
      language.hashCode ^
      languageName.hashCode ^
      category.hashCode ^
      isBundled.hashCode ^
      isDownloaded.hashCode ^
      downloadUrl.hashCode ^
      approximateSizeBytes.hashCode ^
      attribution.hashCode;

  @override
  String toString() =>
      'TafsirBook(id: $id, name: $name, isDownloaded: $isDownloaded)';
}
