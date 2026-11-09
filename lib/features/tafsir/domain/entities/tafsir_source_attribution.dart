/// Scholarly and digital source attribution for a Tafsir or Translation book.
/// Pure Dart — no Flutter framework dependencies.
class TafsirSourceAttribution {
  /// Primary scholar, author, or institutional publisher.
  /// (e.g. "مجمع الملك فهد لطباعة المصحف الشريف", "ابن كثير الدمشقي")
  final String provider;

  /// Digital project or repository supplying the electronic data.
  /// (e.g. "مشروع آيات - جامعة الملك سعود", "مشروع تنزيل Tanzil")
  final String sourceProject;

  /// Canonical URL for the source project or verification reference.
  final String sourceUrl;

  /// License or usage terms attribution notes.
  final String licenseNotes;

  const TafsirSourceAttribution({
    required this.provider,
    required this.sourceProject,
    required this.sourceUrl,
    required this.licenseNotes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafsirSourceAttribution &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          sourceProject == other.sourceProject &&
          sourceUrl == other.sourceUrl &&
          licenseNotes == other.licenseNotes;

  @override
  int get hashCode =>
      provider.hashCode ^
      sourceProject.hashCode ^
      sourceUrl.hashCode ^
      licenseNotes.hashCode;

  @override
  String toString() =>
      'TafsirSourceAttribution(provider: $provider, sourceProject: $sourceProject)';
}

