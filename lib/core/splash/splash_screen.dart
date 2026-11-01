import 'dart:convert';
import 'package:ayaat_quran_majeed/quran/presentation/views/quran_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/initializeData.dart';
import 'package:flutter/services.dart' show rootBundle;


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  

  navigateToHome(context) async {
    await Future.delayed(const Duration(seconds: 1));
    // Load jsonData and quarterjsonData from assets so SurahListPage shows the same data
    var jsonData = [];
    var quarterjsonData = [];
    try {
      final surahsString = await rootBundle.loadString('assets/json/surahs.json');
      final quartersString = await rootBundle.loadString('assets/json/quarters.json');
      jsonData = json.decode(surahsString);
      quarterjsonData = json.decode(quartersString);
    } catch (e) {
      // If loading fails, keep empty lists and print error — SurahListPage already handles empty data.
      print('Error loading surah/quarter json from assets: $e');
    }
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (builder) => const QuranReadingPage(),
        ),
        (route) => false);
  }



  @override
  void initState() {
    super.initState();
    initHiveValues();
    navigateToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: softOffWhite,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/ayaat.png",
                    height: 160,
                    width: 160,
                  ),
                 
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
