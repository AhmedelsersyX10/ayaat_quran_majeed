import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _metadataService = QuranMetadataService();

class QuarterTab extends StatelessWidget {
  final dynamic quarterjsonData;
  final Function(int surah, int ayah) onNavigateToQuarter;

  const QuarterTab({
    Key? key,
    required this.quarterjsonData,
    required this.onNavigateToQuarter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 60,
      itemBuilder: (BuildContext context, int section) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuarterHeader(context, section),
            for (int itemIndex = 0; itemIndex < 4; itemIndex++)
              _buildQuarterListItem(context, section, itemIndex),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildQuarterListItem(BuildContext context, int section, int indexInHizb) {
    final quarterData = quarterjsonData[indexes[section][indexInHizb] - 1];
    final surah = quarterData["surah"];
    final ayah = quarterData["ayah"];

    return Card(
      color: Theme.of(context).cardTheme.color,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            _metadataService.getSurahNameArabic(surah),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Text(
            _metadataService.getVerse(surah, ayah),
            style: TextStyle(
              fontFamily: "AmiriQuran",
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          onTap: () => onNavigateToQuarter(surah, ayah),
          leading: _buildQuarterCircle(context, indexInHizb, section + 1),
        ),
      ),
    );
  }

  Widget _buildQuarterCircle(BuildContext context, int index, int hizbNumber) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFFF5E6D3).withOpacity(.1);
    final iconColor = isDark ? const Color(0xFFD2B48C) : const Color.fromARGB(228, 0, 0, 0);

    switch (index) {
      case 0:
        return Container(
          width: 33.sp,
          height: 33.sp,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
          child: Center(
            child: Text(hizbNumber.toString(), style: TextStyle(fontSize: 14.sp, color: iconColor)),
          ),
        );
      case 1:
        return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
          child: QuarterCircle(color: iconColor, size: 20.sp),
        );
      case 2:
        return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
          child: HalfCircle(color: iconColor, size: 20.sp),
        );
      case 3:
        return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
          child: ThreeQuartersCircle(color: iconColor, size: 20.sp),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildQuarterHeader(BuildContext context, int section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${"hizb".tr()} ${section + 1}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const Divider(endIndent: 370)
        ],
      ),
    );
  }
}
