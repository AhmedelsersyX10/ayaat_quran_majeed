/// Domain entities and enumerations for the Index (الفهرس) feature.
/// Pure Dart — no Flutter framework dependencies.

/// Represents the available tabs within the Quran Index bottom sheet.
enum IndexTab {
  /// Tab 0: Surahs list grouped by Juz (Reference 03).
  surahs,

  /// Tab 1: Quarters list with progress indicators (Reference 04).
  quarters,
}

/// Represents the data loading and operational status of the Index feature.
enum IndexStatus {
  /// Initial state before any state restoration or loading begins.
  initial,

  /// Content is actively being loaded.
  loading,

  /// Content has successfully loaded and is ready for interaction.
  success,

  /// Content loaded successfully but contains no items.
  empty,

  /// An error occurred while loading or restoring index state.
  failure,
}

