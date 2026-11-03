import 'dart:convert';
import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/initializeData.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _fontProgress = 0.0;
  bool _fontFailed = false;

  Future<void> _initFontsAndNavigate() async {
    if (mounted) {
      setState(() {
        _fontFailed = false;
        _fontProgress = 0.0;
      });
    }

    final sw = Stopwatch()..start();
    try {
      await QcfFontLoader.setupFontsAtStartup(
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _fontProgress = progress;
            });
          }
          debugPrint('[QcfFontLoader] ${(progress * 100).toStringAsFixed(1)}%');
        },
      );
      debugPrint('[QcfFontLoader] Fonts initialized in ${sw.elapsedMilliseconds} ms');
    } catch (e) {
      debugPrint('[QcfFontLoader] Font initialization error: $e');
      if (mounted) {
        setState(() {
          _fontFailed = true;
        });
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));

    // Load jsonData and quarterjsonData from assets so SurahListPage shows the same data
    try {
      final surahsString = await rootBundle.loadString('assets/json/surahs.json');
      final quartersString = await rootBundle.loadString('assets/json/quarters.json');
      json.decode(surahsString);
      json.decode(quartersString);
    } catch (e) {
      debugPrint('Error loading surah/quarter json from assets: $e');
    }

    if (mounted) {
      context.go(AppRoutes.reader);
    }
  }

  @override
  void initState() {
    super.initState();
    initHiveValues();
    _initFontsAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: softOffWhite,
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/ayaat.png",
                  height: 160,
                  width: 160,
                ),
                SizedBox(height: AppSpacing.xxl),
                if (_fontFailed) ...[
                  Text(
                    'فشل تحميل خطوط المصحف. يرجى التحقق من مساحة التخزين وإعادة المحاولة.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppButton.primary(
                    text: AppStrings.tr(AppStrings.retry),
                    onPressed: _initFontsAndNavigate,
                    width: 180,
                  ),
                ] else ...[
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _fontProgress > 0 ? _fontProgress : null,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
