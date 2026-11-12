import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';

/// Contract for the Starred Verses repository.
/// Pure Dart — no Flutter framework dependencies.
abstract class StarredRepository {
  /// Loads all starred verses, resolving Quran metadata and text dynamically.
  Future<List<StarredAyahItem>> getStarredVerses();

  /// Toggles the starred state of an Ayah idempotently:
  /// - If unstarred: adds it.
  /// - If already starred: removes it.
  Future<void> toggleStarred(int surahNumber, int verseNumber);

  /// Idempotently adds a verse to starred verses (no-op if already starred).
  Future<void> addStarred(int surahNumber, int verseNumber);

  /// Idempotently removes a verse from starred verses (no-op if not starred).
  Future<void> removeStarred(int surahNumber, int verseNumber);

  /// Checks whether a given verse is starred.
  Future<bool> isStarred(int surahNumber, int verseNumber);
}

