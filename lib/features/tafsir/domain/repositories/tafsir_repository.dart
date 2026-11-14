import 'package:ayaat_quran_majeed/core/network/cancellation_token.dart';

import '../entities/tafsir_book.dart';
import '../entities/tafsir_verse.dart';

/// Central domain repository contract for Tafsir and Translation books.
///
/// Unifies bundled books (Al-Muyassar, Sahih English) and downloadable books
/// behind a single, offline-first interface.
///
/// Pure Dart — no Flutter framework dependencies.
abstract class TafsirRepository {
  /// Returns the complete catalog of available books (bundled and downloadable).
  Future<List<TafsirBook>> getAvailableBooks();

  /// Retrieves the currently active/selected Tafsir book.
  /// Defaults to Al-Tafsir Al-Muyassar ('ar_muyassar').
  Future<TafsirBook> getSelectedBook();

  /// Sets the currently active Tafsir book by [bookId].
  Future<void> setSelectedBook(String bookId);

  /// Retrieves the user's pinned/ordered books list ("مكتبتي" - Reference 34).
  /// Always includes Al-Tafsir Al-Muyassar by default.
  Future<List<TafsirBook>> getMyLibraryBooks();

  /// Updates the book IDs order in "مكتبتي".
  Future<void> updateMyLibraryOrder(List<String> bookIds);

  /// Pinned a book into "مكتبتي".
  Future<void> addToMyLibrary(String bookId);

  /// Removes a book from "مكتبتي".
  /// Note: The default book ('ar_muyassar') is protected and cannot be deleted.
  Future<void> removeFromMyLibrary(String bookId);

  /// Retrieves the Tafsir/translation for a single ayah.
  /// Throws [TafsirNotFoundException] if the ayah or book is missing.
  Future<TafsirVerse> getAyahTafsir({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  });

  /// Retrieves all ayah tafasir for a specific surah.
  Future<List<TafsirVerse>> getSurahTafsir({
    required String bookId,
    required int surahNumber,
  });

  /// Checks whether a book is locally available on disk (either bundled or downloaded).
  Future<bool> isBookAvailableLocally(String bookId);

  /// Downloads a remote Tafsir book with atomic disk writing and progress reporting.
  Future<void> downloadBook(
    String bookId, {
    void Function(int received, int total)? onProgress,
    AppCancellationToken? cancelToken,
  });

  /// Deletes a downloaded book from local disk storage.
  /// Bundled books cannot be deleted.
  Future<void> deleteDownloadedBook(String bookId);

  /// Clears any in-memory parsed caches to release resources.
  void clearMemoryCache();
}
