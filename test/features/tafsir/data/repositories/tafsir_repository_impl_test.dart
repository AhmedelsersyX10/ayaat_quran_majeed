import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/repositories/tafsir_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePreferencesStorage implements PreferencesStorage {
  final Map<String, dynamic> _data = {};

  @override
  bool? getBool(String key) => _data[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _data[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _data[key] as double?;
  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = List<String>.from(value);
    return true;
  }

  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

class FakeTafsirLocalDataSource implements TafsirLocalDataSource {
  final Set<String> downloadedBooks = {};
  final Map<String, Map<int, Map<int, String>>> textData = {};
  bool clearMemoryCacheCalled = false;

  @override
  Future<bool> isBookAvailable(String bookId) async {
    if (bookId == 'ar_muyassar' || bookId == 'en_sahih') return true;
    return downloadedBooks.contains(bookId);
  }

  @override
  Future<bool> isBookDownloaded(String bookId) async {
    if (bookId == 'ar_muyassar' || bookId == 'en_sahih') return true;
    return downloadedBooks.contains(bookId);
  }

  @override
  Future<List<String>> getDownloadedBookIds() async {
    return downloadedBooks.toList();
  }

  @override
  Future<String?> getAyahText({
    required String bookId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return textData[bookId]?[surahNumber]?[ayahNumber];
  }

  @override
  Future<Map<int, String>?> getSurahAyat({
    required String bookId,
    required int surahNumber,
  }) async {
    return textData[bookId]?[surahNumber];
  }

  @override
  Future<String> getBookFilePath(String bookId) async => '/fake/$bookId.json';

  @override
  Future<void> saveDownloadedFile(String bookId, String sourceTempPath) async {
    downloadedBooks.add(bookId);
    textData.putIfAbsent(bookId, () => {1: {1: 'Downloaded text'}});
  }

  @override
  Future<void> deleteDownloadedBook(String bookId) async {
    if (bookId == 'ar_muyassar' || bookId == 'en_sahih') {
      throw const CacheException('Cannot delete bundled books');
    }
    downloadedBooks.remove(bookId);
    textData.remove(bookId);
  }

  @override
  void clearMemoryCache() {
    clearMemoryCacheCalled = true;
  }

  @override
  void clearBookMemoryCache(String bookId) {
    textData.remove(bookId);
  }
}

class FakeTafsirRemoteDataSource implements TafsirRemoteDataSource {
  String? lastDownloadedBookId;
  String? lastDownloadedUrl;

  @override
  Future<String> downloadBookFile({
    required String bookId,
    required String url,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {
    lastDownloadedBookId = bookId;
    lastDownloadedUrl = url;
    if (onProgress != null) onProgress(100, 100);
    return '/fake/temp_$bookId.tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTafsirLocalDataSource localDataSource;
  late FakeTafsirRemoteDataSource remoteDataSource;
  late FakePreferencesStorage preferencesStorage;
  late AppPreferences preferences;
  late TafsirRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeTafsirLocalDataSource();
    remoteDataSource = FakeTafsirRemoteDataSource();
    preferencesStorage = FakePreferencesStorage();
    preferences = AppPreferences(preferencesStorage);
    repository = TafsirRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      preferences: preferences,
    );

    // Seed Al-Muyassar sample data
    localDataSource.textData['ar_muyassar'] = {
      1: {
        1: 'سورة الفاتحة - أبتدئ قراءة القرآن باسم الله',
        2: 'الحمد لله رب العالمين',
      },
    };
  });

  group('TafsirRepositoryImpl - Book Catalog & Selection Tests', () {
    test('getAvailableBooks returns 38 books with accurate download states', () async {
      localDataSource.downloadedBooks.add('sa3dy');

      final books = await repository.getAvailableBooks();
      expect(books.length, equals(38));

      final muyassar = books.firstWhere((b) => b.id == 'ar_muyassar');
      expect(muyassar.isDownloaded, isTrue);
      expect(muyassar.isBundled, isTrue);

      final sa3dy = books.firstWhere((b) => b.id == 'sa3dy');
      expect(sa3dy.isDownloaded, isTrue);
      expect(sa3dy.isBundled, isFalse);

      final katheer = books.firstWhere((b) => b.id == 'katheer');
      expect(katheer.isDownloaded, isFalse);
    });

    test('getSelectedBook defaults to Al-Tafsir Al-Muyassar (ar_muyassar)', () async {
      final selected = await repository.getSelectedBook();
      expect(selected.id, equals('ar_muyassar'));
      expect(selected.name, equals('التفسير الميسر'));
    });

    test('setSelectedBook switches active book when available locally', () async {
      localDataSource.downloadedBooks.add('sa3dy');

      await repository.setSelectedBook('sa3dy');
      expect(preferences.selectedTafsirBookId, equals('sa3dy'));

      final current = await repository.getSelectedBook();
      expect(current.id, equals('sa3dy'));
    });

    test('setSelectedBook throws TafsirNotFoundException if book not downloaded', () async {
      expect(
        () => repository.setSelectedBook('tabary'),
        throwsA(isA<TafsirNotFoundException>()),
      );
    });

    test('getSelectedBook falls back to ar_muyassar if selected book was deleted', () async {
      await preferences.setSelectedTafsirBookId('sa3dy');
      // sa3dy is NOT in localDataSource.downloadedBooks

      final selected = await repository.getSelectedBook();
      expect(selected.id, equals('ar_muyassar'));
      expect(preferences.selectedTafsirBookId, equals('ar_muyassar'));
    });
  });

  group('TafsirRepositoryImpl - My Library Management Tests (Reference 34)', () {
    test('getMyLibraryBooks always contains ar_muyassar', () async {
      final library = await repository.getMyLibraryBooks();
      expect(library.any((b) => b.id == 'ar_muyassar'), isTrue);
    });

    test('addToMyLibrary adds book if valid', () async {
      await repository.addToMyLibrary('sa3dy');

      final library = await repository.getMyLibraryBooks();
      expect(library.any((b) => b.id == 'sa3dy'), isTrue);
      expect(preferences.myLibraryBookIds.contains('sa3dy'), isTrue);
    });

    test('addToMyLibrary throws TafsirNotFoundException for unknown book', () async {
      expect(
        () => repository.addToMyLibrary('unknown_book'),
        throwsA(isA<TafsirNotFoundException>()),
      );
    });

    test('removeFromMyLibrary forbids deleting ar_muyassar with CacheException', () async {
      expect(
        () => repository.removeFromMyLibrary('ar_muyassar'),
        throwsA(isA<CacheException>()),
      );
    });

    test('removeFromMyLibrary removes book and resets selected if active', () async {
      localDataSource.downloadedBooks.add('sa3dy');
      await repository.addToMyLibrary('sa3dy');
      await repository.setSelectedBook('sa3dy');

      await repository.removeFromMyLibrary('sa3dy');

      final library = await repository.getMyLibraryBooks();
      expect(library.any((b) => b.id == 'sa3dy'), isFalse);
      expect(preferences.selectedTafsirBookId, equals('ar_muyassar'));
    });

    test('updateMyLibraryOrder reorders books while preserving ar_muyassar', () async {
      await repository.updateMyLibraryOrder(['en_sahih', 'sa3dy']);

      final saved = preferences.myLibraryBookIds;
      expect(saved.contains('ar_muyassar'), isTrue);
      expect(saved.contains('en_sahih'), isTrue);
      expect(saved.contains('sa3dy'), isTrue);
    });
  });

  group('TafsirRepositoryImpl - Ayah & Surah Tafsir Retrieval Tests', () {
    test('getAyahTafsir returns TafsirVerse for existing verse', () async {
      final verse = await repository.getAyahTafsir(
        bookId: 'ar_muyassar',
        surahNumber: 1,
        ayahNumber: 1,
      );

      expect(verse.surahNumber, equals(1));
      expect(verse.ayahNumber, equals(1));
      expect(verse.bookId, equals('ar_muyassar'));
      expect(verse.text, contains('سورة الفاتحة'));
    });

    test('getAyahTafsir throws TafsirNotFoundException when verse not found', () async {
      expect(
        () => repository.getAyahTafsir(
          bookId: 'ar_muyassar',
          surahNumber: 1,
          ayahNumber: 99,
        ),
        throwsA(isA<TafsirNotFoundException>()),
      );
    });

    test('getSurahTafsir returns all verses sorted', () async {
      final verses = await repository.getSurahTafsir(
        bookId: 'ar_muyassar',
        surahNumber: 1,
      );

      expect(verses.length, equals(2));
      expect(verses[0].ayahNumber, equals(1));
      expect(verses[1].ayahNumber, equals(2));
    });

    test('getSurahTafsir throws TafsirNotFoundException when surah not found', () async {
      expect(
        () => repository.getSurahTafsir(
          bookId: 'ar_muyassar',
          surahNumber: 999,
        ),
        throwsA(isA<TafsirNotFoundException>()),
      );
    });
  });

  group('TafsirRepositoryImpl - Download & Delete Operations Tests', () {
    test('downloadBook downloads remote dataset and saves to local storage', () async {
      await repository.downloadBook('sa3dy');

      expect(remoteDataSource.lastDownloadedBookId, equals('sa3dy'));
      expect(await localDataSource.isBookDownloaded('sa3dy'), isTrue);
    });

    test('downloadBook completes immediately for bundled books', () async {
      await repository.downloadBook('ar_muyassar');
      expect(remoteDataSource.lastDownloadedBookId, isNull);
    });

    test('deleteDownloadedBook deletes file and resets selected book if needed', () async {
      localDataSource.downloadedBooks.add('sa3dy');
      await repository.setSelectedBook('sa3dy');

      await repository.deleteDownloadedBook('sa3dy');

      expect(await localDataSource.isBookDownloaded('sa3dy'), isFalse);
      expect(preferences.selectedTafsirBookId, equals('ar_muyassar'));
    });

    test('clearMemoryCache delegates to localDataSource', () {
      repository.clearMemoryCache();
      expect(localDataSource.clearMemoryCacheCalled, isTrue);
    });
  });
}

