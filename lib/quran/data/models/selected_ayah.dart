/// Represents an Ayah selected by the user in the Mushaf reader.
///
/// Pure Dart entity/model containing Surah number, Ayah number,
/// and Mushaf page number. Used for highlighting and opening
/// the Ayah Options bottom sheet (references 19 & 20).
class SelectedAyah {
  final int surahNumber;
  final int ayahNumber;
  final int pageNumber;

  const SelectedAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.pageNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedAyah &&
          other.surahNumber == surahNumber &&
          other.ayahNumber == ayahNumber &&
          other.pageNumber == pageNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, pageNumber);

  @override
  String toString() =>
      'SelectedAyah(surah: $surahNumber, ayah: $ayahNumber, page: $pageNumber)';
}

