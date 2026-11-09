import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/models/selected_ayah.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuranReadingState {
  final bool isLoading;
  final ReadingPosition position;

  /// The page where the user started dragging the slider.
  /// When not null, the return button with arrow and number is displayed.
  /// Note: Transient in-memory session state, NEVER persisted.
  final int? returnPage;

  /// True when the user is actively dragging the slider.
  final bool isSliderDragging;

  /// Intermediate page scrubbed during dragging.
  final int? draggingPage;

  /// Target verse to temporarily highlight on navigation (e.g. "2:255").
  final String? targetHighlightVerse;

  /// Currently selected ayah in the reader (for options sheet & visual highlight).
  final SelectedAyah? selectedAyah;

  /// True when the reader is in Tafsir mode (Reference 17).
  final bool isTafsirMode;

  const QuranReadingState({
    required this.isLoading,
    required this.position,
    this.returnPage,
    this.isSliderDragging = false,
    this.draggingPage,
    this.targetHighlightVerse,
    this.selectedAyah,
    this.isTafsirMode = false,
  });

  factory QuranReadingState.initial() {
    return const QuranReadingState(
      isLoading: true,
      position: ReadingPosition(page: 1, surahNumber: 1, ayahNumber: 1),
      returnPage: null,
      isSliderDragging: false,
      draggingPage: null,
      targetHighlightVerse: null,
      selectedAyah: null,
      isTafsirMode: false,
    );
  }

  QuranReadingState copyWith({
    bool? isLoading,
    ReadingPosition? position,
    int? returnPage,
    bool clearReturnPage = false,
    bool? isSliderDragging,
    int? draggingPage,
    bool clearDraggingPage = false,
    String? targetHighlightVerse,
    bool clearHighlight = false,
    SelectedAyah? selectedAyah,
    bool clearSelectedAyah = false,
    bool? isTafsirMode,
  }) {
    return QuranReadingState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      returnPage: clearReturnPage ? null : (returnPage ?? this.returnPage),
      isSliderDragging: isSliderDragging ?? this.isSliderDragging,
      draggingPage: clearDraggingPage ? null : (draggingPage ?? this.draggingPage),
      targetHighlightVerse:
          clearHighlight ? null : (targetHighlightVerse ?? this.targetHighlightVerse),
      selectedAyah:
          clearSelectedAyah ? null : (selectedAyah ?? this.selectedAyah),
      isTafsirMode: isTafsirMode ?? this.isTafsirMode,
    );
  }
}

/// Cubit that owns the in-memory Quran reading state for the current session.
///
/// Coordinates between UI (page controllers, slider, Ayah picker) and
/// [QuranReadingRepository] to provide smooth navigation and state persistence.
class QuranReaderCubit extends Cubit<QuranReadingState> {
  final QuranReadingRepository _repository;
  final QuranMetadataService _metadataService;

  QuranReaderCubit(
    this._repository, {
    QuranMetadataService metadataService = const QuranMetadataService(),
  })  : _metadataService = metadataService,
        super(QuranReadingState.initial());

  QuranReadingRepository get repository => _repository;
  QuranMetadataService get metadataService => _metadataService;

  /// Load the initial reading position when the reader is first opened.
  Future<void> loadInitialPosition() async {
    emit(state.copyWith(isLoading: true));

    final position = await _repository.loadLastPosition();

    emit(
      state.copyWith(
        isLoading: false,
        position: position,
      ),
    );
  }

  /// Explicitly persist the current state to storage.
  Future<void> persistCurrentPosition() {
    return _repository.savePosition(state.position);
  }

  /// Called when the user touches/begins dragging the page slider.
  void onSliderDragStarted(int startPage) {
    emit(
      state.copyWith(
        isSliderDragging: true,
        draggingPage: startPage.clamp(1, 604),
      ),
    );
  }

  /// Called continuously while dragging the page slider.
  void onSliderScrubbing(int scrubPage) {
    emit(
      state.copyWith(
        draggingPage: scrubPage.clamp(1, 604),
      ),
    );
  }

  /// Called when the user releases/finishes dragging the page slider.
  ///
  /// Sets [returnPage] to the page where the drag originated if different,
  /// jumps to [targetPage], and persists the new position.
  Future<void> onSliderDragEnded(int targetPage) async {
    final int safeTarget = targetPage.clamp(1, 604);
    final int originPage = state.position.page;

    int? newReturnPage = state.returnPage;
    bool shouldClearReturn = false;

    if (safeTarget == originPage) {
      // Released on the same page where drag started
      if (state.returnPage == safeTarget) {
        shouldClearReturn = true;
      }
    } else {
      // Jumped to a new page -> set return target to origin if not already set
      newReturnPage ??= originPage;
      if (newReturnPage == safeTarget) {
        shouldClearReturn = true;
      }
    }

    final mapped = _mapPageToPosition(safeTarget);
    emit(
      state.copyWith(
        position: mapped,
        isSliderDragging: false,
        clearDraggingPage: true,
        returnPage: shouldClearReturn ? null : newReturnPage,
        clearReturnPage: shouldClearReturn,
      ),
    );

    await _repository.savePosition(mapped);
  }

