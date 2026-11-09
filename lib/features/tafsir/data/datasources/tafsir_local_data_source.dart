import 'dart:convert';
import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translations/muyassar.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translations/sahih_english.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/tafsir_catalog.dart';
import '../models/tafsir_verse_model.dart';

/// Contract for local access and caching of Tafsir and Translation datasets.
abstract class TafsirLocalDataSource {
  /// Checks whether a book is locally available on disk (bundled or downloaded).
  Future<bool> isBookAvailable(String bookId);

  /// Checks specifically if a remote book has been downloaded to local storage.
  Future<bool> isBookDownloaded(String bookId);

  /// Returns the list of all currently downloaded book IDs.
  Future<List<String>> getDownloadedBookIds();

  /// Retrieves the plain text tafsir for [surahNumber] and [ayahNumber] in [bookId].
  /// Returns null if not found.
  Future<String?> getAyahText({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  });

  /// Retrieves all verses' tafsir texts for [surahNumber] in [bookId] as map of {ayah: text}.
  /// Returns null if book data is not found or not downloaded.
  Future<Map<int, String>?> getSurahAyat({
    required String bookId,
    required int surahNumber,
  });

  /// Resolves the canonical file path where [bookId] is stored.
  Future<String> getBookFilePath(String bookId);

  /// Saves a downloaded temporary file [sourceTempPath] atomically as the book's dataset.
  Future<void> saveDownloadedFile(String bookId, String sourceTempPath);

  /// Deletes a downloaded book file from storage and clears its in-memory cache.
  Future<void> deleteDownloadedBook(String bookId);

  /// Clears in-memory cache for all books.
  void clearMemoryCache();

  /// Clears in-memory cache for a single book.
  void clearBookMemoryCache(String bookId);
}

/// Implementation of [TafsirLocalDataSource] managing bundled Dart datasets,
/// downloaded JSON datasets, and an in-memory O(1) indexed lookup cache.
class TafsirLocalDataSourceImpl implements TafsirLocalDataSource {
  final Future<Directory> Function()? _customDocumentsDirectory;

  /// In-memory cache mapping: bookId -> { surahNumber -> { ayahNumber -> tafsirText } }
  final Map<String, Map<int, Map<int, String>>> _memoryCache = {};

  TafsirLocalDataSourceImpl({
    Future<Directory> Function()? customDocumentsDirectory,
  }) : _customDocumentsDirectory = customDocumentsDirectory;

