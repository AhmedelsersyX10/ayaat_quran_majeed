import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/routing/app_shell.dart';
import 'package:ayaat_quran_majeed/core/splash/splash_screen.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/views/reciter_surahs_page.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/views/bookmarks_tab_view.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/views/surahs_tab_view.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/views/khatma_all_wirds_page.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/views/khatma_tab_view.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/views/notes_tab_view.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/views/search_page.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_cubit.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/views/starred_tab_view.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_page_player_bloc.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_reading_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/views/quran_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Central declarative routing configuration using GoRouter.
abstract class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

  // Branch navigator keys for the 5 tabs in the AppShell
  static final GlobalKey<NavigatorState> surahsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'surahsNav');
  static final GlobalKey<NavigatorState> khatmaNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'khatmaNav');
  static final GlobalKey<NavigatorState> bookmarksNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'bookmarksNav');
  static final GlobalKey<NavigatorState> starredNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'starredNav');
  static final GlobalKey<NavigatorState> notesNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'notesNav');

  /// Creates a configured GoRouter instance.
  /// Allows injecting a custom [initialLocation] for testing or deep linking.
  static GoRouter createRouter({String initialLocation = AppRoutes.splash}) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.reader,
          name: AppRoutes.readerName,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final pageParam = state.uri.queryParameters['page'];
            final pageNumber = int.tryParse(pageParam ?? '');
            final surahParam = state.uri.queryParameters['surah'];
            final surahNumber = int.tryParse(surahParam ?? '');
            final ayahParam = state.uri.queryParameters['ayah'];
            final ayahNumber = int.tryParse(ayahParam ?? '');

            return MultiBlocProvider(
              providers: [
                BlocProvider<AudioPlaybackCubit>.value(
                  value: sl<AudioPlaybackCubit>(),
                ),
                BlocProvider<ReciterSelectionCubit>(
                  create: (_) => sl<ReciterSelectionCubit>()..loadReciters(),
                ),
                BlocProvider<QuranPagePlayerBloc>(
                  create: (_) => sl<QuranPagePlayerBloc>(),
                ),
                BlocProvider<QuranReaderCubit>(
                  create: (_) {
                    final cubit = sl<QuranReaderCubit>();
                    if (surahNumber != null && ayahNumber != null) {
                      cubit.goToAyah(surahNumber, ayahNumber);
                    } else if (pageNumber != null) {
                      cubit.goToPage(pageNumber);
                    } else {
                      cubit.loadInitialPosition();
                    }
                    return cubit;
                  },
                ),
                BlocProvider<BookmarkCubit>.value(
                  value: sl<BookmarkCubit>()..loadBookmarks(),
                ),
                BlocProvider<StarredCubit>.value(
                  value: sl<StarredCubit>()..loadStarredVerses(),
                ),
                BlocProvider<TodayCubit>(create: (_) => sl<TodayCubit>()),
              ],
              child: const QuranReadingPage(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.search,
          name: AppRoutes.searchName,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            opaque: false,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            child: BlocProvider<SearchCubit>(
              create: (_) => sl<SearchCubit>(),
              child: const SearchPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.reciterSurahs,
          name: AppRoutes.reciterSurahsName,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final reciterIdParam = state.uri.queryParameters['reciterId'];
            final moshafIdParam = state.uri.queryParameters['moshafId'];
            final reciterId = int.tryParse(reciterIdParam ?? '') ?? 0;
            final moshafId = int.tryParse(moshafIdParam ?? '');

            return MultiBlocProvider(
              providers: [
                BlocProvider<AudioPlaybackCubit>.value(
                  value: sl<AudioPlaybackCubit>(),
                ),
                BlocProvider<ReciterSurahsCubit>(
                  create: (_) =>
                      sl<ReciterSurahsCubit>()
                        ..loadSurahs(reciterId: reciterId, moshafId: moshafId),
                ),
              ],
              child: ReciterSurahsPage(
                reciterId: reciterId,
                moshafId: moshafId,
              ),
            );
          },
        ),

        // Stateful App Shell containing the 5 bottom tabs in RTL order
        StatefulShellRoute.indexedStack(
          restorationScopeId: 'app_shell_stack',
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: السور (Surahs & Quarters Index)
            StatefulShellBranch(
              navigatorKey: surahsNavigatorKey,
              restorationScopeId: 'surahs_branch',
              routes: [
                GoRoute(
                  path: AppRoutes.surahs,
                  name: AppRoutes.surahsName,
                  builder: (context, state) => const SurahsTabView(),
                ),
              ],
            ),

            // Branch 1: الختمة (Khatma)
            StatefulShellBranch(
              navigatorKey: khatmaNavigatorKey,
              restorationScopeId: 'khatma_branch',
              routes: [
                GoRoute(
                  path: AppRoutes.khatma,
                  name: AppRoutes.khatmaName,
                  builder: (context, state) => const KhatmaTabView(),
                  routes: [
                    GoRoute(
                      path: 'all-wirds',
                      name: AppRoutes.khatmaAllWirdsName,
                      builder: (context, state) => const KhatmaAllWirdsPage(),
                    ),
                  ],
                ),
              ],
            ),

            // Branch 2: الفواصل (Bookmarks)
            StatefulShellBranch(
              navigatorKey: bookmarksNavigatorKey,
              restorationScopeId: 'bookmarks_branch',
              routes: [
                GoRoute(
                  path: AppRoutes.bookmarks,
                  name: AppRoutes.bookmarksName,
                  builder: (context, state) => const BookmarksTabView(),
                ),
              ],
            ),

            // Branch 3: مميزة بنجمة (Starred)
            StatefulShellBranch(
              navigatorKey: starredNavigatorKey,
              restorationScopeId: 'starred_branch',
              routes: [
                GoRoute(
                  path: AppRoutes.starred,
                  name: AppRoutes.starredName,
                  builder: (context, state) => const StarredTabView(),
                ),
              ],
            ),

            // Branch 4: الملاحظات (Notes)
            StatefulShellBranch(
              navigatorKey: notesNavigatorKey,
              restorationScopeId: 'notes_branch',
              routes: [
                GoRoute(
                  path: AppRoutes.notes,
                  name: AppRoutes.notesName,
                  builder: (context, state) => const NotesTabView(),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${AppStrings.tr(AppStrings.pageNotFound)}: ${state.uri}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: Text(AppStrings.tr(AppStrings.returnHome)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Default singleton router instance used by the application.
  static final GoRouter router = createRouter();
}
