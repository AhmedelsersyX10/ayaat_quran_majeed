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
  QuranMetadataService get metadataService => const QuranMetadataService();

  @override
  ReadingPosition validateAndNormalize(ReadingPosition rawPosition) => rawPosition;

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
      expect(cubit.state.position.page, 1);
      expect(cubit.state.position.surahNumber, 1);
      expect(cubit.state.position.ayahNumber, 1);
      expect(cubit.state.returnPage, isNull);
      expect(cubit.state.isSliderDragging, isFalse);
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

    test('goToPage clamps negative and out of bound pages safely', () async {
      await cubit.goToPage(-10);
      expect(cubit.state.position.page, 1);

      await cubit.goToPage(999);
      expect(cubit.state.position.page, 604);
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

    test('goToAyah navigates to exact ayah, sets highlight and page', () async {
      // Ayat Al-Kursi (2:255) is on page 42
      await cubit.goToAyah(2, 255);

      expect(cubit.state.position.page, 42);
      expect(cubit.state.position.surahNumber, 2);
      expect(cubit.state.position.ayahNumber, 255);
      expect(cubit.state.targetHighlightVerse, '2:255');
      expect(repository.lastSavedPosition?.page, 42);

      cubit.clearHighlight();
      expect(cubit.state.targetHighlightVerse, isNull);
    });

    test('updateViewMode updates viewMode in state', () {
      cubit.updateViewMode('verticalview');
      expect(cubit.state.position.viewMode, 'verticalview');

      cubit.updateViewMode('pageview');
      expect(cubit.state.position.viewMode, 'pageview');
    });

    test('slider drag lifecycle sets returnPage and handles returnToPreviousPage', () async {
      // 1. Initial page is 10
      await cubit.goToPage(10);
      expect(cubit.state.position.page, 10);
      expect(cubit.state.returnPage, isNull);

      // 2. User starts dragging from page 10
      cubit.onSliderDragStarted(10);
      expect(cubit.state.isSliderDragging, isTrue);
      expect(cubit.state.draggingPage, 10);

      // 3. User scrubs to page 75
      cubit.onSliderScrubbing(75);
      expect(cubit.state.draggingPage, 75);

      // 4. User releases on page 100
      await cubit.onSliderDragEnded(100);
      expect(cubit.state.isSliderDragging, isFalse);
      expect(cubit.state.draggingPage, isNull);
      expect(cubit.state.position.page, 100);
      expect(cubit.state.returnPage, 10); // Return arrow target is 10

      // 5. User taps return button
      await cubit.returnToPreviousPage();
      expect(cubit.state.position.page, 10);
      expect(cubit.state.returnPage, isNull); // Return button dismissed
    });

    test('slider drag ending on the same page does not set returnPage', () async {
      await cubit.goToPage(25);
      cubit.onSliderDragStarted(25);
      cubit.onSliderScrubbing(26);
      await cubit.onSliderDragEnded(25);

      expect(cubit.state.position.page, 25);
      expect(cubit.state.returnPage, isNull);
    });

    test('manually navigating to returnPage clears returnPage', () async {
      await cubit.goToPage(10);
      await cubit.onSliderDragEnded(100);
      expect(cubit.state.returnPage, 10);

      // User manually swipes back to page 10
      await cubit.updateFromPageChange(10);
      expect(cubit.state.position.page, 10);
      expect(cubit.state.returnPage, isNull);
    });

    test('dismissReturnPage dismisses return button without moving', () async {
      await cubit.goToPage(10);
      await cubit.onSliderDragEnded(100);
      expect(cubit.state.returnPage, 10);

      cubit.dismissReturnPage();
      expect(cubit.state.returnPage, isNull);
      expect(cubit.state.position.page, 100);
    });
  });
}
