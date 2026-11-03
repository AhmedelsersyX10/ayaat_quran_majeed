import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_reading_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReadingRepository implements QuranReadingRepository {
  ReadingPosition currentPosition;
  ReadingPosition? lastSavedPosition;
  int saveCount = 0;

  _FakeReadingRepository({required this.currentPosition});

  @override
  Future<ReadingPosition> loadLastPosition() async {
    return currentPosition;
  }

  @override
  Future<void> savePosition(ReadingPosition position) async {
    currentPosition = position;
    lastSavedPosition = position;
    saveCount++;
  }
}

void main() {
  group('QuranReaderCubit Unit Tests', () {
    late _FakeReadingRepository repository;
    late QuranReaderCubit cubit;
    const metadataService = QuranMetadataService();

    setUp(() {
      repository = _FakeReadingRepository(
        currentPosition: const ReadingPosition(
          page: 1,
          surahNumber: 1,
          ayahNumber: 1,
        ),
      );
      cubit = QuranReaderCubit(
        repository,
        metadataService: metadataService,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial state has default values and isLoading is true', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.isChromeVisible, isTrue);
      expect(cubit.state.position.page, 1);
      expect(cubit.state.position.surahNumber, 1);
      expect(cubit.state.position.ayahNumber, 1);
    });

    test('loadInitialPosition loads position from repository and sets isLoading to false', () async {
      repository.currentPosition = const ReadingPosition(
        page: 42,
        surahNumber: 2,
        ayahNumber: 255,
      );

      await cubit.loadInitialPosition();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.position.page, 42);
      expect(cubit.state.position.surahNumber, 2);
      expect(cubit.state.position.ayahNumber, 255);
    });

    test('goToPage navigates to requested page and persists mapped position', () async {
      await cubit.goToPage(42);

      expect(cubit.state.position.page, 42);
      expect(cubit.state.position.surahNumber, 2);
      expect(repository.lastSavedPosition?.page, 42);
      expect(repository.lastSavedPosition?.surahNumber, 2);
    });

    test('goToPage(1) boundary correctly maps to Al-Fatiha', () async {
      await cubit.goToPage(1);

      expect(cubit.state.position.page, 1);
      expect(cubit.state.position.surahNumber, 1);
      expect(cubit.state.position.ayahNumber, 1);
    });

    test('goToPage(604) boundary correctly maps to Juz 30 end surahs', () async {
      await cubit.goToPage(604);

      expect(cubit.state.position.page, 604);
      expect(cubit.state.position.surahNumber, 112); // Al-Ikhlas starts page 604
      expect(repository.lastSavedPosition?.page, 604);
    });

    test('updateFromPageChange syncs state and saves to repository', () async {
      await cubit.updateFromPageChange(2);

      expect(cubit.state.position.page, 2);
      expect(cubit.state.position.surahNumber, 2);
      expect(repository.lastSavedPosition?.page, 2);
      expect(repository.saveCount, 1);
    });

    test('goToSurah navigates to first page of surah', () async {
      // Surah Yasin (36) is on page 440
      await cubit.goToSurah(36);

      expect(cubit.state.position.page, 440);
      expect(cubit.state.position.surahNumber, 36);
      expect(cubit.state.position.ayahNumber, 1);
      expect(repository.lastSavedPosition?.page, 440);
    });

    test('goToAyah navigates to exact ayah and page', () async {
      // Ayat Al-Kursi (2:255) is on page 42
      await cubit.goToAyah(2, 255);

      expect(cubit.state.position.page, 42);
      expect(cubit.state.position.surahNumber, 2);
      expect(cubit.state.position.ayahNumber, 255);
      expect(repository.lastSavedPosition?.page, 42);
    });

    test('toggleChrome toggles isChromeVisible back and forth', () {
      expect(cubit.state.isChromeVisible, isTrue);

      cubit.toggleChrome();
      expect(cubit.state.isChromeVisible, isFalse);

      cubit.toggleChrome();
      expect(cubit.state.isChromeVisible, isTrue);
    });

    test('updateViewMode updates viewMode in state', () {
      cubit.updateViewMode('verticalview');
      expect(cubit.state.position.viewMode, 'verticalview');

      cubit.updateViewMode('pageview');
      expect(cubit.state.position.viewMode, 'pageview');
    });

    test('persistCurrentPosition saves current state to repository', () async {
      await cubit.goToPage(100);
      final initialCount = repository.saveCount;

      await cubit.persistCurrentPosition();
      expect(repository.saveCount, initialCount + 1);
      expect(repository.lastSavedPosition?.page, 100);
    });
  });
}

