// ignore_for_file: unrelated_type_equality_checks, depend_on_referenced_packages, file_names
import 'dart:async';
import 'dart:convert';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/widgets/note_editor_dialog.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/search_navigation_target.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_state.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/views/tafsir_page_view.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/widgets/tafsir_book_picker_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_reading_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_state.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/floating_audio_player.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/play_to_sheet.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/recitation_settings_sheet.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_page_player_bloc.dart';
import 'package:ayaat_quran_majeed/quran/data/models/reciter_model.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/get_translation_data.dart'
    as get_translation_data;
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translationdata.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/bookmark_picker_dialog.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/widgets/mushaf_bookmark_marker.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/json_asset_service.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/remove_html_tags.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/views/quran_sura_list.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_options_sheet.dart'
    show AyahOptionsSheet;
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/ayah_picker_sheet.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/today_ayah_sheet.dart';
import 'package:ayaat_quran_majeed/quran/presentation/controllers/reader_chrome_controller.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/dialogs/share_ayah_dialog.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/settings_bottom_sheet.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/bismallah.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/floating_quran_app_bar.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/header_widget.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_divider.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_footer.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_header.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_shell.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_page_slider.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_return_button.dart';
import 'package:flutter/foundation.dart' as flutter_foundation;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart' as qp;
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
part 'alignment_views/verse_by_verse_view.dart';
part 'alignment_views/vertical_view.dart';
part 'alignment_views/page_view.dart';

const _metadataService = QuranMetadataService();

class QuranReadingPage extends StatelessWidget {
  const QuranReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TafsirCubit>(
      create: (_) => sl<TafsirCubit>(),
      child: BlocBuilder<QuranReaderCubit, QuranReadingState>(
        buildWhen: (previous, current) =>
            previous.isLoading != current.isLoading,
        builder: (context, state) {
          if (state.isLoading) {
            final theme = Theme.of(context);
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return QuranDetailsPage(
            pageNumber: state.position.page,
            jsonData: JsonAssetService.surahsData,
            quarterJsonData: JsonAssetService.quartersData,
            shouldHighlightText: false,
            highlightVerse: "",
            shouldHighlightSura: false,
          );
        },
      ),
    );
  }
}

class QuranDetailsPage extends StatefulWidget {
  final int pageNumber;
  final dynamic jsonData;
  final dynamic quarterJsonData;
  final bool shouldHighlightText;
  final dynamic highlightVerse;
  final bool shouldHighlightSura;

  const QuranDetailsPage({
    super.key,
    required this.pageNumber,
    required this.jsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
    required this.quarterJsonData,
    required this.shouldHighlightSura,
  });

  @override
  State<QuranDetailsPage> createState() => QuranDetailsPageState();
}

