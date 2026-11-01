// ignore_for_file: file_names

part of '../quran_details_page.dart';

final Map<int, List<InlineSpan>> _verticalSpansCache = {};

/// متغير لتتبع الجزء الحالي في العرض الرأسي
// int _currentVerticalJuzNotificationIndex = -1;

extension VerticalViewExtension on QuranDetailsPageState {
  /// التحقق من بداية جزء جديد وإظهار إشعار في العرض الرأسي
  // void _checkAndShowVerticalJuzNotification(int currentPageIndex) {
  //   if (currentPageIndex == 0) return; // تجاهل صفحة الغلاف

  //   final currentPageData = quran.getPageData(currentPageIndex);
  //   if (currentPageData.isEmpty) return;

  //   final firstVerseData = currentPageData[0];
  //   final currentJuzNumber = getJuzNumber(
  //     firstVerseData["surah"],
  //     firstVerseData["start"],
  //   );

  //   // إذا كان الجزء الحالي مختلفًا عن السابق
  //   if (currentJuzNumber != _currentVerticalJuzNotificationIndex) {
  //     _currentVerticalJuzNotificationIndex = currentJuzNumber;

  //     // إظهار الإشعار
  //     Fluttertoast.showToast(
  //       msg: "➤ ${"juz".tr()} ${_getArabicOrdinalJuzName(currentJuzNumber)}",
  //       backgroundColor: secondaryColors[getValue("quranPageolorsIndex")],
  //       textColor: softOffWhites[getValue("quranPageolorsIndex")],
  //       gravity: ToastGravity.CENTER,
  //     );
  //   }
  // }

  Scaffold buildVerticalView(Size screenSize, BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: softOffWhites[getValue("quranPageolorsIndex")],
      body: Stack(
        children: [
          ScrollablePositionedList.separated(
            itemCount: quran.totalPagesCount + 1,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) {
              if (index == 0) return Container();

              // ✅ هنا بقا بيستخدم index الصح
              final surahsOnPage = quran.getPageData(index);
              final surahNames = surahsOnPage
                  .map((s) => widget.jsonData[s["surah"] - 1]["name"] as String)
                  .toSet()
                  .join(" | ");
              if (index == 0) return Container();
              return Container(
                color: secondaryColors[getValue("quranPageolorsIndex")],
                width: double.infinity,
                height: 30.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        checkIfPageIncludesQuarterAndQuarterIndex(
                                        widget.quarterJsonData, quran.getPageData(index), indexes)
                                    .includesQuarter ==
                                true
                            ? "${"page".tr()} ${convertToArabicNumber(index.toString())} | ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex + 1) == 1 ? "" : "${convertToArabicNumber((checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex).toString())}/${convertToArabicNumber(4.toString())}"} ${"hizb".tr()} ${convertToArabicNumber((checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).hizbIndex + 1).toString())} | ${"juz".tr()} ${_getArabicOrdinalJuzName(getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"]))}"
                            : "${"page".tr()} ${convertToArabicNumber(index.toString())} | ${"juz".tr()} ${_getArabicOrdinalJuzName(getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"]))}",
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: softOffWhites[getValue("quranPageolorsIndex")]),
                      ),
                      Text(
                        surahNames, // ✅
                        style: TextStyle(
                          color: softOffWhites[getValue("quranPageolorsIndex")],
                          fontFamily: "Taha",
                          fontSize: 16.sp,
                          letterSpacing: 0.3,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            itemScrollController: itemScrollController,
            initialScrollIndex: getInitialPageIndex(context),
            itemPositionsListener: itemPositionsListener,
            itemBuilder: (context, index) {
              // تنظيف التظليل عند تغيير الصفحة في العرض الرأسي
              verseHighlightTimer?.cancel();

              // التحقق من بداية جزء جديد
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   _checkAndShowVerticalJuzNotification(index);
              // });

              // updateValue("lastRead", index);
              // bool isEvenPage = index.isEven;

              if (index == 0) {
                return Container(
                  color: const Color(0xffFFFCE7),
                  child: Image.asset(
                    "assets/images/quran.jpg",
                    fit: BoxFit.fill,
                  ),
                );
              }

              return KeepAlivePage(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 12.h),
                    MushafDivider(color: secondaryColors[getValue("quranPageolorsIndex")]),
                    Directionality(
                      textDirection: m.TextDirection.rtl,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: RepaintBoundary(
                            child: RichText(
                              key: richTextKeys[index - 1],
                              textDirection: m.TextDirection.rtl,
                              textAlign: TextAlign.center,
                              softWrap: true, //locale: const Locale("ar"),
                              text: TextSpan(
                                locale: const Locale("ar"),
                                children: _buildVerticalPageSpans(index),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    MushafDivider(color: secondaryColors[getValue("quranPageolorsIndex")]),
                    SizedBox(height: 12.h),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildVerticalPageSpans(int index) {
    return _buildMushafSpans(index, _verticalSpansCache);
  }
}
