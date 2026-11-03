// ignore_for_file: file_names

part of '../quran_details_page.dart';

final Map<int, List<InlineSpan>> _pageSpansCache = {};

/// تحويل رقم الجزء (1-30) إلى صيغة ترتيبية بالعربية
String _getArabicOrdinalJuzName(int juzNumber) {
  const arabicOrdinals = [
    'الأول',
    'الثاني',
    'الثالث',
    'الرابع',
    'الخامس',
    'السادس',
    'السابع',
    'الثامن',
    'التاسع',
    'العاشر',
    'الحادي عشر',
    'الثاني عشر',
    'الثالث عشر',
    'الرابع عشر',
    'الخامس عشر',
    'السادس عشر',
    'السابع عشر',
    'الثامن عشر',
    'التاسع عشر',
    'العشرون',
    'الحادي والعشرون',
    'الثاني والعشرون',
    'الثالث والعشرون',
    'الرابع والعشرون',
    'الخامس والعشرون',
    'السادس والعشرون',
    'السابع والعشرون',
    'الثامن والعشرون',
    'التاسع والعشرون',
    'الثلاثون',
  ];

  if (juzNumber >= 1 && juzNumber <= 30) {
    return arabicOrdinals[juzNumber - 1];
  }
  return juzNumber.toString();
}



/// متغير لتتبع الجزء الحالي
// int _currentJuzNotificationIndex = -1;

extension PageViewExtension on QuranDetailsPageState {
  /// التحقق من بداية جزء جديد وإظهار إشعار
  // void _checkAndShowJuzNotification(BuildContext context, int currentPageIndex) {
  //   if (currentPageIndex == 0) return; // تجاهل صفحة الغلاف

  //   final currentPageData = quran.getPageData(currentPageIndex);
  //   if (currentPageData.isEmpty) return;

  //   final firstVerseData = currentPageData[0];
  //   final currentJuzNumber = getJuzNumber(
  //     firstVerseData["surah"],
  //     firstVerseData["start"],
  //   );

  //   // إذا كان الجزء الحالي مختلفًا عن السابق
  //   if (currentJuzNumber != _currentJuzNotificationIndex) {
  //     _currentJuzNotificationIndex = currentJuzNumber;

  //     // إظهار الإشعار
  //     Fluttertoast.showToast(
  //       msg: "➤ ${"juz".tr()} ${_getArabicOrdinalJuzName(currentJuzNumber)}",
  //       backgroundColor: secondaryColors[getValue("quranPageolorsIndex")],
  //       textColor: softOffWhites[getValue("quranPageolorsIndex")],
  //       gravity: ToastGravity.CENTER,
  //     );
  //   }
  // }

  Widget buildPageView(BuildContext context, Size screenSize) {
    final activeHighlights = <qp.HighlightVerse>[];

    // Bookmarks highlights
    final bookmarkCubit = context.watch<BookmarkCubit>();
    for (final bookmark in bookmarkCubit.state.bookmarks) {
      Color bookmarkColor;
      try {
        final hex = bookmark.color.replaceFirst('#', '');
        bookmarkColor = Color(int.parse(hex.length == 6 ? '0xFF$hex' : '0x$hex'));
      } catch (_) {
        bookmarkColor = secondaryColors[getValue("quranPageolorsIndex")];
      }
      activeHighlights.add(
        qp.HighlightVerse(
          verseNumber: bookmark.verseNumber,
          surah: bookmark.suraNumber,
          page: _metadataService.getPageNumber(bookmark.suraNumber, bookmark.verseNumber),
          color: bookmarkColor.withOpacity(0.2),
        ),
      );
    }

    // Selected or searched verse highlight
    if (selectedSpan.isNotEmpty && selectedSpan.contains(':')) {
      final parts = selectedSpan.split(':');
      final s = int.tryParse(parts[0]) ?? 1;
      final a = int.tryParse(parts[1]) ?? 1;
      activeHighlights.add(
        qp.HighlightVerse(
          surah: s,
          verseNumber: a,
          page: _metadataService.getPageNumber(s, a),
          color: secondaryColors[getValue("quranPageolorsIndex")].withOpacity(0.35),
        ),
      );
    } else if (shouldHighlightText && highlightVerse is String && highlightVerse.contains(':')) {
      final parts = highlightVerse.split(':');
      final s = int.tryParse(parts[0]) ?? 1;
      final a = int.tryParse(parts[1]) ?? 1;
      activeHighlights.add(
        qp.HighlightVerse(
          surah: s,
          verseNumber: a,
          page: _metadataService.getPageNumber(s, a),
          color: secondaryColors[getValue("quranPageolorsIndex")].withOpacity(0.35),
        ),
      );
    }

    return FutureBuilder<void>(
      future: qp.QcfFontLoader.ensureFontLoaded(index),
      builder: (context, snapshot) {
        if (!qp.QcfFontLoader.isFontLoaded(index) &&
            snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return qp.QuranPageView(
          pageController: _pageController,
          highlights: activeHighlights,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          isTajweed: false,
          quranPagesCount: 604,
          onPageChanged: (newPageNumber) {
            verseHighlightTimer?.cancel();
            updateState(() {
              index = newPageNumber;
            });
            qp.QcfFontLoader.preloadPages(newPageNumber);
            final readerCubit = context.read<QuranReaderCubit>();
            readerCubit.updateFromPageChange(newPageNumber);
          },
          onVerseTap: (surah, verse) {
            toggleAppbar();
          },
          onLongPress: (surah, verse, details) {
            verseHighlightTimer?.cancel();
            updateState(() {
              selectedSpan = "$surah:$verse";
            });
            final page = _metadataService.getPageNumber(surah, verse);
            showAyahOptionsSheet(page, surah, verse);
          },
          pageHeaderBuilder: (context, pageNum) {
            return MushafPageHeader(pageNumber: pageNum);
          },
          bottomBar: MushafPageFooter(pageNumber: index),
          pageBackgroundColor: Colors.transparent,
          enableTwoPageLayout: false,
        );
      },
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
