import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';

import '../../domain/entities/tafsir_book.dart';
import '../../domain/entities/tafsir_verse.dart';
import '../../domain/repositories/tafsir_repository.dart';
import '../datasources/tafsir_local_data_source.dart';
import '../datasources/tafsir_remote_data_source.dart';
import '../models/tafsir_catalog.dart';

/// Concrete implementation of [TafsirRepository].
///
/// Unifies local bundled datasets and downloadable datasets behind a Clean Architecture
/// interface, maintaining offline-first access, user preferences, and source integrity.
class TafsirRepositoryImpl implements TafsirRepository {
  final TafsirLocalDataSource _localDataSource;
  final TafsirRemoteDataSource _remoteDataSource;
  final AppPreferences? _preferences;

  String _fallbackSelectedId = TafsirCatalog.defaultBookId;
  List<String> _fallbackLibraryIds = [TafsirCatalog.defaultBookId, 'en_sahih'];

  TafsirRepositoryImpl({
    required TafsirLocalDataSource localDataSource,
    required TafsirRemoteDataSource remoteDataSource,
    AppPreferences? preferences,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _preferences = preferences;

  String get _currentSelectedId =>
      _preferences?.selectedTafsirBookId ?? _fallbackSelectedId;

  Future<void> _persistSelectedId(String id) async {
    final prefs = _preferences;
    if (prefs != null) {
      await prefs.setSelectedTafsirBookId(id);
    } else {
      _fallbackSelectedId = id;
    }
  }

  List<String> get _currentLibraryIds =>
      _preferences?.myLibraryBookIds ?? List<String>.from(_fallbackLibraryIds);

  Future<void> _persistLibraryIds(List<String> ids) async {
    final prefs = _preferences;
    if (prefs != null) {
      await prefs.setMyLibraryBookIds(ids);
    } else {
      _fallbackLibraryIds = List<String>.from(ids);
    }
  }

  @override
  Future<List<TafsirBook>> getAvailableBooks() async {
    final downloadedIds = (await _localDataSource.getDownloadedBookIds()).toSet();

    return TafsirCatalog.books.map((model) {
      final isDownloaded = model.isBundled || downloadedIds.contains(model.id);
      return model.toEntity(isDownloaded: isDownloaded);
    }).toList();
  }

  @override
  Future<TafsirBook> getSelectedBook() async {
    final selectedId = _currentSelectedId;
    final isAvailable = await _localDataSource.isBookAvailable(selectedId);

    final resolvedId = isAvailable ? selectedId : TafsirCatalog.defaultBookId;
    if (resolvedId != selectedId) {
      await _persistSelectedId(resolvedId);
    }

    final model = TafsirCatalog.findById(resolvedId) ??
        TafsirCatalog.findById(TafsirCatalog.defaultBookId)!;

    final isDownloaded = await _localDataSource.isBookAvailable(resolvedId);
    return model.toEntity(isDownloaded: isDownloaded);
  }

  @override
  Future<void> setSelectedBook(String bookId) async {
    final model = TafsirCatalog.findById(bookId);
    if (model == null) {
      throw TafsirNotFoundException('Book $bookId does not exist in catalog');
    }

    final isAvailable = await _localDataSource.isBookAvailable(bookId);
    if (!isAvailable) {
      throw TafsirNotFoundException('Book $bookId is not downloaded or available locally');
    }

    await _persistSelectedId(bookId);
  }

  @override
  Future<List<TafsirBook>> getMyLibraryBooks() async {
    final savedIds = List<String>.from(_currentLibraryIds);

    // Guarantee default book is always present in library
    if (!savedIds.contains(TafsirCatalog.defaultBookId)) {
      savedIds.insert(0, TafsirCatalog.defaultBookId);
      await _persistLibraryIds(savedIds);
    }

    final books = <TafsirBook>[];
    for (final id in savedIds) {
      final model = TafsirCatalog.findById(id);
      if (model != null) {
        final isDownloaded = await _localDataSource.isBookAvailable(id);
        books.add(model.toEntity(isDownloaded: isDownloaded));
      }
    }
    return books;
  }

  @override
  Future<void> updateMyLibraryOrder(List<String> bookIds) async {
    final sanitizedIds = <String>[];

    // Ensure default book is always present
    if (!bookIds.contains(TafsirCatalog.defaultBookId)) {
      sanitizedIds.add(TafsirCatalog.defaultBookId);
    }

    for (final id in bookIds) {
      if (TafsirCatalog.findById(id) != null && !sanitizedIds.contains(id)) {
        sanitizedIds.add(id);
      }
    }

    await _persistLibraryIds(sanitizedIds);
  }

  @override
  Future<void> addToMyLibrary(String bookId) async {
    final model = TafsirCatalog.findById(bookId);
    if (model == null) {
      throw TafsirNotFoundException('Book $bookId not found');
    }

    final currentIds = List<String>.from(_currentLibraryIds);
    if (!currentIds.contains(bookId)) {
      currentIds.add(bookId);
      await _persistLibraryIds(currentIds);
    }
  }

  @override
  Future<void> removeFromMyLibrary(String bookId) async {
    if (bookId == TafsirCatalog.defaultBookId) {
      throw const CacheException('The default Tafsir book cannot be removed from My Library');
    }

    final currentIds = List<String>.from(_currentLibraryIds);
    currentIds.remove(bookId);
    await _persistLibraryIds(currentIds);

    // Reset selected book if the currently selected one was removed
    if (_currentSelectedId == bookId) {
      await _persistSelectedId(TafsirCatalog.defaultBookId);
    }
  }

  @override
  Future<TafsirVerse> getAyahTafsir({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final text = await _localDataSource.getAyahText(
      bookId: bookId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    if (text == null) {
      throw TafsirNotFoundException(
        'Tafsir for surah $surahNumber ayah $ayahNumber not found in book $bookId',
      );
    }

    return TafsirVerse(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      text: text,
      bookId: bookId,
    );
  }

  @override
  Future<List<TafsirVerse>> getSurahTafsir({
    required String bookId,
    required int surahNumber,
  }) async {
    final surahMap = await _localDataSource.getSurahAyat(
      bookId: bookId,
      surahNumber: surahNumber,
    );

    if (surahMap == null) {
      throw TafsirNotFoundException(
        'Tafsir for surah $surahNumber not found in book $bookId',
      );
    }

    final sortedKeys = surahMap.keys.toList()..sort();
    return sortedKeys
        .map(
          (ayah) => TafsirVerse(
            surahNumber: surahNumber,
            ayahNumber: ayah,
            text: surahMap[ayah]!,
            bookId: bookId,
          ),
        )
        .toList();
  }

  @override
  Future<bool> isBookAvailableLocally(String bookId) async {
    return _localDataSource.isBookAvailable(bookId);
  }

  @override
  Future<void> downloadBook(
    String bookId, {
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    final model = TafsirCatalog.findById(bookId);
    if (model == null) {
      throw TafsirNotFoundException('Book $bookId not found in catalog');
    }

    if (model.isBundled) {
      return; // Already bundled, no download needed
    }

    final downloadUrl = model.downloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      throw TafsirNotFoundException('No download URL available for book $bookId');
    }

    final tempFilePath = await _remoteDataSource.downloadBookFile(
      bookId: bookId,
      url: downloadUrl,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    await _localDataSource.saveDownloadedFile(bookId, tempFilePath);
  }

  @override
  Future<void> deleteDownloadedBook(String bookId) async {
    await _localDataSource.deleteDownloadedBook(bookId);

    // If deleted book was currently selected, fall back to default
    if (_currentSelectedId == bookId) {
      await _persistSelectedId(TafsirCatalog.defaultBookId);
    }
  }

  @override
  void clearMemoryCache() {
    _localDataSource.clearMemoryCache();
  }
}
