import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/localization_config.dart';
import 'package:ayaat_quran_majeed/core/routing/app_router.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/json_asset_service.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

/// Backward-compatible global getter referencing DI service locator.
AudioPlayer get audioPlayer => sl<AudioPlayer>();

/// Theme mode notifier persisted via Hive.
final ValueNotifier<bool> isDarkModeNotifier =
    ValueNotifier(getValue('darkMode') ?? false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ez.EasyLocalization.ensureInitialized();
  await initializeHive();
  await JsonAssetService.init();
  await initInjection();

  runApp(
    ez.EasyLocalization(
      supportedLocales: LocalizationConfig.supportedLocales,
      path: LocalizationConfig.translationsPath,
      fallbackLocale: LocalizationConfig.fallbackLocale,
      startLocale: LocalizationConfig.startLocale,
      saveLocale: false,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder: (context, child) => ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDark, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            title: 'القرآن الكريم',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
