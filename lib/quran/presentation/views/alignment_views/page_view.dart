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

  PageView buildPageView(BuildContext context, Size screenSize) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      allowImplicitScrolling: true,
      pageSnapping: true,
      padEnds: false,

      onPageChanged: (a) {
        // إلغاء أي مؤقت تظليل قيد التشغيل
        verseHighlightTimer?.cancel();

        updateState(() {
          index = a;
        });

        final readerCubit = context.read<QuranReaderCubit>();
        readerCubit.updateFromPageChange(a);

        // التحقق من بداية جزء جديد وإظهار الإشعار
        // _checkAndShowJuzNotification(context, a);
      },
      controller: _pageController,
      // onPageChanged: _onPageChanged,
      reverse: context.locale.languageCode == "ar" ? false : true,
      itemCount: quran.totalPagesCount + 1 /* specify the total number of pages */,
      itemBuilder: (context, idx) {
        // Preload next and prev pages spans when scrolling
        // if (_pageController.hasClients && _pageController.position.isScrollingNotifier.value) {
        //   if (idx < quran.totalPagesCount) _buildPageSpans(idx + 1);
        //   if (idx > 1) _buildPageSpans(idx - 1);
        // }

        final bool isEvenPage = idx.isEven;

        if (idx == 0) {
          return Container(
            color: const Color(0xffFFFCE7),
            child: Image.asset(
              "assets/images/quran.jpg",
              fit: BoxFit.fill,
            ),
          );
        }

        return KeepAlivePage(
          child: _buildQuranPage(idx, isEvenPage, screenSize, context),
        );
      },
    );
  }

  Widget _buildQuranPage(int index, bool isEvenPage, Size screenSize, BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 4.h),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  right: 12.0.w,
                  left: 12.w,
                ),
                child: _buildBodyPageView(index, screenSize),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(right: 12.w, left: 12.w, top: 2.h),
                child: MushafDivider(color: secondaryColors[getValue("quranPageolorsIndex")]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  right: 20.w,
                ),
                child: _buildFooterPageView(index),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 4.h),
            ),
          ],
        ),
      ),
    );
  }

  Center _buildFooterPageView(int index) {
    return Center(
      child: Builder(
        builder: (context) {
          final quarterResult = checkIfPageIncludesQuarterAndQuarterIndex(
              widget.quarterJsonData, quran.getPageData(index), indexes);

          return quarterResult.includesQuarter
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/numberP.png',
                        height: 27.h,
                      ),
                      Text(
                        "${"page".tr()} ${convertToArabicNumber(index.toString())}  |  ${(quarterResult.quarterIndex + 1) == 1 ? "" : "${convertToArabicNumber((quarterResult.quarterIndex).toString())}/${convertToArabicNumber(4.toString())}"} ${"hizb".tr()} ${convertToArabicNumber((quarterResult.hizbIndex + 1).toString())}",
                        style: TextStyle(
                          fontFamily: 'aldahabi',
                          fontSize: 10.sp,
                          color: secondaryColors[getValue("quranPageolorsIndex")],
                        ),
                      ),
                    ],
                  ),
                )
              : Align(
                  alignment: Alignment.centerRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/numberP.png',
                        height: 20.h,
                      ),
                      Text(
                        "${"page".tr()} ${convertToArabicNumber(index.toString())}",
                        style: TextStyle(
                          fontFamily: 'aldahabi',
                          fontSize: 11.sp,
                          color: secondaryColors[getValue("quranPageolorsIndex")],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  SizedBox _buildBodyPageView(int index, Size screenSize) {
    // استخرج كل السور في الصفحة
    final surahsOnPage = quran.getPageData(index);

// اعمل list بأسماء السور
    final surahNames = surahsOnPage
        .map((s) => widget.jsonData[s["surah"] - 1]["name"] as String)
        .toSet() // لو نفس السورة اتكررت في أكتر من حزب
        .join(" | ");
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          if ((index == 1 || index == 2))
            SizedBox(
              height: (screenSize.height * .24),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${"juz".tr()} ${_getArabicOrdinalJuzName(getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"]))}",
                  style: TextStyle(
                    fontFamily: 'aldahabi',
                    fontSize: 14.sp,
                    color: secondaryColors[getValue("quranPageolorsIndex")],
                  ),
                ),
                Text(
                  surahNames,
                  style: TextStyle(
                    color: secondaryColors[getValue("quranPageolorsIndex")],
                    fontFamily: "Taha",
                    fontSize: 16.sp,
                    letterSpacing: 0.3,
                  ),
                )
              ],
            ),
          ),
          MushafDivider(color: secondaryColors[getValue("quranPageolorsIndex")]),
          Directionality(
            textDirection: m.TextDirection.rtl,
            child: SizedBox(
              width: double.infinity,
              child: RepaintBoundary(
                child: RichText(
                  key: richTextKeys[index - 1],
                  textDirection: m.TextDirection.rtl,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  text: TextSpan(
                    locale: const Locale("ar"),
                    children: _buildPageSpans(index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildPageSpans(int index) {
    return _buildMushafSpans(index, _pageSpansCache);
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
