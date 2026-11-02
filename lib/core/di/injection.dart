import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/bookmark_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_search_repository.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_page_player_bloc.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_reading_cubit.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_search_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

/// Central service locator instance
final GetIt sl = GetIt.instance;

/// Initializes central dependency injection registrations.
Future<void> initInjection() async {
  // ---------------------------------------------------------
  // 1. External / Core Singletons
  // ---------------------------------------------------------
  if (!sl.isRegistered<AudioPlayer>()) {
    sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  }

  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // ---------------------------------------------------------
  // 2. Storage Layer Singletons (if not already registered by StorageInitializer)
  // ---------------------------------------------------------
  if (!sl.isRegistered<HiveStorageService>()) {
    sl.registerLazySingleton<HiveStorageService>(() => HiveStorageServiceImpl());
  }

  if (sl.isRegistered<PreferencesStorage>() && !sl.isRegistered<AppPreferences>()) {
    sl.registerLazySingleton<AppPreferences>(
      () => AppPreferences(sl<PreferencesStorage>()),
    );
  }

  // ---------------------------------------------------------
  // 3. Repositories
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranReadingRepository>()) {
    sl.registerLazySingleton<QuranReadingRepository>(
      () => const QuranReadingRepository(),
    );
  }

  if (!sl.isRegistered<BookmarkRepository>()) {
    sl.registerLazySingleton<BookmarkRepository>(
      () => const BookmarkRepository(),
    );
  }

  if (!sl.isRegistered<QuranSearchRepository>()) {
    sl.registerLazySingleton<QuranSearchRepository>(
      () => QuranSearchRepository(),
    );
  }

  // ---------------------------------------------------------
  // 3. Presentation / Cubits & Blocs (Factories)
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranPagePlayerBloc>()) {
    sl.registerFactory<QuranPagePlayerBloc>(
      () => QuranPagePlayerBloc(),
    );
  }

  if (!sl.isRegistered<QuranReaderCubit>()) {
    sl.registerFactory<QuranReaderCubit>(
      () => QuranReaderCubit(sl<QuranReadingRepository>()),
    );
  }

  if (!sl.isRegistered<BookmarkCubit>()) {
    sl.registerFactory<BookmarkCubit>(
      () => BookmarkCubit(sl<BookmarkRepository>()),
    );
  }

  if (!sl.isRegistered<QuranSearchCubit>()) {
    sl.registerFactory<QuranSearchCubit>(
      () => QuranSearchCubit(sl<QuranSearchRepository>()),
    );
  }
}

/// Resets all registrations in the service locator (useful for test isolation).
Future<void> resetInjection() async {
  if (sl.isRegistered<HiveStorageService>()) {
    try {
      await sl<HiveStorageService>().closeAll();
    } catch (_) {}
  }
  await sl.reset();
}
