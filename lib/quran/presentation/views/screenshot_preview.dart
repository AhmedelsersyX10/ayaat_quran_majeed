import 'dart:io';
import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/main.dart' show isDarkModeNotifier;
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translationdata.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/save_image.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/share_image.dart' show shareImage;
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/bismallah.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/header_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart';
import 'package:quran/quran.dart' as get_translation_data;
import 'package:screenshot/screenshot.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart' as m;

class ScreenShotPreviewPage extends StatefulWidget {
  final int index;
  final int surahNumber;
  final dynamic jsonData;
  final int firstVerse;
  final int lastVerse;

  const ScreenShotPreviewPage({
    super.key,
    required this.index,
    required this.surahNumber,
    required this.jsonData,
    required this.firstVerse,
    required this.lastVerse,
  });

  @override
  State<ScreenShotPreviewPage> createState() => _ScreenShotPreviewPageState();
}

class _ScreenShotPreviewPageState extends State<ScreenShotPreviewPage>
    with SingleTickerProviderStateMixin {
  TextAlign _alignment = TextAlign.center;
  Directory? _appDir;
  int _indexOfTheme = getValue("quranPageolorsIndex");
  double _textSize = 22.0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final ScreenshotController _screenshotController = ScreenshotController();
  Color get _accentColor => darkWarmBrowns[_indexOfTheme];

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _initialize();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    _appDir = await getTemporaryDirectory();
    await _getTranslationData();
    if (mounted) {
      setState(() {});
      _fadeController.forward();
    }
  }

  Future<void> _getTranslationData() async {
    if (getValue("addTafseerValue") > 1) {
      File file = File(
        "${_appDir!.path}/${translationDataList[getValue("addTafseerValue")].typeText}.json",
      );
      await file.readAsString();
    }
  }

  // ─── Builders: Verse / Tafseer spans ─────────────────────────────────────────

  List<InlineSpan> _buildVerseSpans(int surahNumber, int firstVerseNumber, int lastVerseNumber) {
    List<InlineSpan> verseSpans = [];

    for (int verseNumber = firstVerseNumber; verseNumber <= lastVerseNumber; verseNumber++) {
      String verseText = getVerse(surahNumber, verseNumber);

      verseSpans.addAll([
        TextSpan(
          text: "$verseText ",
          style: _getVerseTextStyle(),
        ),
        TextSpan(
          locale: const Locale("ar"),
          text: " ${convertToArabicNumber(verseNumber.toString())} ",
          style: _getVerseNumberStyle(),
        ),
      ]);
    }

    return verseSpans;
  }

  TextStyle _getVerseTextStyle() {
    return TextStyle(
      color: darkWarmBrowns[_indexOfTheme],
      fontSize: _textSize.sp,
      wordSpacing: 0,
      height: 2,
      fontFamily: getValue("selectedFontFamily"),
    );
  }

  TextStyle _getVerseNumberStyle() {
    return TextStyle(
      color: secondaryColors[_indexOfTheme],
      fontSize: _textSize.sp,
      fontFamily: "KFGQPC Uthmanic Script HAFS Regular",
    );
  }

  Future<List<InlineSpan>> _buildTafseerSpans(
      int surahNumber, int firstVerse, int lastVerse, dynamic translatee) async {
    final List<InlineSpan> spans = [
      TextSpan(
        // text: "${translatee.typeTextInRelatedLanguage}:\n",
        style: _tafseerHeaderStyle,
      ),
    ];
    for (int v = firstVerse; v <= lastVerse; v++) {
      String text = get_translation_data.getVerseTranslation(surahNumber, v, translatee);
      text = text.replaceAll("<p>", "\n").replaceAll("</p>", "");
      spans.add(TextSpan(
        text: "$text (${convertToArabicNumber(v.toString())}) ",
        style: _tafseerTextStyle,
      ));
    }
    return spans;
  }

  // ─── Text styles (computed from current state) ────────────────────────────────

  TextStyle get _verseTextStyle => TextStyle(
        color: darkWarmBrowns[_indexOfTheme],
        fontSize: _textSize.sp,
        height: 2.2,
        wordSpacing: 0,
        fontFamily: getValue("selectedFontFamily"),
      );

  TextStyle get _tafseerHeaderStyle => TextStyle(
        color: darkWarmBrowns[_indexOfTheme],
        fontSize: ((_textSize + 6.5) / 2).sp,
        fontWeight: FontWeight.w700,
        fontFamily: "cairo",
      );

  TextStyle get _tafseerTextStyle => TextStyle(
        color: darkWarmBrowns[_indexOfTheme].withOpacity(0.85),
        fontSize: ((_textSize + 6) / 2).sp,
        height: 1.8,
        fontFamily: "cairo",
      );

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _updateSetting(String key, bool? value) {
    updateValue(key, value);
    setState(() {});
  }

  bool _shouldShowBasmallah() => widget.firstVerse == 1 && widget.index != 1 && widget.index != 187;

  m.TextDirection _tafseerTextDirection() =>
      translationDataList[getValue("addTafseerValue")].typeInNativeLanguage == "العربية"
          ? m.TextDirection.rtl
          : m.TextDirection.ltr;

  // ─── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _shareScreenshot() async {
    final img = await _screenshotController.capture();
    if (img != null) shareImage(img);
  }

  Future<void> _saveScreenshot() async {
    final img = await _screenshotController.capture();
    if (img != null) await saveImageToGallery(img);
  }

  // ─── Root build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkModeNotifier.value;

    return Scaffold(
      backgroundColor: isDark ? darkSlateGray : const Color(0xFFF5F0EA),
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 12.h),
                children: [
                  _buildThemeSelector(),
                  _buildSettingsChips(),
                  _buildAlignAndSizeBar(isDark),
                  SizedBox(height: 16.h),
                  _buildPreviewSectionLabel(isDark),
                  _buildScreenshotPreview(),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(bool isDark) => AppBar(
        backgroundColor: isDark ? deepNavyBlack : wineRed,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "preview".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );

  // ─── Theme Selector ───────────────────────────────────────────────────────────

  Widget _buildThemeSelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "السمة اللونية",
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[500],
              fontFamily: "cairo",
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 38.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: darkWarmBrowns.length,
              itemBuilder: (_, i) => _buildThemeChip(i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(int index) {
    final isSelected = _indexOfTheme == index;
    return GestureDetector(
      onTap: () => setState(() => _indexOfTheme = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(right: 8.w),
        width: 44.w,
        height: 34.h,
        decoration: BoxDecoration(
          color: softOffWhites[index],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? darkWarmBrowns[index] : Colors.grey.withOpacity(0.25),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: darkWarmBrowns[index].withOpacity(0.3), blurRadius: 6)]
              : [],
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: darkWarmBrowns[index],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Settings Chips ───────────────────────────────────────────────────────────

  Widget _buildSettingsChips() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          _buildToggleChip(
            label: 'showsuraheader'.tr(),
            value: getValue("showSuraHeader"),
            onToggle: (v) => _updateSetting("showSuraHeader", v),
          ),
          _buildToggleChip(
            label: 'showbottombar'.tr(),
            value: getValue("showBottomBar"),
            onToggle: (v) => _updateSetting("showBottomBar", v),
          ),
          _buildToggleChip(
            label: 'addtafseer'.tr(),
            value: getValue("addTafseer"),
            onToggle: (v) => _updateSetting("addTafseer", v),
          ),
          _buildToggleChip(
            label: 'addAppSlogan'.tr(),
            value: getValue("addAppSlogan"),
            onToggle: (v) => _updateSetting("addAppSlogan", v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool value,
    required void Function(bool) onToggle,
  }) {
    final accentColor = darkWarmBrowns[_indexOfTheme];
    return GestureDetector(
      onTap: () => onToggle(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: value ? accentColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? accentColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                value ? Icons.check_rounded : Icons.add_rounded,
                key: ValueKey(value),
                color: value ? Colors.white : Colors.grey[600],
                size: 14.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: value ? Colors.white : Colors.grey[700],
                fontSize: 12.sp,
                fontFamily: "cairo",
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Alignment + Size Row ─────────────────────────────────────────────────────

  Widget _buildAlignAndSizeBar(bool isDark) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          _buildAlignmentToggle(),
          SizedBox(width: 16.w),
          Expanded(child: _buildSizeSlider(isDark)),
        ],
      ),
    );
  }

  Widget _buildAlignmentToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _alignBtn(TextAlign.right, Icons.format_align_right_rounded),
          _alignBtn(TextAlign.center, Icons.format_align_center_rounded),
          _alignBtn(TextAlign.justify, Icons.format_align_justify_rounded),
        ],
      ),
    );
  }

  Widget _alignBtn(TextAlign align, IconData icon) {
    final isActive = _alignment == align;
    return GestureDetector(
      onTap: () => setState(() => _alignment = align),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isActive ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: isActive ? darkWarmBrowns[_indexOfTheme] : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildSizeSlider(bool isDark) {
    return Row(
      children: [
        Text("A", style: TextStyle(fontSize: 11.sp, color: Colors.grey[400])),
        SizedBox(width: 6.w),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: darkWarmBrowns[_indexOfTheme],
              inactiveTrackColor: Colors.grey[200],
              thumbColor: darkWarmBrowns[_indexOfTheme],
              overlayColor: darkWarmBrowns[_indexOfTheme].withOpacity(0.1),
            ),
            child: Slider(
              value: _textSize,
              min: 15.0,
              max: 45.0,
              divisions: 30,
              onChanged: (v) => setState(() => _textSize = v),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Text("A", style: TextStyle(fontSize: 15.sp, color: Colors.grey[400])),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: darkWarmBrowns[_indexOfTheme].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _textSize.round().toString(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: darkWarmBrowns[_indexOfTheme],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section label ────────────────────────────────────────────────────────────

  Widget _buildPreviewSectionLabel(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14.h,
            decoration: BoxDecoration(
              color: darkWarmBrowns[_indexOfTheme],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            "المعاينة",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontFamily: "cairo",
            ),
          ),
        ],
      ),
    );
  }

  // ─── Screenshot Preview Card ─────────────────────────────────────────────────

  Widget _buildScreenshotPreview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: darkWarmBrowns[_indexOfTheme].withOpacity(0.18),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Screenshot(
            controller: _screenshotController,
            child: Container(
              color: softOffWhites[_indexOfTheme],
              child: Container(
                decoration: BoxDecoration(
                  color: softOffWhites[_indexOfTheme],
                  image: const DecorationImage(
                    image: AssetImage("assets/images/mosquepnggold.png"),
                    opacity: .07,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: Image.asset(
                          "assets/images/try6.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        if (getValue("showSuraHeader") == true) _buildSuraHeader(),
                        SizedBox(height: widget.firstVerse == 1 ? 0.h : 0.h),
                        if (_shouldShowBasmallah()) Basmallah(index: _indexOfTheme),
                        _buildVersesText(),
                        if (getValue("addTafseer") == true) _buildTafseerSection(),
                        if (getValue("addAppSlogan") == true) _buildAppSlogan(),
                        SizedBox(height: 16.h),
                        if (getValue("showBottomBar") == true) _buildBottomStrip(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuraHeader() => HeaderWidget(
        e: {"surah": widget.surahNumber},
        jsonData: widget.jsonData,
        indexOfTheme: _indexOfTheme,
      );

  Widget _buildVersesText() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SizedBox(
          width: double.infinity,
          child: RichText(
            textAlign: _alignment,
            locale: const Locale("ar"),
            textDirection: m.TextDirection.rtl,
            text: TextSpan(
              text: '',
              style: _verseTextStyle,
              children: _buildVerseSpans(widget.surahNumber, widget.firstVerse, widget.lastVerse),
            ),
          ),
        ),
      );

  Widget _buildTafseerSection() {
    return _buildSection(
      title: "التفسير الميسر",
      icon: Icons.book,
      child: FutureBuilder<List<InlineSpan>>(
        future: _buildTafseerSpans(
          widget.surahNumber,
          widget.firstVerse,
          widget.lastVerse,
          translationDataList[getValue("addTafseerValue")],
        ),
        builder: (ctx, snap) => RichText(
          textDirection: _tafseerTextDirection(),
          textAlign: m.TextAlign.center,
          text: TextSpan(children: snap.data ?? []),
        ),
      ),
    );
  }
  // Widget _buildTafseerSection() => Column(
  //       children: [
  //         Divider(height: 1, color: darkWarmBrowns[_indexOfTheme].withOpacity(0.15)),
  //         FutureBuilder<List<InlineSpan>>(
  //           future: _buildTafseerSpans(
  //             widget.surahNumber,
  //             widget.firstVerse,
  //             widget.lastVerse,
  //             translationDataList[getValue("addTafseerValue")],
  //           ),
  //           builder: (ctx, snap) => Padding(
  //             padding: EdgeInsets.all(8.w),
  //             child: RichText(
  //               textDirection: _tafseerTextDirection(),
  //               textAlign: m.TextAlign.center,
  //               text: TextSpan(children: snap.data ?? []),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    bool isRTL = true,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 24.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── عنوان القسم ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Directionality(
              textDirection: isRTL ? m.TextDirection.rtl : m.TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: _accentColor, size: 13.sp),
                  SizedBox(width: 5.w),
                  Text(
                    title,
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: "cairo",
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── محتوى القسم ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSlogan() => Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: const AssetImage("assets/images/ghaith.png"), height: 22.h),
            SizedBox(width: 6.w),
            Text(
              "تطبيق غيث المسلم",
              style: TextStyle(
                fontSize: 10.sp,
                color: darkWarmBrowns[_indexOfTheme].withOpacity(0.7),
                fontFamily: "cairo",
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomStrip() => Container(
        color: secondaryColors[_indexOfTheme],
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "[${widget.firstVerse} - ${widget.lastVerse}]",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: softOffWhites[_indexOfTheme],
              ),
            ),
            Text(
              widget.jsonData[widget.surahNumber - 1]["name"],
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamilies[0],
                color: softOffWhites[_indexOfTheme],
              ),
            ),
          ],
        ),
      );

  // ─── Bottom Action Bar ────────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? deepNavyBlack : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12.h,
        top: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: "shareexternal".tr(),
              icon: Icons.share_rounded,
              onTap: _shareScreenshot,
              outlined: true,
              color: darkWarmBrowns[_indexOfTheme],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _ActionButton(
              label: "savetogallery".tr(),
              icon: Icons.download_rounded,
              onTap: _saveScreenshot,
              outlined: false,
              color: isDarkModeNotifier.value ? darkWarmBrowns[_indexOfTheme] : wineRed,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Advanced Settings Sheet ──────────────────────────────────────────────────
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.outlined,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: outlined ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: outlined ? color : Colors.white, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: context.locale.languageCode == "ar" ? 12.sp : 13.sp,
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : Colors.white,
                  fontFamily: "cairo",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
