import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Basmallah extends StatelessWidget {
  final int index;
  const Basmallah({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      child: Padding(
        padding: EdgeInsets.only(
            left: (screenSize.width * .2).w,
            right: (screenSize.width * .2).w,
            top: 8.h,
            bottom: 2.h),
        child: Image.asset(
          "assets/images/Basmala.png",
          color: darkWarmBrowns[index].withOpacity(.9),
          width: MediaQuery.of(context).size.width.w * .4,
        ),
      ),
    );
  }
}
