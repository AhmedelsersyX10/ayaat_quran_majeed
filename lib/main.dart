
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/cubit/bloc/player_bar_bloc.dart';
import 'package:ayaat_quran_majeed/cubit/bloc/quran_reading_cubit.dart';
import 'package:ayaat_quran_majeed/cubit/player_bloc_bloc.dart';
import 'package:ayaat_quran_majeed/cubit/quran_page_player_bloc.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/bookmark_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/json_asset_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:ayaat_quran_majeed/core/splash/splash_screen.dart';
import 'package:just_audio/just_audio.dart';

// import 'package:alarm/alarm.dart';
final AudioPlayer audioPlayer = AudioPlayer();
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(getValue("darkMode") ?? false);

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ez.EasyLocalization.ensureInitialized();
  await initializeHive();
  await JsonAssetService.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<QuranReadingRepository>(
          create: (_) => const QuranReadingRepository(),
        ),
        RepositoryProvider<BookmarkRepository>(
          create: (_) => const BookmarkRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PlayerBlocBloc()),
          BlocProvider(create: (_) => QuranPagePlayerBloc()),
          BlocProvider(create: (_) => PlayerBarBloc()),
          BlocProvider(
            create: (context) => QuranReaderCubit(
              context.read<QuranReadingRepository>(),
            )..loadInitialPosition(),
          ),
          BlocProvider(
            create: (context) => BookmarkCubit(
              context.read<BookmarkRepository>(),
            )..loadBookmarks(),
          ),
        ],
        child: ez.EasyLocalization(
          supportedLocales: const [Locale('ar')],
          path: 'assets/translations', // <-- change the path of the translation files
          fallbackLocale: const Locale('ar'),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  setup() async {
    // await    setupServiceLocator();
  }
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // checkNotificationPermission();

    super.initState();
  }

  // BoxController boxController = BoxController();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //print(context.locale.toLanguageTag());
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder: (context, child) => ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDark, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'القرآن الكريم',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData(
              fontFamily: context.locale.languageCode == "ar" ? "cairo" : "roboto",
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
