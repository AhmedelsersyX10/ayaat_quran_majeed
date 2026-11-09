import '../../domain/entities/tafsir_book.dart';
import '../../domain/entities/tafsir_category.dart';
import '../../domain/entities/tafsir_source_attribution.dart';

/// Data model representing a book in the Tafsir catalog.
class TafsirBookModel {
  final String id;
  final String name;
  final String author;
  final String description;
  final String language;
  final String languageName;
  final TafsirCategory category;
  final bool isBundled;
  final String? downloadUrl;
  final int? approximateSizeBytes;
  final TafsirSourceAttribution attribution;

  const TafsirBookModel({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.language,
    required this.languageName,
    required this.category,
    required this.isBundled,
    this.downloadUrl,
    this.approximateSizeBytes,
    required this.attribution,
  });

  /// Maps this model to domain entity [TafsirBook], enriched with local download state.
  TafsirBook toEntity({required bool isDownloaded}) {
    return TafsirBook(
      id: id,
      name: name,
      author: author,
      description: description,
      language: language,
      languageName: languageName,
      category: category,
      isBundled: isBundled,
      isDownloaded: isBundled || isDownloaded,
      downloadUrl: downloadUrl,
      approximateSizeBytes: approximateSizeBytes,
      attribution: attribution,
    );
  }

  /// Deserializes model from JSON map.
  factory TafsirBookModel.fromJson(Map<String, dynamic> json) {
    return TafsirBookModel(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      languageName: json['languageName'] as String,
      category: TafsirCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TafsirCategory.arabicTafsir,
      ),
      isBundled: json['isBundled'] as bool? ?? false,
      downloadUrl: json['downloadUrl'] as String?,
      approximateSizeBytes: json['approximateSizeBytes'] as int?,
      attribution: TafsirSourceAttribution(
        provider: json['attributionProvider'] as String? ?? '',
        sourceProject: json['attributionProject'] as String? ?? '',
        sourceUrl: json['attributionUrl'] as String? ?? '',
        licenseNotes: json['attributionLicense'] as String? ?? '',
      ),
    );
  }

  /// Serializes model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'description': description,
      'language': language,
      'languageName': languageName,
      'category': category.name,
      'isBundled': isBundled,
      'downloadUrl': downloadUrl,
      'approximateSizeBytes': approximateSizeBytes,
      'attributionProvider': attribution.provider,
      'attributionProject': attribution.sourceProject,
      'attributionUrl': attribution.sourceUrl,
      'attributionLicense': attribution.licenseNotes,
    };
  }
}

