import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translationdata.dart';
import 'package:ayaat_quran_majeed/quran/presentation/widgets/bottom_sheets/translation_selection_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Settings bottom sheet for Quran page customization
/// Allows users to change themes, fonts, alignment, and translations
class SettingsBottomSheet {
  /// Show the settings modal bottom sheet
  ///
  /// [context] - Build context
  /// [onSettingsChanged] - Callback when settings are changed (triggers setState)
  static void show(
    BuildContext context, {
    required VoidCallback onSettingsChanged,
  }) {
    int tabIndex = 0;

    showMaterialModalBottomSheet(
      enableDrag: true,
      duration: const Duration(milliseconds: 600),
      backgroundColor: Colors.transparent,
      context: context,
      animationCurve: Curves.easeInOutQuart,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(.1),
      bounce: true,
      builder: (a) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStatee) {
          final isVerseByVerse = getValue("alignmentType") == "versebyverse";
          final bgColor = softOffWhites[getValue("quranPageolorsIndex")];
          final primaryColor = darkWarmBrowns[getValue("quranPageolorsIndex")];
          final secondaryColor = secondaryColors[getValue("quranPageolorsIndex")];

          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                SizedBox(height: 12.h),
                Container(
                  height: 5.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 16.h),

                // Settings Title
                Text(
                  "settings".tr(),
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),

                // Tab selector buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _buildTabButton(
                        isSelected: tabIndex == 0,
                        icon: Icons.color_lens_rounded,
                        label: "theme".tr(),
                        activeColor: secondaryColor,
                        onTap: () => setStatee(() => tabIndex = 0),
                      ),
                      _buildTabButton(
                        isSelected: tabIndex == 1,
                        icon: Icons.view_agenda_rounded,
                        label: "viewType".tr(),
                        activeColor: secondaryColor,
                        onTap: () => setStatee(() => tabIndex = 1),
                      ),
                      if (isVerseByVerse)
                        _buildTabButton(
                          isSelected: tabIndex == 2,
                          icon: Icons.translate_rounded,
                          label: "tafseer".tr(),
                          activeColor: secondaryColor,
                          onTap: () => setStatee(() => tabIndex = 2),
                        ),
                      if (isVerseByVerse)
                        _buildTabButton(
                          isSelected: tabIndex == 3,
                          icon: Icons.text_fields_rounded,
                          label: "fontSize".tr(),
                          activeColor: secondaryColor,
                          onTap: () => setStatee(() => tabIndex = 3),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),
                Divider(color: Colors.grey.withOpacity(0.2), height: 1),

                // Tab content
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: _buildTabContent(
                    tabIndex,
                    context,
                    setStatee,
                    onSettingsChanged,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build modern tab selection pill button
  static Widget _buildTabButton({
    required bool isSelected,
    required IconData icon,
    required String label,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? activeColor.withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey.shade600,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? activeColor : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build tab content based on selected tab
  static Widget _buildTabContent(
    int tabIndex,
    BuildContext context,
    StateSetter setStatee,
    VoidCallback onSettingsChanged,
  ) {
    switch (tabIndex) {
      case 0:
        return _buildThemeTab(context, setStatee, onSettingsChanged);
      case 1:
        return _buildAlignmentTab(context, setStatee, onSettingsChanged);
      case 2:
        return _buildTranslationTab(
          context,
          setStatee,
          onSettingsChanged,
        );
      case 3:
        return _buildFontTab(context, setStatee, onSettingsChanged);
      default:
        return const SizedBox();
    }
  }

  /// Theme selection tab
  static Widget _buildThemeTab(
    BuildContext context,
    StateSetter setStatee,
    VoidCallback onSettingsChanged,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.5,
      ),
      itemCount: softOffWhites.length,
      itemBuilder: (context, index) {
        final isSelected = getValue("quranPageolorsIndex") == index;
        return InkWell(
          onTap: () {
            updateValue("quranPageolorsIndex", index);
            setStatee(() {});
            onSettingsChanged();
          },
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: softOffWhites[index],
              border: Border.all(
                color: isSelected ? secondaryColors[index] : Colors.transparent,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: secondaryColors[index].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: darkWarmBrowns[index],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: secondaryColors[index],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        color: secondaryColors[index],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Font selection tab
  static Widget _buildFontTab(
    BuildContext context,
    StateSetter setStatee,
    VoidCallback onSettingsChanged,
  ) {
    final showFontSlider =
        getValue("alignmentType") == "versebyverse" || getValue("alignmentType") == "verticalview";

    return Column(
      children: [
        // Font size section
        if (showFontSlider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "fontSize".tr(),
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: darkWarmBrowns[getValue("quranPageolorsIndex")],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (getValue("alignmentType") == "versebyverse") {
                            updateValue("verseByVerseFontSize", 24.0);
                          } else if (getValue("alignmentType") == "verticalview") {
                            updateValue("verticalViewFontSize", 22.0);
                          } else {
                            updateValue("pageViewFontSize", 23.0);
                          }
                          setStatee(() {});
                          onSettingsChanged();
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color:
                                secondaryColors[getValue("quranPageolorsIndex")].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restore_rounded,
                                size: 16.sp,
                                color: secondaryColors[getValue("quranPageolorsIndex")],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "reset".tr(),
                                style: TextStyle(
                                  fontFamily: "cairo",
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColors[getValue("quranPageolorsIndex")],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildFontSizeControlButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          double current = _getCurrentFontSize();
                          if (current > 14.0) {
                            _updateFontSize(current - 1.0, setStatee, onSettingsChanged);
                          }
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: _getCurrentFontSize(),
                          min: 14.0,
                          max: 40.0,
                          divisions: 26,
                          label: _getCurrentFontSize().round().toString(),
                          activeColor: secondaryColors[getValue("quranPageolorsIndex")],
                          inactiveColor:
                              secondaryColors[getValue("quranPageolorsIndex")].withOpacity(0.2),
                          onChanged: (value) =>
                              _updateFontSize(value, setStatee, onSettingsChanged),
                        ),
                      ),
                      _buildFontSizeControlButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          double current = _getCurrentFontSize();
                          if (current < 40.0) {
                            _updateFontSize(current + 1.0, setStatee, onSettingsChanged);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        if (showFontSlider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Divider(color: Colors.grey.withOpacity(0.2)),
          ),

        // Font family selection
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: fontFamilies.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final fontFamily = fontFamilies[index];
              final isSelected = getValue("selectedFontFamily") == fontFamily;
              final activeColor = secondaryColors[getValue("quranPageolorsIndex")];

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: InkWell(
                  onTap: () {
                    updateValue("selectedFontFamily", fontFamily);
                    setStatee(() {});
                    onSettingsChanged();
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? activeColor.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected
                            ? activeColor.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  fontSize: 18.sp,
                                  color: darkWarmBrowns[getValue("quranPageolorsIndex")],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                fontFamily,
                                style: TextStyle(
                                  fontFamily: "cairo",
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static double _getCurrentFontSize() {
    if (getValue("alignmentType") == "versebyverse") {
      return getValue("verseByVerseFontSize").toDouble();
    } else if (getValue("alignmentType") == "verticalview") {
      return getValue("verticalViewFontSize").toDouble();
    } else {
      return getValue("pageViewFontSize").toDouble();
    }
  }

  static void _updateFontSize(double value, StateSetter setStatee, VoidCallback onSettingsChanged) {
    if (getValue("alignmentType") == "versebyverse") {
      updateValue("verseByVerseFontSize", value);
    } else if (getValue("alignmentType") == "verticalview") {
      updateValue("verticalViewFontSize", value);
    } else {
      updateValue("pageViewFontSize", value);
    }
    setStatee(() {});
    onSettingsChanged();
  }

  static Widget _buildFontSizeControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: secondaryColors[getValue("quranPageolorsIndex")].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: secondaryColors[getValue("quranPageolorsIndex")],
        ),
      ),
    );
  }

  /// Alignment/View type selection tab
  static Widget _buildAlignmentTab(
    BuildContext context,
    StateSetter setStatee,
    VoidCallback onSettingsChanged,
  ) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildAlignmentOption(
          title: "pageview".tr(),
          subtitle: "عرض صفحات المصحف التقليدية",
          value: "pageview",
          currentValue: getValue("alignmentType"),
          icon: Icons.menu_book_rounded,
          setStatee: setStatee,
          onSettingsChanged: onSettingsChanged,
        ),
        SizedBox(height: 12.h),
        _buildAlignmentOption(
          title: "verticalview".tr(),
          subtitle: "قراءة عمودية للآيات متتالية",
          value: "verticalview",
          currentValue: getValue("alignmentType"),
          icon: Icons.view_agenda_rounded,
          setStatee: setStatee,
          onSettingsChanged: onSettingsChanged,
        ),
        SizedBox(height: 12.h),
        _buildAlignmentOption(
          title: "versebyverse".tr(),
          subtitle: "قراءة مع الترجمة والتفسير",
          value: "versebyverse",
          currentValue: getValue("alignmentType"),
          icon: Icons.format_list_bulleted_rounded,
          setStatee: setStatee,
          onSettingsChanged: onSettingsChanged,
        ),
      ],
    );
  }

  /// Build single alignment option
  static Widget _buildAlignmentOption({
    required String title,
    required String subtitle,
    required String value,
    required String currentValue,
    required IconData icon,
    required StateSetter setStatee,
    required VoidCallback onSettingsChanged,
  }) {
    final isSelected = currentValue == value;
    final activeColor = secondaryColors[getValue("quranPageolorsIndex")];
    final primaryColor = darkWarmBrowns[getValue("quranPageolorsIndex")];

    return InkWell(
      onTap: () {
        updateValue("alignmentType", value);
        setStatee(() {});
        onSettingsChanged();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "cairo",
                      fontSize: 16.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? primaryColor : Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: "cairo",
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              )
            else
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTranslationTab(
    BuildContext context,
    StateSetter setStatee,
    VoidCallback onSettingsChanged,
  ) {
    final currentTranslation =
        translationDataList[getValue("indexOfTranslationInVerseByVerse") ?? 0];
    final activeColor = secondaryColors[getValue("quranPageolorsIndex")];
    final primaryColor = darkWarmBrowns[getValue("quranPageolorsIndex")];

    return Column(
      children: [
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "selectTranslation".tr(),
            style: TextStyle(
              fontFamily: "cairo",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: InkWell(
            onTap: () => TranslationSelectionSheet.show(
              context,
              onSettingsChanged: () {
                setStatee(() {});
                onSettingsChanged();
              },
            ),
            borderRadius: BorderRadius.circular(20.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: activeColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: activeColor,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTranslation.typeTextInRelatedLanguage,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontFamily: currentTranslation.typeInNativeLanguage == "العربية"
                                ? "cairo"
                                : "roboto",
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          currentTranslation.typeInNativeLanguage,
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.sp,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: 6.w),
              Text(
                "clickToChangeTranslation".tr(),
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // _showTranslationBottomSheet and _downloadTranslation are removed
  // in favor of TranslationSelectionSheet.show
}
