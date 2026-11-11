import 'package:flutter/material.dart' show Color;

/// Represents a Quran bookmark item conforming to Screens 11 & 27.
///
/// Features 4 standard colored bookmarks (Red, Yellow, Green, Blue)
/// with support for unassigning, renaming, re-coloring, and custom bookmarks.
class BookmarkItem {
  final String id;
  final String name;
  final String colorHex;
  final int? surahNumber;
  final int? verseNumber;
  final int? pageNumber;
  final DateTime? updatedAt;
  final bool isDefault;

  const BookmarkItem({
    required this.id,
    required this.name,
    required this.colorHex,
    this.surahNumber,
    this.verseNumber,
    this.pageNumber,
    this.updatedAt,
    this.isDefault = false,
  });

  /// Whether this bookmark is currently assigned to a specific Ayah.
  bool get isAssigned => surahNumber != null && verseNumber != null;

  /// Parsed Flutter [Color] from the hex string.
  Color get color {
    final cleanHex = colorHex.replaceFirst('#', '').padLeft(8, 'f');
    return Color(int.parse(cleanHex, radix: 16));
  }

  /// Backward compatibility alias for legacy code.
  int get suraNumber => surahNumber ?? 0;

  // --- 4 Standard Slots IDs ---
  static const String defaultRedId = 'red';
  static const String defaultYellowId = 'yellow';
  static const String defaultGreenId = 'green';
  static const String defaultBlueId = 'blue';

  // --- 4 Standard Initial Bookmark Slots (Screens 11 & 27) ---
  static BookmarkItem defaultRed() => const BookmarkItem(
    id: defaultRedId,
    name: 'الأحمر',
    colorHex: '#C9484A',
    isDefault: true,
  );

  static BookmarkItem defaultYellow() => const BookmarkItem(
    id: defaultYellowId,
    name: 'الأصفر',
    colorHex: '#D7AC3C',
    isDefault: true,
  );

  static BookmarkItem defaultGreen() => const BookmarkItem(
    id: defaultGreenId,
    name: 'الأخضر',
    colorHex: '#62A77B',
    isDefault: true,
  );

  static BookmarkItem defaultBlue() => const BookmarkItem(
    id: defaultBlueId,
    name: 'الأزرق',
    colorHex: '#218FC9',
    isDefault: true,
  );

  /// Returns the 4 default bookmark slots in standard display order.
  static List<BookmarkItem> defaultSlots() => [
    defaultRed(),
    defaultYellow(),
    defaultGreen(),
    defaultBlue(),
  ];

  BookmarkItem copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? surahNumber,
    int? verseNumber,
    int? pageNumber,
    DateTime? updatedAt,
    bool? isDefault,
    bool clearAssignment = false,
  }) {
    return BookmarkItem(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      surahNumber: clearAssignment ? null : (surahNumber ?? this.surahNumber),
      verseNumber: clearAssignment ? null : (verseNumber ?? this.verseNumber),
      pageNumber: clearAssignment ? null : (pageNumber ?? this.pageNumber),
      updatedAt: clearAssignment ? null : (updatedAt ?? this.updatedAt),
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkItem &&
        other.id == id &&
        other.name == name &&
        other.colorHex == colorHex &&
        other.surahNumber == surahNumber &&
        other.verseNumber == verseNumber &&
        other.pageNumber == pageNumber &&
        other.updatedAt == updatedAt &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorHex,
    surahNumber,
    verseNumber,
    pageNumber,
    updatedAt,
    isDefault,
  );
}