class QuranDetailsPageState extends State<QuranDetailsPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  // ==================== Controllers ====================
  final ScrollController _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  late PageController _pageController;
  final GlobalKey<TafsirPageViewState> _tafsirPageKey =
      GlobalKey<TafsirPageViewState>();
  ScreenshotController screenshotController = ScreenshotController();
  late AnimationController _navHighlightController;
  late Animation<double> _navHighlightAnimation;

  // ==================== State Variables ====================
  int index = 0;
  int playIndexPage = 0;
  String selectedSpan = "";
  String isDownloading = "";
  var highlightVerse;
  var shouldHighlightText;
  var currentVersePlaying;
  var dataOfCurrentTranslation;
  String? swipeDirection;
  bool isScrolling = false; // متغير لكشف حالة التمرير/التقليب
  bool shouldHighlightSura = false;

  // ==================== Full Surah Playback ====================
  int? currentSurahNumber;
  int? currentPlayingVerse = 0; // الآية التي يتم تشغيلها حالياً
  StreamSubscription<SequenceState?>? positionSubscription;
  StreamSubscription<ProcessingState>? processingSubscription;
  Timer? verseTrackingTimer;
  Timer? _debounceTimer; // Debouncer for scroll updates
  bool isTrackingStarted = false; // flag لمنع بدء التتبع مرتين

  // ==================== Bookmarks & Starred Verses ====================
  List<BookmarkItem> bookmarks = [];
  Set<String> starredVerses = {};
  Set<String> expandedTafseerVerses = {};

  // ==================== UI State ====================
  double valueOfSlider = 0;
  double currentHeight = 2.0;
  double currentLetterSpacing = 0.0;
  bool showSuraHeader = true;
  bool addAppSlogan = true;
  late final ReaderChromeController _chromeController;
  Timer? verseHighlightTimer; // Timer for delayed verse highlighting

  // ==================== Helpers ====================
  late Timer timer;
  Directory? appDir;
  var english = RegExp(r'[a-zA-Z]');
  List<GlobalKey> richTextKeys = List.generate(604, (_) => GlobalKey());
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  // ==================== Reciters ====================
  List<QuranPageReciter> reciters = [];

  // ==================== Quran Reading Cubit Sync ====================
  bool _hasSyncedInitialPosition = false;
  bool _hasFetchedInitialBookmarks = false;

  // ==================== Initialization Methods ====================

  void setIndex() {
    index = widget.pageNumber;
  }

  void toggleTafseer(int surah, int ayah) {
    final verseKey = "$surah:$ayah";
    setState(() {
      if (expandedTafseerVerses.contains(verseKey)) {
        expandedTafseerVerses.remove(verseKey);
      } else {
        expandedTafseerVerses.add(verseKey);
      }
    });
  }

  Future<void> initialize() async {
    appDir = await getTemporaryDirectory();
    getTranslationData();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> checkIfSelectHighlight() async {
    // Legacy periodic timer removed as it violates persistent manual highlight
  }

  // ==================== Data Fetching Methods ====================

  void fetchBookmarks() {
    if (!mounted) return;
    final state = context.read<BookmarkCubit>().state;
    setState(() {
      bookmarks = state.bookmarks;
    });
  }

  static Future<dynamic> _decodeJson(String jsonString) async {
    return json.decode(jsonString);
  }

  Future<void> getTranslationData() async {
    try {
      if (getValue("indexOfTranslationInVerseByVerse") > 1) {
        File file = File(
          "${appDir!.path}/${translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeText}.json",
        );

        if (await file.exists()) {
          String jsonData = await file.readAsString();
          // Check mounted before and after async operation
          if (!mounted) return;
          // Offload JSON decoding to background thread
          dataOfCurrentTranslation = await flutter_foundation.compute(
            _decodeJson,
            jsonData,
          );
        }
      }
      // Only setState if still mounted
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Silently catch errors - widget may be disposed
      if (mounted) {
        setState(() {});
      }
    }
  }

  // [CAN_BE_EXTRACTED] -> helpers/audio_url_fixer.dart
  String fixAudioUrl(String url) {
    if (url.contains('audio-surah')) {
      return url.replaceAll('audio-surah', 'audio');
    }
    return url;
  }

  @override
  void initState() {
    super.initState();

    // Initialize data
    shouldHighlightSura = widget.shouldHighlightSura;
    setIndex();
    initialize();
    addReciters();

    // Setup listeners
    _scrollController.addListener(_scrollListener);
    checkIfSelectHighlight();

    // Setup page controller
    _pageController = PageController(
      initialPage: (widget.pageNumber - 1).clamp(0, 603),
    );
    _pageController.addListener(_pagecontroller_scrollListner);
    _pageController.addListener(_updatePageControllerScrollingState);

    // Add listener for item positions (Vertical / Verse-by-Verse)
    itemPositionsListener.itemPositions.addListener(_itemPositionsListener);
    itemPositionsListener.itemPositions.addListener(_updateScrollingState);

    // Initialize nav highlight animation
    _navHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
    );

    _navHighlightAnimation = CurvedAnimation(
      parent: _navHighlightController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _navHighlightController.addListener(() {
      if (mounted) {
        // Invalidate ONLY the current page index to trigger color update without rebuilding the whole Quran
        _pageSpansCache.remove(index);
        _verticalSpansCache.remove(index);
        setState(() {});
      }
    });

    _navHighlightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _navHighlightController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            highlightVerse = "";
            shouldHighlightText = false;
          });
        }
      }
    });

    // Setup highlight animations
    changeHighlightSurah();
    highlightVerseFunction();

    // Configure system UI
    _configureSystemUI();

    // Initialize chrome controller (starts visible on reader entry, no auto-hide timer)
    _chromeController = ReaderChromeController(initialVisibility: true);
  }

  void toggleAppbar() {
    _chromeController.toggle();
  }

  @override
  void didUpdateWidget(QuranDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageNumber != oldWidget.pageNumber &&
        widget.pageNumber != index) {
      // Only update local state if widget.pageNumber changed due to a deliberate parent update,
      // though now we handle most updates via BlocListener.
      setState(() {
        index = widget.pageNumber;
      });
      // We rely on BlocListener for navigation now to avoid conflicts
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch initial bookmarks from BookmarkCubit once without setState
    if (!_hasFetchedInitialBookmarks) {
      _hasFetchedInitialBookmarks = true;
      bookmarks = context.read<BookmarkCubit>().state.bookmarks;
    }

    // Ensure we only sync the initial reading position once.
    if (!_hasSyncedInitialPosition) {
      _hasSyncedInitialPosition = true;

      // Precache the Quran page background image for smoother transition
      precacheImage(const AssetImage("assets/images/quran.jpg"), context);

      final readerCubit = context.read<QuranReaderCubit>();
      readerCubit.updateFromPageChange(widget.pageNumber);
    }
  }

  // ==================== System UI Configuration ====================

  void _configureSystemUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  // [CAN_BE_EXTRACTED] -> helpers/reciters_helper.dart
  void addReciters() {
    for (final element in _metadataService.reciters) {
      reciters.add(
        QuranPageReciter(
          identifier: element["identifier"],
          language: element["language"],
          name: element["name"],
          englishName: element["englishName"],
          format: element["format"],
          type: element["type"],
          direction: element["direction"],
        ),
      );
    }
  }

  // ==================== Scroll Listeners ====================

  void _scrollListener() {
    // Scrolling must never affect highlight state
  }

  void _pagecontroller_scrollListner() {
    // Scrolling must never affect highlight state
  }

  void _itemPositionsListener() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      // Find the first visible item
      final firstVisible = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce(
            (ItemPosition min, ItemPosition position) =>
                position.itemLeadingEdge < min.itemLeadingEdge ? position : min,
          );

      final int firstVisibleIndex = firstVisible.index;

      // Scrolling must never affect highlight state
      verseHighlightTimer?.cancel();

      // Debounce the update to avoid excessive state changes/writes
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 150), () {
        // Exit if widget was disposed before timer fired
        if (!mounted) return;

        if (index != firstVisibleIndex) {
          // Update the localized index state
          setState(() {
            index = firstVisibleIndex;
          });

          // Update the global cubit state (and persist)
          // We check if it's different to avoid redundant updates
          try {
            final currentCubitPage = context
                .read<QuranReaderCubit>()
                .state
                .position
                .page;
            if (currentCubitPage != firstVisibleIndex) {
              context.read<QuranReaderCubit>().updateFromPageChange(
                firstVisibleIndex,
              );
            }
          } catch (e) {
            // Context may be invalid if widget was disposed
          }
        }
      });
    }
  }

  /// تحديث حالة التمرير للعروض الرأسية والآية بآية
  void _updateScrollingState() {
    // تتبع ما إذا كان التمرير قيد التقدم
    isScrolling = itemPositionsListener.itemPositions.value.isNotEmpty;
  }

  /// تحديث حالة التمرير من PageController (للعرض الأفقي)
  void _updatePageControllerScrollingState() {
    if (_pageController.hasClients) {
      isScrolling = _pageController.position.isScrollingNotifier.value;
    }
  }

  // ==================== Highlight Functions ====================

  Future<void> changeHighlightSurah() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      // Ignore if cancelled
    }
    // Don't modify state after dispose
    if (mounted) {
      setState(() {
        shouldHighlightSura = false;
      });
    }
  }

  void highlightVerseFunction() {
    shouldHighlightText = widget.shouldHighlightText;

    if (!widget.shouldHighlightText) return;

    // إذا كان highlightVerse نص آية، نحوله للتنسيق الجديد
    if (widget.highlightVerse is String &&
        widget.highlightVerse.toString().isNotEmpty) {
      final verseText = widget.highlightVerse.toString();
      try {
        final pageData = _metadataService.getPageData(
          index > 0 ? index : widget.pageNumber,
        );
        for (var e in pageData) {
          for (var i = e["start"]; i <= e["end"]; i++) {
            if (_metadataService.getVerse(e["surah"], i) == verseText) {
              highlightVerse = "${e["surah"]}:$i";
              break;
            }
          }
        }
      } catch (e) {
        highlightVerse = widget.highlightVerse;
      }
    } else {
      highlightVerse = widget.highlightVerse;
    }

    _navHighlightController.forward(from: 0.0);
  }

  void triggerHighlight(int surah, int ayah) {
    if (!mounted) return;

    setState(() {
      shouldHighlightText = true;
      highlightVerse = "$surah:$ayah"; // Matches selectedSpan format
    });

    final targetPage = _metadataService.getPageNumber(surah, ayah);
    _pageSpansCache.remove(targetPage);
    _verticalSpansCache.remove(targetPage);

    _navHighlightController.forward(from: 0.0);
  }

  @override
  void dispose() {
    // Cancel timers
    try {
      timer.cancel();
    } catch (e) {
      // Timer already canceled
    }
    verseTrackingTimer?.cancel();
    _debounceTimer?.cancel();
    _chromeController.dispose();
    verseHighlightTimer?.cancel();

    _navHighlightController.dispose();

    // Cancel subscriptions
    positionSubscription?.cancel();
    processingSubscription?.cancel();

    // Remove listeners
    _scrollController.removeListener(_scrollListener);
    _pageController.removeListener(_pagecontroller_scrollListner);
    _pageController.removeListener(_updatePageControllerScrollingState);
    itemPositionsListener.itemPositions.removeListener(_itemPositionsListener);
    itemPositionsListener.itemPositions.removeListener(_updateScrollingState);

    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Dispose controllers
    _pageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ==================== Utility Methods ====================

  int total = 0;

  int getTotalCharacters(List<String> stringList) {
    total = 0;
    for (String str in stringList) {
      total += str.length;
    }
    return total;
  }

  bool hasLocalBookmark(int surahNumber, int verseNumber) {
    return bookmarks.any(
      (b) =>
          b.isAssigned &&
          b.surahNumber == surahNumber &&
          b.verseNumber == verseNumber,
    );
  }

  Color? localBookmarkColor(int surahNumber, int verseNumber) {
    for (final b in bookmarks) {
      if (b.isAssigned &&
          b.surahNumber == surahNumber &&
          b.verseNumber == verseNumber) {
        return b.color;
      }
    }
    return null;
  }

  /// Resolve the initial page index for scrollable views (vertical / verse-by-verse)
  /// using the QuranReaderCubit when available, otherwise falling back to the
  /// legacy `lastRead` Hive value.
  int getInitialPageIndex(BuildContext context) {
    final readerCubit = context.watch<QuranReaderCubit>();
    final dynamic legacyLastRead = getValue("lastRead");

    if (!readerCubit.state.isLoading) {
      return readerCubit.state.position.page;
    }

    if (legacyLastRead is int && legacyLastRead > 0) {
      return legacyLastRead;
    }

    // Fallback to first page (Al-Fatiha)
    return 1;
  }

  // [CAN_BE_EXTRACTED] -> helpers/quran_page_helper.dart
  Result checkIfPageIncludesQuarterAndQuarterIndex(array, pageData, indexes) {
    for (int i = 0; i < array.length; i++) {
      int surah = array[i]['surah'];
      int ayah = array[i]['ayah'];
      for (int j = 0; j < pageData.length; j++) {
        int pageSurah = pageData[j]['surah'];
        int start = pageData[j]['start'];
        int end = pageData[j]['end'];
        if ((surah == pageSurah) && (ayah >= start) && (ayah <= end)) {
          int targetIndex = i + 1;
          for (int hizbIndex = 0; hizbIndex < indexes.length; hizbIndex++) {
            List<int> hizb = indexes[hizbIndex];
            for (
              int quarterIndex = 0;
              quarterIndex < hizb.length;
              quarterIndex++
            ) {
              if (hizb[quarterIndex] == targetIndex) {
                return Result(true, i, hizbIndex, quarterIndex);
              }
            }
          }
        }
      }
    }
    return Result(false, -1, -1, -1);
  }

  // ==================== Build Method ====================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize = MediaQuery.of(context).size;
    final themeColor = softOffWhites[getValue("quranPageolorsIndex")];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // ✅ لون حقيقي مش transparent عشان ميبانش الأسود
        statusBarColor:
            softOffWhites[getValue(
              "quranPageolorsIndex",
            )], // ← نفس لون الـ Scaffold
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor:
            softOffWhites[getValue(
              "quranPageolorsIndex",
            )], // ← نفس لون الـ Scaffold
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<BookmarkCubit, BookmarkState>(
            listener: (context, state) {
              if (mounted) {
                setState(() {
                  bookmarks = state.bookmarks;
                });
              }
            },
          ),
          BlocListener<AudioPlaybackCubit, AudioPlaybackState>(
            listenWhen: (prev, curr) =>
                prev.currentAyah != curr.currentAyah ||
                prev.surahNumber != curr.surahNumber ||
                prev.hasTiming != curr.hasTiming,
            listener: (context, audioState) {
              if (!mounted) return;
              // Follow recitation position across page boundaries without misleading jumps:
              // Only if timing is verified, ayah is valid (not Basmala), and user is not dragging slider.
              if (audioState.hasTiming && audioState.currentAyah != null) {
                final ayahPage = _metadataService.getPageNumber(
                  audioState.surahNumber,
                  audioState.currentAyah!,
                );
                final readerCubit = context.read<QuranReaderCubit>();
                if (!readerCubit.state.isSliderDragging &&
                    ayahPage >= 1 &&
                    ayahPage <= 604) {
                  final currentPage = _pageController.hasClients
                      ? ((_pageController.page?.round() ?? 0) + 1)
                      : index;
                  if (ayahPage != currentPage) {
                    setState(() {
                      index = ayahPage;
                    });
                    readerCubit.updateFromPageChange(ayahPage);
                    if (_pageController.hasClients) {
                      final diff = (ayahPage - currentPage).abs();
                      final zeroBased = (ayahPage - 1).clamp(0, 603);
                      if (diff > 5) {
                        _pageController.jumpToPage(zeroBased);
                      } else {
                        _pageController.animateToPage(
                          zeroBased,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutQuart,
                        );
                      }
                    }
                    if (itemScrollController.isAttached) {
                      itemScrollController.jumpTo(index: ayahPage);
                    }
                    _tafsirPageKey.currentState?.jumpToPage(ayahPage);
                  }
                }
              }
            },
          ),
          BlocListener<QuranReaderCubit, QuranReadingState>(
            listenWhen: (previous, current) =>
                previous.position.page != current.position.page ||
                previous.targetHighlightVerse != current.targetHighlightVerse,
            listener: (context, state) {
              if (!mounted) return;

              final int targetPage = state.position.page;
              // Use the controller's page as the truth if available, otherwise fallback to index.
              // This prevents conflicts if didUpdateWidget updated 'index' prematurely.
              final int currentPage = _pageController.hasClients
                  ? ((_pageController.page?.round() ?? 0) + 1)
                  : index;

              if (targetPage != currentPage) {
                setState(() {
                  index = targetPage;
                });
                if (_pageController.hasClients) {
                  final int diff = (targetPage - currentPage).abs();
                  final int zeroBasedTarget = (targetPage - 1).clamp(0, 603);
                  if (diff > 5) {
                    _pageController.jumpToPage(zeroBasedTarget);
                  } else {
                    _pageController.animateToPage(
                      zeroBasedTarget,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutQuart,
                    );
                  }
                }
                if (itemScrollController.isAttached) {
                  itemScrollController.jumpTo(index: targetPage);
                }
                _tafsirPageKey.currentState?.jumpToPage(targetPage);
              }

              if (state.targetHighlightVerse != null) {
                final parts = state.targetHighlightVerse!.split(':');
                if (parts.length == 2) {
                  final s = int.tryParse(parts[0]);
                  final a = int.tryParse(parts[1]);
                  if (s != null && a != null) {
                    triggerHighlight(s, a);
                    context.read<QuranReaderCubit>().clearHighlight();
                  }
                }
              }
            },
          ),
        ],
        child: BlocBuilder<QuranPagePlayerBloc, QuranPagePlayerState>(
          builder: (context, state) {
            return Scaffold(
              key: scaffoldKey,
              resizeToAvoidBottomInset: false,
              extendBody: true, // ✅ أضف هذا
              extendBodyBehindAppBar: true,
              backgroundColor: softOffWhites[getValue("quranPageolorsIndex")],
              // extendBodyBehindAppBar: true,
              body: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is UserScrollNotification &&
                          notification.direction != ScrollDirection.idle) {
                        _chromeController.hide();
                      } else if (notification is ScrollStartNotification &&
                          notification.dragDetails != null) {
                        _chromeController.hide();
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap: () {
                        toggleAppbar();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Builder(
                        builder: (context2) {
                          return _buildAlignmentView(screenSize, context);
                        },
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _chromeController,
                    builder: (context, isChromeVisible, _) {
                      return Stack(
                        children: [
                          // Floating App Bar
                          BlocBuilder<QuranReaderCubit, QuranReadingState>(
                            buildWhen: (prev, curr) =>
                                prev.isTafsirMode != curr.isTafsirMode,
                            builder: (context, readerState) {
                              return BlocBuilder<TafsirCubit, TafsirState>(
                                builder: (context, tafsirState) {
                                  return FloatingQuranAppBar(
                                    isVisible: isChromeVisible,
                                    backgroundColor:
                                        softOffWhites[getValue(
                                          "quranPageolorsIndex",
                                        )],
                                    iconColor:
                                        secondaryColors[getValue(
                                          "quranPageolorsIndex",
                                        )],
                                    tafsirBookTitle: readerState.isTafsirMode
                                        ? (tafsirState.selectedBook?.name ??
                                              'الميسر')
                                        : null,
                                    onSelectTafsirBook: () =>
                                        TafsirBookPickerSheet.show(context),
                                    onIndex: () async {
                                      final result =
                                          await QuranDetailsPageState.showSurahNavigatorSheet(
                                            context,
                                          );
                                      if (result != null) {
                                        final readerCubit = context
                                            .read<QuranReaderCubit>();
                                        if (result is int) {
                                          readerCubit.goToPage(result);
                                        } else if (result is Map) {
                                          readerCubit.goToPage(
                                            result['pageNumber'],
                                          );
                                          triggerHighlight(
                                            result['surah'],
                                            result['ayah'],
                                          );
                                        }
                                      }
                                    },
                                    onSearch: () async {
                                      final result = await context
                                          .push<SearchNavigationTarget>(
                                            AppRoutes.search,
                                          );
                                      if (result != null && mounted) {
                                        context
                                            .read<QuranReaderCubit>()
                                            .goToPage(result.pageNumber);
                                        if (result.surahNumber != null &&
                                            result.ayahNumber != null) {
                                          triggerHighlight(
                                            result.surahNumber!,
                                            result.ayahNumber!,
                                          );
                                        }
                                      }
                                    },
                                    onToday: () {
                                      final todayCubit = context
                                          .read<TodayCubit>();
                                      todayCubit.loadTodayAyah();
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => BlocProvider.value(
                                          value: todayCubit,
                                          child: TodayAyahSheet(
                                            onShare: (ayah) {
                                              showDialog(
                                                context: context,
                                                builder: (_) => ShareAyahDialog(
                                                  surahNumber: ayah.surahNumber,
                                                  verseNumber: ayah.ayahNumber,
                                                  index: ayah.pageNumber,
                                                  jsonData:
                                                      widget.jsonData ??
                                                      JsonAssetService
                                                          .surahsData,
                                                  translationDataList:
                                                      translationDataList,
                                                ),
                                              );
                                            },
                                            onTafsir: (ayah) {
                                              Navigator.of(context).pop();
                                              final readerCubit = context
                                                  .read<QuranReaderCubit>();
                                              readerCubit.goToPage(
                                                ayah.pageNumber,
                                              );
                                              readerCubit.toggleTafsirMode(
                                                enable: true,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    onSettings: () {
                                      SettingsBottomSheet.show(
                                        context,
                                        onSettingsChanged: () {
                                          _pageSpansCache.clear();
                                          getTranslationData();
                                          updateState(() {});
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          // Floating Return Button with Page Number (AGENTS.md Section 14)
                          BlocBuilder<QuranReaderCubit, QuranReadingState>(
                            buildWhen: (prev, curr) =>
                                prev.returnPage != curr.returnPage,
                            builder: (context, readerState) {
                              return Positioned(
                                bottom: isChromeVisible ? 124.h : 74.h,
                                right: 20.w,
                                child: MushafReturnButton(
                                  returnPage: readerState.returnPage,
                                  onReturn: () {
                                    context
                                        .read<QuranReaderCubit>()
                                        .returnToPreviousPage();
                                  },
                                  onDismiss: () {
                                    context
                                        .read<QuranReaderCubit>()
                                        .dismissReturnPage();
                                  },
                                ),
                              );
                            },
                          ),
                          // Floating Audio Player (Ref 05 & Video 37)
                          BlocBuilder<AudioPlaybackCubit, AudioPlaybackState>(
                            builder: (context, audioState) {
                              final isAudioActive =
                                  audioState.status != PlaybackStatus.idle;
                              final bool shouldShow =
                                  isChromeVisible || isAudioActive;

                              final double bottomOffset = isChromeVisible
                                  ? (MediaQuery.of(context).padding.bottom +
                                        68.h)
                                  : (MediaQuery.of(context).padding.bottom +
                                        16.h);

                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuart,
                                bottom: shouldShow ? bottomOffset : -160.h,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: FloatingAudioPlayer(
                                    onPlayFallback: () {
                                      final pageData = _metadataService
                                          .getPageData(index);
                                      if (pageData.isNotEmpty) {
                                        final first = pageData.first;
                                        context
                                            .read<AudioPlaybackCubit>()
                                            .playAyah(
                                              first['surah'] as int,
                                              first['start'] as int,
                                            );
                                      } else {
                                        context
                                            .read<AudioPlaybackCubit>()
                                            .playAyah(1, 1);
                                      }
                                    },
                                    onSettingsPressed: () {
                                      RecitationSettingsSheet.show(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          // Bottom Page Slider Toolbar (Ref 05)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutQuart,
                            bottom: isChromeVisible ? 0 : -90.h,
                            left: 0,
                            right: 0,
                            child:
                                BlocBuilder<
                                  QuranReaderCubit,
                                  QuranReadingState
                                >(
                                  buildWhen: (prev, curr) =>
                                      prev.position.page !=
                                          curr.position.page ||
                                      prev.isSliderDragging !=
                                          curr.isSliderDragging ||
                                      prev.draggingPage != curr.draggingPage,
                                  builder: (context, readerState) {
                                    return Container(
                                      color:
                                          softOffWhites[getValue(
                                                "quranPageolorsIndex",
                                              )]
                                              .withOpacity(0.96),
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).padding.bottom +
                                            4.h,
                                      ),
                                      child: MushafPageSlider(
                                        currentPage: readerState.position.page,
                                        isTafsirMode: readerState.isTafsirMode,
                                        onDragStarted: (startPage) {
                                          context
                                              .read<QuranReaderCubit>()
                                              .onSliderDragStarted(startPage);
                                        },
                                        onScrubbing: (scrubPage) {
                                          context
                                              .read<QuranReaderCubit>()
                                              .onSliderScrubbing(scrubPage);
                                        },
                                        onPageSelected: (selectedPage) {
                                          context
                                              .read<QuranReaderCubit>()
                                              .onSliderDragEnded(selectedPage);
                                        },
                                        onTafseerPressed: () {
                                          context
                                              .read<QuranReaderCubit>()
                                              .toggleTafsirMode();
                                        },
                                      ),
                                    );
                                  },
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<dynamic> showSurahNavigatorSheet(BuildContext context) {
    if (!context.mounted) return Future.value(null);
    // Capture cubits to pass them into the modal route
    final bookmarkCubit = context.read<BookmarkCubit>();
    final quranReaderCubit = context.read<QuranReaderCubit>();

    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      ),
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: bookmarkCubit),
            BlocProvider.value(value: quranReaderCubit),
          ],
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SurahListPage(
              jsonData: JsonAssetService.surahsData,
              quarterjsonData: JsonAssetService.quartersData,
            ),
          ),
        );
      },
    );
  }

  /// Displays the pixel-faithful Ayah Picker sheet (Ref 38 & 39).
  static Future<int?> showAyahPickerSheet(
    BuildContext context, {
    required int surahNumber,
    int? initialAyahNumber,
  }) async {
    final result = await AyahPickerSheet.show(
      context,
      surahNumber: surahNumber,
      initialAyahNumber: initialAyahNumber,
    );
    return result?.ayahNumber;
  }

  // ==================== View Selection ====================

  Widget _buildAlignmentView(Size screenSize, BuildContext context) {
    final readerState = context.watch<QuranReaderCubit>().state;
    if (readerState.isTafsirMode) {
      return TafsirPageView(
        key: _tafsirPageKey,
        initialPage: index,
        onPageChanged: (newPageNumber) {
          updateState(() {
            index = newPageNumber;
          });
          context.read<QuranReaderCubit>().updateFromPageChange(newPageNumber);
        },
        onToggleChrome: toggleAppbar,
        onVerseLongPress: (surah, ayah) {
          selectedSpan = "$surah:$ayah";
          context.read<QuranReaderCubit>().selectAyah(surah, ayah);
          final page = _metadataService.getPageNumber(surah, ayah);
          showAyahOptionsSheet(page, surah, ayah);
        },
      );
    }

    final alignmentType = getValue("alignmentType");

    switch (alignmentType) {
      case "verticalview":
        return buildVerticalView(screenSize, context);
      case "pageview":
        return buildPageView(context, screenSize);
      case "versebyverse":
        return buildVerseByVerseView(screenSize, context);
      default:
        return buildVerseByVerseView(screenSize, context);
    }
  }

  bool isVerseStarred(int surah, int ayah) {
    try {
      return context.read<StarredCubit>().isStarred(surah, ayah);
    } catch (_) {
      if (sl.isRegistered<StarredCubit>()) {
        return sl<StarredCubit>().isStarred(surah, ayah);
      }
      return starredVerses.contains("$surah:$ayah") ||
          starredVerses.contains("$surah-$ayah");
    }
  }

  void showAyahOptionsSheet(int index, int surahNumber, int verseNumber) {
    if (!mounted) return;

    final quranReaderCubit = context.read<QuranReaderCubit>();
    quranReaderCubit.selectAyah(surahNumber, verseNumber);

    AyahOptionsSheet.show(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      isStarred: isVerseStarred(surahNumber, verseNumber),
      onStarTap: () {
        try {
          context.read<StarredCubit>().toggleStarred(surahNumber, verseNumber);
        } catch (_) {
          if (sl.isRegistered<StarredCubit>()) {
            sl<StarredCubit>().toggleStarred(surahNumber, verseNumber);
          }
        }
        setState(() {});
      },
      onShareTap: () {
        showDialog(
          context: context,
          builder: (_) => ShareAyahDialog(
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            index: index,
            jsonData: widget.jsonData ?? JsonAssetService.surahsData,
            translationDataList: translationDataList,
          ),
        );
      },
      onBookmarkTap: () {
        context.read<BookmarkCubit>().toggleRedBookmark(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: index,
        );
        Navigator.of(context).pop();
      },
      onAnotherBookmarkTap: () {
        final bCubit = context.read<BookmarkCubit>();
        Navigator.of(context).pop();
        BookmarkPickerDialog.show(
          context: context,
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: index,
          bookmarks: bCubit.state.bookmarks,
          onSelectBookmark: (bookmarkId) {
            bCubit.assignBookmark(
              id: bookmarkId,
              surahNumber: surahNumber,
              verseNumber: verseNumber,
              pageNumber: index,
            );
          },
          onAddNewBookmark: (newBookmark) {
            bCubit.addCustomBookmark(newBookmark);
          },
        );
      },
      onReciteTap: () {
        Navigator.of(context).pop();
        context.read<AudioPlaybackCubit>().playAyah(surahNumber, verseNumber);
      },
      onPlayToTap: () {
        Navigator.of(context).pop();
        PlayToSheet.show(
          context,
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          isStarred: isVerseStarred(surahNumber, verseNumber),
          onStarTap: () {
            try {
              context.read<StarredCubit>().toggleStarred(surahNumber, verseNumber);
            } catch (_) {
              if (sl.isRegistered<StarredCubit>()) {
                sl<StarredCubit>().toggleStarred(surahNumber, verseNumber);
              }
            }
            setState(() {});
          },
          onShareTap: () {
            showDialog(
              context: context,
              builder: (_) => ShareAyahDialog(
                surahNumber: surahNumber,
                verseNumber: verseNumber,
                index: index,
                jsonData: widget.jsonData ?? JsonAssetService.surahsData,
                translationDataList: translationDataList,
              ),
            );
          },
        );
      },
      onLibraryTap: () {
        Navigator.of(context).pop();
        context.read<QuranReaderCubit>().toggleTafsirMode(enable: true);
      },
      onNotesTap: () {
        Navigator.of(context).pop();
        NoteEditorDialog.show(
          context: context,
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: index,
        );
      },
    ).then((_) {
      if (mounted) {
        quranReaderCubit.clearSelectedAyah();
        setState(() {
          selectedSpan = "";
        });
      }
    });
  }

  Future<void> addStarredVerse(int surahNumber, int verseNumber) async {
    try {
      await context.read<StarredCubit>().addStarred(surahNumber, verseNumber);
    } catch (_) {
      if (sl.isRegistered<StarredCubit>()) {
        await sl<StarredCubit>().addStarred(surahNumber, verseNumber);
      }
    }
    setState(() {});
  }

  Future<void> removeStarredVerse(int surahNumber, int verseNumber) async {
    try {
      await context.read<StarredCubit>().removeStarred(surahNumber, verseNumber);
    } catch (_) {
      if (sl.isRegistered<StarredCubit>()) {
        await sl<StarredCubit>().removeStarred(surahNumber, verseNumber);
      }
    }
    setState(() {});
  }

  void updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  List<InlineSpan> _buildMushafSpans(
    int index,
    Map<int, List<InlineSpan>> cache,
  ) {
    if (cache.containsKey(index)) {
      return cache[index]!;
    }

    List<InlineSpan> spans = _metadataService.getPageData(index).expand((e) {
      List<InlineSpan> iterSpans = [];
      for (var i = e["start"]; i <= e["end"]; i++) {
        // Header
        if (i == 1) {
          iterSpans.add(
            WidgetSpan(
              child: HeaderWidget(e: e, jsonData: widget.jsonData),
            ),
          );

          if (index != 187 && index != 1) {
            iterSpans.add(
              WidgetSpan(
                child: Basmallah(index: getValue("quranPageolorsIndex")),
              ),
            );
          }
          if (index == 187 || index == 1) {
            iterSpans.add(WidgetSpan(child: Container(height: 10.h)));
          }
        }

        // Verses
        iterSpans.add(
          TextSpan(
            locale: const Locale("ar"),
            recognizer:
                LongPressGestureRecognizer(
                    duration: const Duration(milliseconds: 300),
                  )
                  ..onLongPress = () {
                    verseHighlightTimer?.cancel();
                    _pageSpansCache.remove(index);
                    _verticalSpansCache.remove(index);
                    updateState(() {
                      selectedSpan = "${e["surah"]}:$i";
                    });
                    showAyahOptionsSheet(index, e["surah"], i);
                  },
            text: i == e["start"]
                ? "${_metadataService.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${_metadataService.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                : _metadataService
                      .getVerseQCF(e["surah"], i)
                      .replaceAll(' ', ''),
            style: TextStyle(
              height: (index == 1 || index == 2) ? 2.h : 1.95.h,
              letterSpacing: 0.w,
              wordSpacing: 0,
              color: darkWarmBrowns[getValue("quranPageolorsIndex")],
              fontSize: index == 1 || index == 2
                  ? 28.sp
                  : index == 145 || index == 201
                  ? index == 532 || index == 533
                        ? 22.5.sp
                        : 22.4.sp
                  : 22.9.sp,
              fontFamily: qp.QcfFontLoader.getBaseFontFamily(index),
              backgroundColor: selectedSpan == "${e["surah"]}:$i"
                  ? secondaryColors[getValue("quranPageolorsIndex")]
                        .withOpacity(0.3)
                  : (shouldHighlightText == true &&
                        highlightVerse == "${e["surah"]}:$i")
                  ? Color.lerp(
                      Colors.transparent,
                      secondaryColors[getValue("quranPageolorsIndex")]
                          .withOpacity(0.4),
                      _navHighlightAnimation.value,
                    )
                  : hasLocalBookmark(e["surah"] as int, i as int)
                  ? localBookmarkColor(
                          e["surah"] as int,
                          i,
                        )?.withOpacity(.19) ??
                        Colors.transparent
                  : Colors.transparent,
            ),
          ),
        );
        if (hasLocalBookmark(e["surah"] as int, i)) {
          iterSpans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.bookmark,
                color:
                    localBookmarkColor(e["surah"] as int, i) ??
                    secondaryColors[getValue("quranPageolorsIndex")],
              ),
            ),
          );
        }
      }
      return iterSpans;
    }).toList();

    cache[index] = spans;
    return spans;
  }
}

class Result {
  bool includesQuarter;
  int index;
  int hizbIndex;
  int quarterIndex;

  Result(this.includesQuarter, this.index, this.hizbIndex, this.quarterIndex);
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
    : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 50, stiffness: 100, damping: 0.8);
}