  Future<Directory> _getTafasirDirectory() async {
    final docsDir = _customDocumentsDirectory != null
        ? await _customDocumentsDirectory()
        : await getApplicationDocumentsDirectory();

    final dir = Directory('${docsDir.path}/tafasir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> getBookFilePath(String bookId) async {
    final dir = await _getTafasirDirectory();
    return '${dir.path}/$bookId.json';
  }

  @override
  Future<bool> isBookAvailable(String bookId) async {
    if (bookId == 'ar_muyassar' || bookId == 'en_sahih') {
      return true;
    }
    return isBookDownloaded(bookId);
  }

  @override
  Future<bool> isBookDownloaded(String bookId) async {
    if (bookId == 'ar_muyassar' || bookId == 'en_sahih') {
      return true;
    }
    try {
      final path = await getBookFilePath(bookId);
      final file = File(path);
      return await file.exists() && await file.length() > 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getDownloadedBookIds() async {
    final downloaded = <String>[];
    try {
      final dir = await _getTafasirDirectory();
      if (!await dir.exists()) return downloaded;

      final entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.json')) {
          final fileName = entity.uri.pathSegments.last;
          final bookId = fileName.substring(0, fileName.length - 5);
          if (TafsirCatalog.findById(bookId) != null) {
            downloaded.add(bookId);
          }
        }
      }
    } catch (e) {
      throw CacheException('Failed to list downloaded books: $e');
    }
    return downloaded;
  }

  @override
  Future<String?> getAyahText({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final bookData = await _ensureBookLoaded(bookId);
    if (bookData == null) return null;

    final surahMap = bookData[surahNumber];
    if (surahMap == null) return null;

    return surahMap[ayahNumber];
  }

  @override
  Future<Map<int, String>?> getSurahAyat({
    required String bookId,
    required int surahNumber,
  }) async {
    final bookData = await _ensureBookLoaded(bookId);
    if (bookData == null) return null;

    final surahMap = bookData[surahNumber];
    if (surahMap == null) return null;

    return Map<int, String>.unmodifiable(surahMap);
  }

  @override
  Future<void> saveDownloadedFile(String bookId, String sourceTempPath) async {
    try {
      final tempFile = File(sourceTempPath);
      if (!await tempFile.exists()) {
        throw const TafsirDownloadException('Downloaded temp file does not exist');
      }

      final targetPath = await getBookFilePath(bookId);
      final targetFile = File(targetPath);

      // Validate JSON structure before replacing target
      final content = await tempFile.readAsString();
      final decoded = json.decode(content);
      if (decoded is! List || decoded.isEmpty) {
        throw const TafsirCorruptedDataException('Downloaded file contains invalid JSON array');
      }

      // Atomic rename
      await tempFile.rename(targetFile.path);

      // Invalidate memory cache so next read picks up new data
      clearBookMemoryCache(bookId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw CacheException('Failed to save downloaded book $bookId: $e');
    }
  }

  @override
  Future<void> deleteDownloadedBook(String bookId) async {
    if (bookId == 'ar_muyassar' || bookId == 'en_sahih') {
      throw const CacheException('Cannot delete bundled books');
    }

    try {
      final targetPath = await getBookFilePath(bookId);
      final file = File(targetPath);
      if (await file.exists()) {
        await file.delete();
      }
      clearBookMemoryCache(bookId);
    } catch (e) {
      throw CacheException('Failed to delete book $bookId: $e');
    }
  }

  @override
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  @override
  void clearBookMemoryCache(String bookId) {
    _memoryCache.remove(bookId);
  }

  /// Ensures the entire book is indexed in [_memoryCache].
  /// Runs JSON parsing in background isolate via [compute] to protect the UI thread.
  Future<Map<int, Map<int, String>>?> _ensureBookLoaded(String bookId) async {
    if (_memoryCache.containsKey(bookId)) {
      return _memoryCache[bookId];
    }

    // 1. Check bundled books
    if (bookId == 'ar_muyassar') {
      final indexed = _indexBundledList(muyassar);
      _memoryCache[bookId] = indexed;
      return indexed;
    }

    if (bookId == 'en_sahih') {
      final indexed = _indexBundledList(en_sahih);
      _memoryCache[bookId] = indexed;
      return indexed;
    }

    // 2. Check downloaded book on disk
    final filePath = await getBookFilePath(bookId);
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }

    try {
      final jsonString = await file.readAsString();
      // Offload heavy JSON decoding to a background isolate
      final indexed = await compute(_parseJsonToAyahMap, jsonString);
      _memoryCache[bookId] = indexed;
      return indexed;
    } catch (e) {
      throw TafsirCorruptedDataException(
        'Failed to parse downloaded book $bookId dataset: $e',
      );
    }
  }

  /// Indexes a bundled in-memory Dart list into an O(1) map structure.
  static Map<int, Map<int, String>> _indexBundledList(List<dynamic> rawList) {
    final Map<int, Map<int, String>> result = {};

    for (final item in rawList) {
      if (item is Map) {
        final model = TafsirVerseModel.fromJson(Map<String, dynamic>.from(item));
        result.putIfAbsent(model.surahNumber, () => {})[model.ayahNumber] =
            model.text;
      }
    }
    return result;
  }
}

/// Top-level worker function for [compute] to parse JSON in a background isolate.
Map<int, Map<int, String>> _parseJsonToAyahMap(String jsonString) {
  final decoded = json.decode(jsonString);
  final Map<int, Map<int, String>> result = {};

  if (decoded is List) {
    for (final item in decoded) {
      if (item is Map) {
        final model = TafsirVerseModel.fromJson(Map<String, dynamic>.from(item));
        result.putIfAbsent(model.surahNumber, () => {})[model.ayahNumber] =
            model.text;
      }
    }
  }
  return result;
}
