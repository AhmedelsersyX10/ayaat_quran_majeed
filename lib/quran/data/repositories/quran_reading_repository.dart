import 'dart:convert';

import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Pure entity/model representing a stable reading position in the Mushaf.
/// Persists stable domain identifiers only, never transient widget state.
class ReadingPosition {
  final int page;
  final int surahNumber;
  final int ayahNumber;
  final String? viewMode;

  const ReadingPosition({
    required this.page,
    required this.surahNumber,
    required this.ayahNumber,
    this.viewMode,
  });

  ReadingPosition copyWith({
    int? page,
    int? surahNumber,
    int? ayahNumber,
    String? viewMode,
  }) {
    return ReadingPosition(
      page: page ?? this.page,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'viewMode': viewMode,
    };
  }

  factory ReadingPosition.fromMap(Map<String, dynamic> map) {
    return ReadingPosition(
      page: (map['page'] as num?)?.toInt() ?? 1,
      surahNumber: (map['surahNumber'] as num?)?.toInt() ?? 1,
      ayahNumber: (map['ayahNumber'] as num?)?.toInt() ?? 1,
      viewMode: map['viewMode'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReadingPosition.fromJson(String source) =>
      ReadingPosition.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPosition &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber &&
          viewMode == other.viewMode;

  @override
  int get hashCode =>
      page.hashCode ^
      surahNumber.hashCode ^
      ayahNumber.hashCode ^
      viewMode.hashCode;

  @override
  String toString() =>
      'ReadingPosition(page: $page, surah: $surahNumber, ayah: $ayahNumber, mode: $viewMode)';
}

/// Repository responsible for persisting, validating, and restoring the
/// current Quran reading position.
///
/// This wraps the legacy `lastRead` Hive key (storing only page number)
/// and persists a richer structured `lastReadingPosition` payload.
/// Normalizes and handles corrupt/stale positions gracefully.
class QuranReadingRepository {
  static const String _legacyLastReadKey = 'lastRead';
  static const String _lastReadingPositionKey = 'lastReadingPosition';
  final QuranMetadataService _metadataService;

  const QuranReadingRepository({
    QuranMetadataService metadataService = const QuranMetadataService(),
  }) : _metadataService = metadataService;

  QuranMetadataService get metadataService => _metadataService;

  /// Load the last reading position with strict validation and normalization.
  ///
  /// Priority:
  /// 1. Structured `lastReadingPosition` (page + surah + ayah)
  /// 2. Legacy `lastRead` page number mapped to (page, first surah/ayah)
  /// 3. Default fallback to Al-Fatiha: page 1, surah 1, ayah 1
  Future<ReadingPosition> loadLastPosition() async {
    final dynamic stored = getValue(_lastReadingPositionKey);
    if (stored is String && stored.isNotEmpty) {
      try {
        final parsed = ReadingPosition.fromJson(stored);
        final normalized = validateAndNormalize(parsed);
        if (normalized != parsed) {
          await savePosition(normalized);
        }
        return normalized;
      } catch (_) {
        // Fall through to legacy handling.
      }
    } else if (stored is Map<String, dynamic>) {
      try {
        final parsed = ReadingPosition.fromMap(stored);
        final normalized = validateAndNormalize(parsed);
        if (normalized != parsed) {
          await savePosition(normalized);
        }
        return normalized;
      } catch (_) {
        // Fall through to legacy handling.
      }
    }

    final dynamic legacy = getValue(_legacyLastReadKey);
    if (legacy is int && legacy > 0) {
      final safePage = legacy.clamp(1, 604);
      final mapped = _mapPageToReadingPosition(safePage);
      await savePosition(mapped);
      return mapped;
    }

    // First-time open → Al-Fatiha (page 1, surah 1, ayah 1)
    final fallback = _mapPageToReadingPosition(1);
    await savePosition(fallback);
    return fallback;
  }

  /// Persist the current reading position after validating and normalizing.
  Future<void> savePosition(ReadingPosition position) async {
    final normalized = validateAndNormalize(position);

    // Keep legacy `lastRead` updated for backward compatibility
    updateValue(_legacyLastReadKey, normalized.page);

    // Store the richer representation
    updateValue(_lastReadingPositionKey, normalized.toJson());
  }

  /// Validates and normalizes [rawPosition] against [QuranMetadataService].
  ///
  /// Guarantees:
  /// - `page` is strictly clamped between 1 and 604.
  /// - `surahNumber` is between 1 and 114.
  /// - `ayahNumber` is between 1 and total verses in that surah.
  /// - `surahNumber` and `ayahNumber` belong to `page`. If stale or mismatched,
  ///   they are automatically synchronized to the first verse on `page`.
  ReadingPosition validateAndNormalize(ReadingPosition rawPosition) {
    final int safePage = rawPosition.page.clamp(1, 604);

    try {
      final pageData = _metadataService.getPageData(safePage);
      if (pageData.isEmpty) {
        return _mapPageToReadingPosition(safePage).copyWith(
          viewMode: rawPosition.viewMode,
        );
      }

      // Check if the given (surah, ayah) exists on safePage
      for (final segment in pageData) {
        final int s = segment['surah'] as int;
        final int start = segment['start'] as int;
        final int end = segment['end'] as int;
        if (rawPosition.surahNumber == s &&
            rawPosition.ayahNumber >= start &&
            rawPosition.ayahNumber <= end) {
          return rawPosition.copyWith(page: safePage);
        }
      }

      // Mismatched / stale: normalize to the first verse of the page
      final firstSegment = pageData.first;
      return ReadingPosition(
        page: safePage,
        surahNumber: firstSegment['surah'] as int,
        ayahNumber: firstSegment['start'] as int,
        viewMode: rawPosition.viewMode,
      );
    } catch (_) {
      return _mapPageToReadingPosition(safePage).copyWith(
        viewMode: rawPosition.viewMode,
      );
    }
  }

  /// Helper to map a mushaf page number to a concrete surah and ayah
  /// using the [QuranMetadataService].
  ReadingPosition _mapPageToReadingPosition(int page) {
    try {
      final pageData = _metadataService.getPageData(page);
      if (pageData.isNotEmpty) {
        final firstSegment = pageData.first;
        final int surah = firstSegment['surah'] as int;
        final int ayah = firstSegment['start'] as int;

        return ReadingPosition(
          page: page,
          surahNumber: surah,
          ayahNumber: ayah,
        );
      }
    } catch (_) {
      // If anything goes wrong, fall back to Al-Fatiha.
    }

    return const ReadingPosition(
      page: 1,
      surahNumber: 1,
      ayahNumber: 1,
    );
  }
}
