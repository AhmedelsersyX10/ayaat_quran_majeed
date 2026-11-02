import 'dart:convert';
import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/initializeData.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  

  Future<void> _navigateToHome() async {
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
    if (mounted) {
      context.go(AppRoutes.reader);
    }
  }

  @override
  void initState() {
    super.initState();
    initHiveValues();
    _navigateToHome();
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
