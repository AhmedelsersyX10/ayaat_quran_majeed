import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';

class HeaderWidget extends StatelessWidget {
  final Map<String, dynamic> e;
  final dynamic jsonData;
  final int? indexOfTheme;

  const HeaderWidget({super.key, required this.e, required this.jsonData, this.indexOfTheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/images/888-02.png",
              width: MediaQuery.of(context).size.width.w,
              height: 80.h,
              color: indexOfTheme != null
                  ? indexOfTheme != 1 &&
                          indexOfTheme != 2 &&
                          indexOfTheme != 0 &&
                          indexOfTheme != 6 &&
                          indexOfTheme != 13 &&
                          indexOfTheme != 15
                      ? secondaryColors[indexOfTheme!]
                      : null
                  : getValue("quranPageolorsIndex") != 1 &&
                          getValue("quranPageolorsIndex") != 2 &&
                          getValue("quranPageolorsIndex") != 0 &&
                          getValue("quranPageolorsIndex") != 6 &&
                          getValue("quranPageolorsIndex") != 13 &&
                          getValue("quranPageolorsIndex") != 15
                      ? secondaryColors[getValue("quranPageolorsIndex")]
                      : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "اياتها\n${getVerseCount(e["surah"])}",
                  style: TextStyle(
                      // color: deepBurgundyRed,
                      color: indexOfTheme == null
                          ? darkWarmBrowns[getValue("quranPageolorsIndex")].withOpacity(.9)
                          : darkWarmBrowns[indexOfTheme!].withOpacity(.92),
                      fontSize: 6.sp,
                      fontFamily: "UthmanicHafs13"),
                ),
                Center(
                    child: RichText(
                  text: TextSpan(
                    text: "${e["surah"]}",
                    style: TextStyle(
                      fontFamily: "arsura",
                      fontSize: 28.sp,
                      color: indexOfTheme == null
                          ? darkWarmBrowns[getValue("quranPageolorsIndex")].withOpacity(.9)
                          : darkWarmBrowns[indexOfTheme!].withOpacity(.9),
                    ),
                  ),
                  textAlign: TextAlign.center,
                )),
                Text(
                  "ترتيبها\n${e["surah"]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      //color: deepBurgundyRed,//
                      color: indexOfTheme == null
                          ? darkWarmBrowns[getValue("quranPageolorsIndex")].withOpacity(.9)
                          : darkWarmBrowns[indexOfTheme!].withOpacity(.9),
                      fontSize: 6.sp,
                      fontFamily: "UthmanicHafs13"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
