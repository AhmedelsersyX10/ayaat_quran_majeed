// ignore_for_file: file_names

part of '../quran_details_page.dart';

extension VerseByVerseViewExtension on QuranDetailsPageState {
  Scaffold buildVerseByVerseView(Size screenSize, BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: softOffWhites[getValue("quranPageolorsIndex")],
      body: ScrollablePositionedList.separated(
        itemCount: quran.totalPagesCount + 1,
        separatorBuilder: (context, index) {
          if (index == 0) return Container();
          return Container(
            color: secondaryColors[getValue("quranPageolorsIndex")],
            width: double.infinity,
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
                    widget.jsonData[quran.getPageData(index)[0]["surah"] - 1]["name"],
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamilies[0],
                        color: softOffWhites[getValue("quranPageolorsIndex")]),
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
          // تنظيف التظليل عند تغيير الصفحة في عرض الآية بآية
          verseHighlightTimer?.cancel();

          if (index == 0) {
            return Container(
              color: const Color(0xffFFFCE7),
              child: Image.asset(
                "assets/images/quran.jpg",
                fit: BoxFit.fill,
              ),
            );
          }
          return MushafPageShell(
            screenSize: screenSize,
            isEvenPage: index.isEven,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 4.h),
                MushafDivider(color: secondaryColors[getValue("quranPageolorsIndex")]),
                SizedBox(height: 6.h),
                Directionality(
                  textDirection: m.TextDirection.rtl,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: SizedBox(
                        width: double.infinity,
                        child: RichText(
                          key: richTextKeys[index - 1],
                          textDirection: m.TextDirection.rtl,
                          textAlign: TextAlign.right,
                          softWrap: true,
                          text: TextSpan(
                            locale: const Locale("ar"),
                            children: quran.getPageData(index).expand((e) {
                              List<InlineSpan> spans = [];
                              for (var i = e["start"]; i <= e["end"]; i++) {
                                // Header
                                if (i == 1) {
                                  spans.add(WidgetSpan(
                                    child: HeaderWidget(e: e, jsonData: widget.jsonData),
                                  ));

                                  if (index != 187 && index != 1) {
                                    spans.add(WidgetSpan(
                                        child: Basmallah(
                                      index: getValue("quranPageolorsIndex"),
                                    )));
                                  }
                                  if (index == 187 || index == 1) {
                                    spans.add(WidgetSpan(
                                        child: Container(
                                      height: 10.h,
                                    )));
                                  }
                                }

                                // Verses
                                spans.add(TextSpan(
                                  locale: const Locale("ar"),
                                  children: [
                                    TextSpan(
                                      recognizer: LongPressGestureRecognizer(
                                        duration: const Duration(milliseconds: 300),
                                      )..onLongPress = () {
                                          verseHighlightTimer?.cancel();
                                          _pageSpansCache.remove(index);
                                          _verticalSpansCache.remove(index);
                                          updateState(() {
                                            selectedSpan = "${e["surah"]}:$i";
                                          });
                                          showAyahOptionsSheet(index, e["surah"], i);
                                        },
                                      text: quran.getVerse(e["surah"], i),
                                      style: TextStyle(
                                        color: darkWarmBrowns[getValue("quranPageolorsIndex")],
                                        fontSize: getValue("verseByVerseFontSize").toDouble(),
                                        fontFamily: getValue("selectedFontFamily"),
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
                                                : hasLocalBookmark(
                                                    e["surah"] as int,
                                                    i as int,
                                                  )
                                                    ? localBookmarkColor(e["surah"] as int, i)
                                                            ?.withOpacity(.19) ??
                                                        Colors.transparent
                                                    : Colors.transparent,
                                      ),
                                    ),
                                    TextSpan(
                                        text: " ${convertToArabicNumber((i).toString())} ",
                                        style: TextStyle(
                                            fontSize: 24.sp,
                                            color: isVerseStarred(e["surah"], i)
                                                ? Colors.amber
                                                : secondaryColors[getValue("quranPageolorsIndex")],
                                            fontFamily: "KFGQPC Uthmanic Script HAFS Regular")),
                                    if (hasLocalBookmark(
                                      e["surah"] as int,
                                      i,
                                    ))
                                      WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.bookmark,
                                            color: localBookmarkColor(
                                                  e["surah"] as int,
                                                  i,
                                                ) ??
                                                secondaryColors[getValue("quranPageolorsIndex")],
                                          )),
                                    WidgetSpan(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              toggleTafseer(e["surah"], i);
                                            },
                                            borderRadius: BorderRadius.circular(20.r),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w, vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color:
                                                    secondaryColors[getValue("quranPageolorsIndex")]
                                                        .withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(20.r),
                                                border: Border.all(
                                                  color: secondaryColors[
                                                          getValue("quranPageolorsIndex")]
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    expandedTafseerVerses
                                                            .contains("${e["surah"]}:$i")
                                                        ? Icons.keyboard_arrow_up_rounded
                                                        : Icons.keyboard_arrow_down_rounded,
                                                    size: 20.sp,
                                                    color: secondaryColors[
                                                        getValue("quranPageolorsIndex")],
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    expandedTafseerVerses
                                                            .contains("${e["surah"]}:$i")
                                                        ? "إخفاء التفسير"
                                                        : "إظهار التفسير",
                                                    style: TextStyle(
                                                      fontFamily: "cairo",
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: secondaryColors[
                                                          getValue("quranPageolorsIndex")],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (expandedTafseerVerses.contains("${e["surah"]}:$i"))
                                      WidgetSpan(
                                          child: SizedBox(
                                        width: double.infinity,
                                        child: Directionality(
                                          textDirection: translationDataList[getValue(
                                                          "indexOfTranslationInVerseByVerse")]
                                                      .typeInNativeLanguage ==
                                                  "العربية"
                                              ? m.TextDirection.rtl
                                              : m.TextDirection.ltr,
                                          child: get_translation_data
                                                  .getVerseTranslationForVerseByVerse(
                                                    dataOfCurrentTranslation,
                                                    e["surah"],
                                                    i,
                                                    translationDataList[getValue(
                                                        "indexOfTranslationInVerseByVerse")],
                                                  )
                                                  .contains(">")
                                              ? Html(
                                                  data: get_translation_data
                                                      .getVerseTranslationForVerseByVerse(
                                                    dataOfCurrentTranslation,
                                                    e["surah"],
                                                    i,
                                                    translationDataList[getValue(
                                                        "indexOfTranslationInVerseByVerse")],
                                                  ),
                                                  style: {
                                                    '*': Style(
                                                      fontFamily: 'cairo',
                                                      fontSize: FontSize(14.sp),
                                                      lineHeight: LineHeight(1.7.sp),
                                                    ),
                                                  },
                                                )
                                              : Text(
                                                  get_translation_data
                                                      .getVerseTranslationForVerseByVerse(
                                                    dataOfCurrentTranslation,
                                                    e["surah"],
                                                    i,
                                                    translationDataList[getValue(
                                                        "indexOfTranslationInVerseByVerse")],
                                                  ),
                                                  style: TextStyle(
                                                      color: darkWarmBrowns[
                                                          getValue("quranPageolorsIndex")],
                                                      fontFamily: translationDataList[getValue(
                                                                          "indexOfTranslationInVerseByVerse") ??
                                                                      0]
                                                                  .typeInNativeLanguage ==
                                                              "العربية"
                                                          ? "cairo"
                                                          : "roboto",
                                                      fontSize: 14.sp),
                                                ),
                                        ),
                                      )),
                                    WidgetSpan(
                                        child: Divider(
                                      height: 15.h,
                                      color: darkWarmBrowns[getValue("quranPageolorsIndex")]
                                          .withOpacity(.3),
                                    ))
                                  ],
                                ));
                              }
                              return spans;
                            }).toList(),
                          ),
                        )),
                  ),
                ),
                SizedBox(height: 6.h),
                MushafDivider(color: secondaryColors[getValue("quranPageolorsIndex")]),
                SizedBox(height: 6.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
