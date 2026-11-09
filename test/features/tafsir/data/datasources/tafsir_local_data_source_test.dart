import 'dart:convert';
import 'dart:io';

import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late TafsirLocalDataSourceImpl dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tafsir_local_test_');
    dataSource = TafsirLocalDataSourceImpl(
      customDocumentsDirectory: () async => tempDir,
    );
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('TafsirLocalDataSource - Bundled Datasets Tests', () {
    test('ar_muyassar is permanently available and downloaded', () async {
      expect(await dataSource.isBookAvailable('ar_muyassar'), isTrue);
      expect(await dataSource.isBookDownloaded('ar_muyassar'), isTrue);
    });

    test('en_sahih is permanently available and downloaded', () async {
      expect(await dataSource.isBookAvailable('en_sahih'), isTrue);
      expect(await dataSource.isBookDownloaded('en_sahih'), isTrue);
    });

    test('fetches Al-Fatiha ayah 1 from bundled muyassar instantly', () async {
      final text = await dataSource.getAyahText(
        bookId: 'ar_muyassar',
        surahNumber: 1,
        ayahNumber: 1,
      );

      expect(text, isNotNull);
      expect(text!.contains('سورة الفاتحة'), isTrue);
      expect(text.contains('أبتدئ قراءة القرآن باسم الله'), isTrue);
    });

    test('fetches full Al-Fatiha surah (7 ayahs) from bundled muyassar', () async {
      final surahMap = await dataSource.getSurahAyat(
        bookId: 'ar_muyassar',
        surahNumber: 1,
      );

      expect(surahMap, isNotNull);
      expect(surahMap!.length, equals(7));
      expect(surahMap[1], isNotEmpty);
      expect(surahMap[7], isNotEmpty);
    });

    test('fetches Al-Fatiha ayah 1 from bundled sahih_english', () async {
      final text = await dataSource.getAyahText(
        bookId: 'en_sahih',
        surahNumber: 1,
        ayahNumber: 1,
      );

      expect(text, isNotNull);
      expect(
        text,
        equals('In the name of Allah, the Entirely Merciful, the Especially Merciful.'),
      );
    });

    test('returns null for nonexistent surah or ayah numbers', () async {
      final invalidAyah = await dataSource.getAyahText(
        bookId: 'ar_muyassar',
        surahNumber: 1,
        ayahNumber: 99,
      );
      expect(invalidAyah, isNull);

      final invalidSurah = await dataSource.getSurahAyat(
        bookId: 'ar_muyassar',
        surahNumber: 200,
      );
      expect(invalidSurah, isNull);
    });

    test('prevent deleting bundled books with CacheException', () async {
      expect(
        () => dataSource.deleteDownloadedBook('ar_muyassar'),
        throwsA(isA<CacheException>()),
      );
      expect(
        () => dataSource.deleteDownloadedBook('en_sahih'),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('TafsirLocalDataSource - Downloaded Datasets & Storage Tests', () {
    test('non-downloaded book returns false and null ayah text', () async {
      expect(await dataSource.isBookAvailable('sa3dy'), isFalse);
      expect(await dataSource.isBookDownloaded('sa3dy'), isFalse);

      final text = await dataSource.getAyahText(
        bookId: 'sa3dy',
        surahNumber: 1,
        ayahNumber: 1,
      );
      expect(text, isNull);
    });

    test('saves valid downloaded file atomically and serves ayah texts', () async {
      // Create sample downloaded JSON file
      final sampleJson = json.encode([
        {'id': 1, 'sura': 1, 'aya': 1, 'text': '<p>{بِسْمِ اللَّهِ} أي: أبتدئ بكل اسم لله</p>'},
        {'id': 2, 'sura': 1, 'aya': 2, 'text': '<p>{الْحَمْدُ لِلَّهِ} الثناء على الله</p>'},
      ]);

      final sourceTempFile = File('${tempDir.path}/temp_sample.json');
      await sourceTempFile.writeAsString(sampleJson);

      await dataSource.saveDownloadedFile('sa3dy', sourceTempFile.path);

      expect(await dataSource.isBookDownloaded('sa3dy'), isTrue);
      expect(await dataSource.isBookAvailable('sa3dy'), isTrue);

      final downloadedList = await dataSource.getDownloadedBookIds();
      expect(downloadedList.contains('sa3dy'), isTrue);

      final ayah1 = await dataSource.getAyahText(
        bookId: 'sa3dy',
        surahNumber: 1,
        ayahNumber: 1,
      );
      expect(ayah1, equals('{بِسْمِ اللَّهِ} أي: أبتدئ بكل اسم لله'));

      final surah1 = await dataSource.getSurahAyat(
        bookId: 'sa3dy',
        surahNumber: 1,
      );
      expect(surah1, isNotNull);
      expect(surah1!.length, equals(2));
      expect(surah1[2], equals('{الْحَمْدُ لِلَّهِ} الثناء على الله'));

      // Delete book
      await dataSource.deleteDownloadedBook('sa3dy');
      expect(await dataSource.isBookDownloaded('sa3dy'), isFalse);
    });

    test('rejects corrupted or empty JSON when saving downloaded file', () async {
      final emptyFile = File('${tempDir.path}/corrupt.json');
      await emptyFile.writeAsString('{"invalid": "not_an_array"}');

      expect(
        () => dataSource.saveDownloadedFile('katheer', emptyFile.path),
        throwsA(isA<TafsirCorruptedDataException>()),
      );
    });

    test('clearMemoryCache clears in-memory maps cleanly', () async {
      // Trigger load
      await dataSource.getAyahText(
        bookId: 'ar_muyassar',
        surahNumber: 1,
        ayahNumber: 1,
      );

      dataSource.clearMemoryCache();

      // Subsequent access reloads smoothly without failure
      final reloaded = await dataSource.getAyahText(
        bookId: 'ar_muyassar',
        surahNumber: 1,
        ayahNumber: 1,
      );
      expect(reloaded, isNotNull);
    });
  });
}

