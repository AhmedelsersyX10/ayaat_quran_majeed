// ignore_for_file: prefer_single_quotes, unused_field
import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/main.dart';
import 'package:ayaat_quran_majeed/quran/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/tabs/juz_tab.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/tabs/quarter_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ghaith/features/quran/presentation/cubit/quran_page_player_bloc.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;

class SurahListPage extends StatefulWidget {
  final dynamic jsonData;
  final dynamic quarterjsonData;

  const SurahListPage({Key? key, required this.jsonData, required this.quarterjsonData})
      : super(key: key);

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  // 🔹 [CAN_BE_EXTRACTED] يمكن نقل متغيرات الحالة لملف state/surah_list_state.dart
  bool isLoading = true;
  final TextEditingController textEditingController = TextEditingController();
  String searchQuery = "";
  dynamic filteredData;
  int _currentIndex = 0;
  final ItemScrollController _juzScrollController = ItemScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<int> pageNumbers = [];
  List<BookmarkModel> bookmarks = [];
  Set<String> starredVerses = {};
  int juzNumberLastRead = 0;
  bool _isSearchOpen = false;

  // 🔹 [CAN_BE_EXTRACTED] يمكن نقل الـ tabs لملف constants/app_constants.dart
  final List<Tab> tabs = <Tab>[
    Tab(text: 'surah'.tr()),
    Tab(text: 'juz'.tr()),
    Tab(text: 'quarter'.tr()),
  ];

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  // 🔹 [CAN_BE_EXTRACTED] يمكن نقل التهيئة لملف services/surah_list_initializer.dart
  void _initializeData() {
    getStarredVerse();
    addFilteredData();
    if (getValue("lastRead") != "non") {
      getJuzNumber();
    }
  }

  Future<void> getJuzNumber() async {
    if (getValue("lastRead") != "non") {
      juzNumberLastRead = quran.getJuzNumber(quran.getPageData(getValue("lastRead"))[0]["surah"],
          quran.getPageData(getValue("lastRead"))[0]["start"]);
      setState(() {});
    }
  }

  static dynamic _decodeJson(String jsonString) {
    return json.decode(jsonString);
  }