  /// Jump back to the page where the slider drag originated.
  /// Dismisses the return arrow button afterwards.
  Future<void> returnToPreviousPage() async {
    final returnTarget = state.returnPage;
    if (returnTarget == null) return;

    final mapped = _mapPageToPosition(returnTarget);
    emit(
      state.copyWith(
        position: mapped,
        clearReturnPage: true,
      ),
    );

    await _repository.savePosition(mapped);
  }

  /// Manually dismiss the return arrow button without navigating.
  void dismissReturnPage() {
    emit(state.copyWith(clearReturnPage: true));
  }

  /// Update state in response to a page change in the mushaf page view.
  ///
  /// If the user manually navigates back to [returnPage], it clears it automatically.
  Future<void> updateFromPageChange(int page) async {
    final int safePage = page.clamp(1, 604);
    final mapped = _mapPageToPosition(safePage);

    final bool shouldClearReturn = state.returnPage != null && state.returnPage == safePage;

    emit(
      state.copyWith(
        position: mapped,
        clearReturnPage: shouldClearReturn,
      ),
    );
    await _repository.savePosition(mapped);
  }

  /// Navigate to a specific mushaf page.
  Future<void> goToPage(int page) async {
    final int safePage = page.clamp(1, 604);
    final mapped = _mapPageToPosition(safePage);

    final bool shouldClearReturn = state.returnPage != null && state.returnPage == safePage;

    emit(
      state.copyWith(
        position: mapped,
        clearReturnPage: shouldClearReturn,
      ),
    );
    await _repository.savePosition(mapped);
  }

  /// Navigate to a specific surah (first ayah by default).
  Future<void> goToSurah(int surahNumber, {int ayahNumber = 1}) async {
    final int safeSurah = surahNumber.clamp(1, 114);
    final int maxAyah = _metadataService.getVerseCount(safeSurah);
    final int safeAyah = ayahNumber.clamp(1, maxAyah);

    final int page = _metadataService.getPageNumber(safeSurah, safeAyah);
    final position = ReadingPosition(
      page: page,
      surahNumber: safeSurah,
      ayahNumber: safeAyah,
      viewMode: state.position.viewMode,
    );

    final bool shouldClearReturn = state.returnPage != null && state.returnPage == page;

    emit(
      state.copyWith(
        position: position,
        clearReturnPage: shouldClearReturn,
        targetHighlightVerse: '$safeSurah:$safeAyah',
      ),
    );
    await _repository.savePosition(position);
  }

  /// Navigate to a specific ayah with target highlight.
  Future<void> goToAyah(int surahNumber, int ayahNumber) async {
    final int safeSurah = surahNumber.clamp(1, 114);
    final int maxAyah = _metadataService.getVerseCount(safeSurah);
    final int safeAyah = ayahNumber.clamp(1, maxAyah);

    final int page = _metadataService.getPageNumber(safeSurah, safeAyah);
    final position = ReadingPosition(
      page: page,
      surahNumber: safeSurah,
      ayahNumber: safeAyah,
      viewMode: state.position.viewMode,
    );

    final bool shouldClearReturn = state.returnPage != null && state.returnPage == page;

    emit(
      state.copyWith(
        position: position,
        clearReturnPage: shouldClearReturn,
        targetHighlightVerse: '$safeSurah:$safeAyah',
      ),
    );
    await _repository.savePosition(position);
  }

  /// Clear any pending verse highlight.
  void clearHighlight() {
    emit(state.copyWith(clearHighlight: true));
  }

  /// Selects an ayah, updating reader state and highlighting it on the page.
  void selectAyah(int surahNumber, int ayahNumber) {
    final safeSurah = surahNumber.clamp(1, 114);
    final maxAyah = _metadataService.getVerseCount(safeSurah);
    final safeAyah = ayahNumber.clamp(1, maxAyah);
    final page = _metadataService.getPageNumber(safeSurah, safeAyah);

    emit(
      state.copyWith(
        selectedAyah: SelectedAyah(
          surahNumber: safeSurah,
          ayahNumber: safeAyah,
          pageNumber: page,
        ),
      ),
    );
  }

  /// Clears the currently selected ayah and its highlight.
  void clearSelectedAyah() {
    emit(state.copyWith(clearSelectedAyah: true));
  }

  /// Toggles Tafsir mode on/off (or forces a specific state via [enable]).
  void toggleTafsirMode({bool? enable}) {
    emit(state.copyWith(isTafsirMode: enable ?? !state.isTafsirMode));
  }

  /// Update only the view mode (e.g., page, vertical, verse-by-verse).
  void updateViewMode(String viewMode) {
    emit(
      state.copyWith(
        position: state.position.copyWith(viewMode: viewMode),
      ),
    );
  }

  ReadingPosition _mapPageToPosition(int page) {
    final safePage = page.clamp(1, 604);
    try {
      final pageData = _metadataService.getPageData(safePage);
      if (pageData.isNotEmpty) {
        final firstSegment = pageData.first;
        final int surah = firstSegment['surah'] as int;
        final int ayah = firstSegment['start'] as int;

        return state.position.copyWith(
          page: safePage,
          surahNumber: surah,
          ayahNumber: ayah,
        );
      }
    } catch (_) {
      // Fall back to the existing state if mapping fails.
    }

    return state.position.copyWith(page: safePage);
  }
}
