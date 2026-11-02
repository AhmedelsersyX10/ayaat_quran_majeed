import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/splash/splash_screen.dart';
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
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<QuranPagePlayerBloc>(
                  create: (_) => sl<QuranPagePlayerBloc>(),
                ),
                BlocProvider<QuranReaderCubit>(
                  create: (_) => sl<QuranReaderCubit>()..loadInitialPosition(),
                ),
                BlocProvider<BookmarkCubit>(
                  create: (_) => sl<BookmarkCubit>()..loadBookmarks(),
                ),
              ],
              child: const QuranReadingPage(),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الصفحة غير موجودة: ${state.uri}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('العودة للرئيسية'),
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