  Future<void> getStarredVerse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      final decodedData = await compute(_decodeJson, savedData);
      starredVerses = Set<String>.from(decodedData);
    }
    if (mounted) setState(() {});
  }

  Future<void> addFilteredData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        filteredData = widget.jsonData;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep local snapshot in sync with the global BookmarkCubit
    final bookmarkState = context.watch<BookmarkCubit>().state;
    bookmarks = bookmarkState.bookmarks;

    final theme = Theme.of(context);

    return DefaultTabController(
      length: tabs.length,
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            endDrawer: SafeArea(child: _buildBookmarksDrawer(context)),
            key: scaffoldKey,
            appBar: _buildAppBar(context),
            body: _buildTabBarView(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: _isSearchOpen ? _buildCloseSearchButton() : _buildBackButton(),
      actions: _isSearchOpen
          ? [_buildBookmarkButton(context)]
          : [_buildSearchAppBarButton(), _buildBookmarkButton(context)],
      bottom: _buildTabBar(),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30), // حجم الانحناء
        ),
      ),
      centerTitle: !_isSearchOpen,
      backgroundColor: theme.appBarTheme.backgroundColor,
      title: _isSearchOpen
          ? _buildAppBarSearchField()
          : Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                "alQuran".tr(),
                style: TextStyle(color: theme.appBarTheme.foregroundColor, fontSize: 20.sp),
              ),
            ),
    );
  }

  Widget _buildCloseSearchButton() {
    return IconButton(
      icon: Icon(Icons.close, size: 24.sp, color: Colors.white),
      onPressed: () => setState(() => _isSearchOpen = false),
    );
  }

  Widget _buildSearchAppBarButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
      child: IconButton(
        icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
        onPressed: () => setState(() => _isSearchOpen = true),
      ),
    );
  }

  Widget _buildAppBarSearchField() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Container(
        margin: EdgeInsets.only(top: 4.h, bottom: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TextField(
          textDirection: m.TextDirection.rtl,
          controller: textEditingController,
          onChanged: _onSearchTextChanged,
          style: _searchTextStyle().copyWith(color: Colors.white, fontSize: 16.sp),
          cursorColor: Colors.white,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'searchQuran'.tr(),
            hintStyle: TextStyle(color: Colors.white70, fontSize: 14.sp),
            suffixIcon: _buildSearchSuffixIcon(iconColor: Colors.white70),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 0, top: 8.h),
      child: Builder(builder: (context) {
        return IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: const Icon(Iconsax.bookmark, color: softOffWhite),
        );
      }),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TabBar(
          indicatorPadding: EdgeInsets.symmetric(horizontal: 35.w),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorWeight: 4,
          tabs: tabs,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 1) getJuzNumber();
          },
        ),
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      children: [
        _buildSurahTab(context),
        JuzTab(
          scrollController: _juzScrollController,
          juzNumberLastRead: juzNumberLastRead,
          onNavigateToJuz: (juzNumber, firstSurah, firstVerse) {
            Navigator.pop(context, {
              'pageNumber': quran.getPageNumber(firstSurah, firstVerse),
              'surah': firstSurah,
              'ayah': firstVerse,
            });
          },
        ),
        QuarterTab(
          quarterjsonData: widget.quarterjsonData,
          onNavigateToQuarter: (surah, ayah) {
            Navigator.pop(context, {
              'pageNumber': quran.getPageNumber(surah, ayah),
              'surah': surah,
              'ayah': ayah,
            });
          },
        ),
      ],
    );
  }

  Widget _buildSurahTab(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // if (getValue("lastRead") != "non") _buildLastReadSection(),
            _buildSurahList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuffixIcon({Color? iconColor}) {
    final color = iconColor ?? _getSearchIconColor();
    return GestureDetector(
      onTap: () {
        if (searchQuery.isNotEmpty) {
          _clearSearch();
        } else {
          setState(() => _isSearchOpen = false);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: searchQuery.isNotEmpty
            ? Icon(Icons.close, color: color)
            : Icon(Icons.search, color: color),
      ),
    );
  }

  Color _getSearchIconColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : const Color.fromARGB(73, 0, 0, 0);
  }

  TextStyle _searchTextStyle() {
    return TextStyle(
      fontFamily: "aldahabi",
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  // TextStyle _searchHintStyle() {
  //   return TextStyle(
  //     fontFamily: "aldahabi",
  //     color: isDarkModeNotifier.value ? Colors.white70 : const Color.fromARGB(73, 0, 0, 0),
  //   );
  // }

  void _onSearchTextChanged(String value) {
    setState(() => searchQuery = value);

    if (value.isEmpty) {
      filteredData = widget.jsonData;
      pageNumbers.clear();
      return;
    }

    pageNumbers.clear();
    _handlePageNumberSearch(value);

    setState(() {
      filteredData = widget.jsonData.where((sura) {
        final suraName = sura['englishName'].toLowerCase();
        final suraNameArabic = quran.getSurahNameArabic(sura["number"]);

        return suraName.contains(searchQuery.toLowerCase()) ||
            suraNameArabic.contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _handlePageNumberSearch(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      pageNumbers.add(parsed);
    }
  }

  void _clearSearch() {
    if (searchQuery.isNotEmpty) {
      filteredData = widget.jsonData;
      textEditingController.clear();
      pageNumbers.clear();
      setState(() => searchQuery = "");
    }
  }

  Widget _buildSurahList() {
    return Expanded(
      child: isLoading
          ? _buildShimmerLoading()
          : ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                if (pageNumbers.isNotEmpty) _buildPageNumbersList(),
                _buildSurahsListView(),
              ],
            ),
    );
  }

  Widget _buildPageNumbersList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("page".tr()),
        ),
        ListView.separated(
          reverse: true,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w),
            child: Divider(color: Colors.grey.withOpacity(.5)),
          ),
          itemCount: pageNumbers.length,
          itemBuilder: (ctx, index) => _buildPageNumberItem(pageNumbers[index]),
        ),
      ],
    );
  }

  Widget _buildPageNumberItem(int pageNumber) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.pop(context, pageNumber),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pageNumber.toString()),
                Text(quran.getSurahName(quran.getPageData(pageNumber)[0]["surah"])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
        child: Divider(color: Colors.grey.withOpacity(.5)),
      ),
      itemCount: filteredData.length,
      itemBuilder: (context, index) => _buildSurahListItem(index),
    );
  }

  // 🔹 [CAN_BE_EXTRACTED] يمكن نقل بناء عنصر السورة لملف ui/components/surah_list_item.dart
  Widget _buildSurahListItem(int index) {
    final suraData = filteredData[index];
    final suraNumberInQuran = suraData["number"];
    final surahBookmarks = bookmarks.where((b) => b.suraNumber == suraNumberInQuran).toList();
    final BookmarkModel? firstBookmark = surahBookmarks.isNotEmpty ? surahBookmarks.first : null;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: _buildSurahNumberCircle(suraNumberInQuran),
        title: _buildSurahTitle(suraData, firstBookmark),
        subtitle: _buildSurahSubtitle(suraData),
        // trailing: _buildSurahTrailing(suraNumber),
        onTap: () => _navigateToSurah(suraNumberInQuran),
      ),
    );
  }

  Widget _buildSurahNumberCircle(int suraNumber) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/sura_frame.png"),
        ),
      ),
      child: Center(
        child: Text(
          suraNumber.toString(),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12.sp),
        ),
      ),
    );
  }

  Widget _buildSurahTitle(Map<String, dynamic> suraData, BookmarkModel? bookmark) {
    return SizedBox(
      width: 90.w,
      child: Row(
        children: [
          Text(
            "سورة ${suraData["name"]}",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: "arsura",
            ),
          ),
          if (bookmark != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: _buildBookmarkIcon(bookmark),
            ),
        ],
      ),
    );
  }

  Widget _buildBookmarkIcon(BookmarkModel bookmark) {
    Color color;
    try {
      color = Color(int.parse("0x${bookmark.color}"));
    } catch (_) {
      color = colorsOfBookmarks2.first;
    }

    return Icon(
      Icons.bookmark,
      size: 16.sp,
      color: color.withOpacity(.7),
    );
  }

  Widget _buildSurahSubtitle(Map<String, dynamic> suraData) {
    final ayahCount = quran.getVerseCount(suraData["number"]);
    return Text(
      "${suraData["englishName"]} ($ayahCount)",
      style: TextStyle(fontFamily: "uthmanic", fontSize: 14.sp, color: Colors.grey.withOpacity(.8)),
    );
  }

  // Widget _buildSurahTrailing(int suraNumber) {
  //   return RichText(
  //     text: TextSpan(
  //       text: "$suraNumber",
  //       style: TextStyle(
  //         color: getValue("darkMode") ? Colors.white70 : Colors.black,
  //         fontSize: 28.sp,
  //         fontFamily: "arsura",
  //       ),
  //     ),
  //   );
  // }

  void _navigateToSurah(int suraNumber) async {
    Navigator.pop(context, quran.getPageNumber(suraNumber, 1));
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (builder) => BlocProvider(
    //       create: (context) => QuranPagePlayerBloc(),
    //       child: QuranDetailsPage(
    //         shouldHighlightSura: true,
    //         shouldHighlightText: false,
    //         highlightVerse: "",
    //         jsonData: widget.jsonData,
    //         quarterJsonData: widget.quarterjsonData,
    //         pageNumber: quran.getPageNumber(suraNumber, 1),
    //       ),
    //     ),
    //   ),
    // );
  }

  // 🔹 [CAN_BE_EXTRACTED] يمكن نقل درج الإشارات المرجعية لملف ui/drawers/bookmarks_drawer.dart
  Widget _buildBookmarksDrawer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * .7,
      color: isDarkModeNotifier.value ? darkSlateGray : paperBeige,
      child: ListView(
        shrinkWrap: true,
        children: [
          _buildBookmarksList(),
          // _buildStarredVersesHeader(),
          // _buildStarredVersesList(),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    if (bookmarks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 40.sp,
              color: isDarkModeNotifier.value
                  ? Colors.white.withOpacity(.6)
                  : darkWarmBrowns[0].withOpacity(.6),
            ),
            SizedBox(height: 12.h),
            Text(
              "noBookmarksYet".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "cairo",
                fontSize: 15.sp,
                color: isDarkModeNotifier.value ? Colors.white.withOpacity(.85) : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookmarks.length,
      itemBuilder: (c, i) => _buildBookmarkItem(bookmarks[i]),
    );
  }

  Widget _buildBookmarkItem(BookmarkModel bookmark) {
    final suraNumber = bookmark.suraNumber;
    final verseNumber = bookmark.verseNumber;
    Color bookmarkColor;
    try {
      bookmarkColor = Color(int.parse("0x${bookmark.color}"));
    } catch (_) {
      bookmarkColor = colorsOfBookmarks2.first;
    }

    return Material(
      borderRadius: BorderRadius.circular(18),
      color: darkWarmBrowns[0].withOpacity(.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _navigateToBookmark(suraNumber, verseNumber),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              _buildBookmarkHeader(bookmark, bookmarkColor),
              const Divider(),
              _buildBookmarkVerse(suraNumber, verseNumber),
              const Divider(),
              _buildBookmarkInfo(suraNumber, verseNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkHeader(dynamic bookmark, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bookmark, color: color),
        SizedBox(width: 20.w),
        Text(
          bookmark.name,
          style: TextStyle(
            fontFamily: "cairo",
            fontSize: 14.sp,
            color: getValue("darkMode") ? Colors.white.withOpacity(.87) : darkWarmBrowns[0],
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkVerse(int suraNumber, int verseNumber) {
    return SizedBox(
      child: Text(
        quran.getVerse(suraNumber, verseNumber),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: fontFamilies[0],
          fontSize: 18.sp,
          color: isDarkModeNotifier.value ? Colors.white.withOpacity(.87) : darkWarmBrowns[0],
        ),
      ),
    );
  }

  Widget _buildBookmarkInfo(int suraNumber, int verseNumber) {
    return Column(
      children: [
        Text(
          context.locale.languageCode == "ar"
              ? quran.getSurahNameArabic(suraNumber)
              : quran.getSurahNameEnglish(suraNumber),
          style: TextStyle(
            color: isDarkModeNotifier.value ? Colors.white.withOpacity(.87) : Colors.black87,
          ),
        ),
        Text(
          convertToArabicNumber(verseNumber.toString()),
          style: TextStyle(
            fontSize: 24.sp,
            color: isDarkModeNotifier.value ? Colors.white.withOpacity(.87) : Colors.black87,
            fontFamily: "KFGQPC Uthmanic Script HAFS Regular",
          ),
        ),
      ],
    );
  }

  void _navigateToBookmark(int suraNumber, int verseNumber) async {
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context); // Close drawer
    }
    Navigator.pop(context, quran.getPageNumber(suraNumber, verseNumber));
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (builder) => QuranDetailsPage(
    //       shouldHighlightSura: false,
    //       pageNumber: quran.getPageNumber(suraNumber, verseNumber),
    //       jsonData: widget.jsonData,
    //       shouldHighlightText: true,
    //       highlightVerse: quran.getVerse(suraNumber, verseNumber),
    //       quarterJsonData: widget.quarterjsonData,
    //     ),
    //   ),
    // );
  }

  // Widget _buildStarredVersesHeader() {
  //   return Column(
  //     children: [
  //       Center(
  //         child: Padding(
  //           padding: EdgeInsets.only(top: 8.0.h),
  //           child: Text(
  //             "starredverses".tr(),
  //             style: TextStyle(
  //               color: isDarkModeNotifier.value ? Colors.white.withOpacity(.87) : Colors.black,
  //               fontSize: 18.sp,
  //             ),
  //           ),
  //         ),
  //       ),
  //       Center(child: Icon(Icons.keyboard_arrow_down, size: 18.sp)),
  //     ],
  //   );
  // }

  // Widget _buildStarredVersesList() {
  //   return ListView(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     children: starredVerses.map((e) => _buildStarredVerseItem(e)).toList(),
  //   );
  // }

  // Widget _buildStarredVerseItem(String verseKey) {
  //   final parts = verseKey.split("-");
  //   final suraNumber = int.parse(parts[0]);
  //   final verseNumber = int.parse(parts[1]);

  //   return Container(
  //     color: darkWarmBrowns[0].withOpacity(.05),
  //     onTap: () => _navigateToStarredVerse(suraNumber, verseNumber),
  //     child: Column(
  //       children: [
  //         _buildStarredVerseText(suraNumber, verseNumber),
  //         _buildStarredVerseInfo(suraNumber, verseNumber),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStarredVerseText(int suraNumber, int verseNumber) {
  //   return Text(
  //     quran.getVerse(suraNumber, verseNumber),
  //     textAlign: TextAlign.center,
  //     style: TextStyle(
  //       fontFamily: fontFamilies[0],
  //       fontSize: 18.sp,
  //       color: isDarkModeNotifier.value ? Colors.white.withOpacity(.87) : darkWarmBrowns[0],
  //     ),
  //   );
  // }

  // Widget _buildStarredVerseInfo(int suraNumber, int verseNumber) {
  //   return Column(
  //     children: [
  //       Text(
  //         context.locale.languageCode == "ar"
  //             ? quran.getSurahNameArabic(suraNumber)
  //             : quran.getSurahNameEnglish(suraNumber),
  //         textAlign: TextAlign.center,
  //       ),
  //       Text(
  //         convertToArabicNumber(verseNumber.toString()),
  //         style: TextStyle(
  //           fontSize: 24.sp,
  //           color: isDarkModeNotifier.value ? Colors.white.withOpacity(.87) : Colors.black87,
  //           fontFamily: "KFGQPC Uthmanic Script HAFS Regular",
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // void _navigateToStarredVerse(int suraNumber, int verseNumber) async {
  //   Navigator.pop(context, quran.getPageNumber(suraNumber, verseNumber));
  //   // await Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (builder) => QuranDetailsPage(
  //   //       shouldHighlightSura: false,
  //   //       pageNumber: quran.getPageNumber(suraNumber, verseNumber),
  //   //       jsonData: widget.jsonData,
  //   //       shouldHighlightText: true,
  //   //       highlightVerse: quran.getVerse(suraNumber, verseNumber),
  //   //       quarterJsonData: widget.quarterjsonData,
  //   //     ),
  //   //   ),
  //   // );
  // }

  // 🔹 [CAN_BE_EXTRACTED] يمكن نقل تأثير التحميل لملف ui/components/shimmer_loading.dart
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(.5),
          highlightColor: isDarkModeNotifier.value ? deepNavyBlack : paperBeige,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
            child: ListTile(
              leading: Container(width: 45, height: 45, color: softOffWhite),
              title: Container(height: 15, color: softOffWhite),
              subtitle: Container(height: 12, color: softOffWhite),
            ),
          ),
        );
      },
    );
  }
}
