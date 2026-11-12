import 'package:ayaat_quran_majeed/features/starred/data/datasources/starred_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/starred/data/models/starred_ayah_model.dart';
import 'package:ayaat_quran_majeed/features/starred/data/repositories/starred_repository_impl.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStarredLocalDataSource implements StarredLocalDataSource {
  List<StarredAyahModel> storage = [];

  @override
  Future<List<StarredAyahModel>> getStarredVerses() async {
    return List.from(storage);
  }

  @override
  Future<void> saveStarredVerses(List<StarredAyahModel> items) async {
    storage = List.from(items);
  }
}

void main() {
  group('StarredRepositoryImpl Unit Tests', () {
    late FakeStarredLocalDataSource localDataSource;
    late StarredRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeStarredLocalDataSource();
      repository = StarredRepositoryImpl(
        localDataSource: localDataSource,
        metadataService: const QuranMetadataService(),
      );
    });

    test('getStarredVerses returns empty list initially', () async {
      final items = await repository.getStarredVerses();
      expect(items, isEmpty);
    });

    test('addStarred idempotently adds a verse', () async {
      await repository.addStarred(2, 255);

      var items = await repository.getStarredVerses();
      expect(items.length, equals(1));
      expect(items.first.surahNumber, equals(2));
      expect(items.first.verseNumber, equals(255));
      expect(items.first.surahName, equals('البقرة'));
      expect(items.first.pageNumber, equals(42));

      // Adding the same verse again should not duplicate
      await repository.addStarred(2, 255);
      items = await repository.getStarredVerses();
      expect(items.length, equals(1));
    });

    test('removeStarred idempotently removes an existing verse', () async {
      await repository.addStarred(2, 2);
      await repository.addStarred(2, 4);

      var items = await repository.getStarredVerses();
      expect(items.length, equals(2));

      await repository.removeStarred(2, 2);
      items = await repository.getStarredVerses();
      expect(items.length, equals(1));
      expect(items.first.verseNumber, equals(4));

      // Removing a non-existent verse is a safe no-op
      await repository.removeStarred(2, 2);
      items = await repository.getStarredVerses();
      expect(items.length, equals(1));
    });

    test('toggleStarred toggles starred state correctly', () async {
      expect(await repository.isStarred(1, 1), isFalse);

      await repository.toggleStarred(1, 1);
      expect(await repository.isStarred(1, 1), isTrue);

      await repository.toggleStarred(1, 1);
      expect(await repository.isStarred(1, 1), isFalse);
    });

    test('isStarred returns true only when verse exists', () async {
      expect(await repository.isStarred(2, 5), isFalse);
      await repository.addStarred(2, 5);
      expect(await repository.isStarred(2, 5), isTrue);
      expect(await repository.isStarred(2, 6), isFalse);
    });
  });
}
