import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/audio/data/repositories/playback_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/audio/data/services/audio_player_service.dart';
import 'package:ayaat_quran_majeed/features/audio/data/services/just_audio_player_service.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_surahs_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/data/repositories/index_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/data/repositories/search_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/repositories/tafsir_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:ayaat_quran_majeed/features/today/data/repositories/today_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/today/data/services/umm_al_qura_date_service.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
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
  // 3. Services / Data Sources
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranMetadataService>()) {
    sl.registerLazySingleton<QuranMetadataService>(
      () => const QuranMetadataService(),
    );
  }

  if (!sl.isRegistered<UmmAlQuraDateService>()) {
    sl.registerLazySingleton<UmmAlQuraDateService>(
      () => const UmmAlQuraDateService(),
    );
  }

  if (!sl.isRegistered<AudioRemoteDataSource>()) {
    sl.registerLazySingleton<AudioRemoteDataSource>(
      () => AudioRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
  }

  if (!sl.isRegistered<AudioCacheDataSource>()) {
    sl.registerLazySingleton<AudioCacheDataSource>(
      () => AudioCacheDataSourceImpl(hiveStorage: sl<HiveStorageService>()),
    );
  }

  if (!sl.isRegistered<AudioPlayerService>()) {
    sl.registerLazySingleton<AudioPlayerService>(
      () => JustAudioPlayerServiceImpl(player: sl<AudioPlayer>()),
    );
  }

  if (!sl.isRegistered<TafsirLocalDataSource>()) {
    sl.registerLazySingleton<TafsirLocalDataSource>(
      () => TafsirLocalDataSourceImpl(),
    );
  }

  if (!sl.isRegistered<TafsirRemoteDataSource>()) {
    sl.registerLazySingleton<TafsirRemoteDataSource>(
      () => TafsirRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
  }

  // ---------------------------------------------------------
  // 4. Repositories
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranReadingRepository>()) {
    sl.registerLazySingleton<QuranReadingRepository>(
      () => QuranReadingRepository(
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<BookmarkRepository>()) {
    sl.registerLazySingleton<BookmarkRepository>(
      () => const BookmarkRepository(),
    );
  }

  if (!sl.isRegistered<QuranSearchRepository>()) {
    sl.registerLazySingleton<QuranSearchRepository>(
      () => QuranSearchRepository(
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchRepository>()) {
    sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<TodayRepository>()) {
    sl.registerLazySingleton<TodayRepository>(
      () => TodayRepositoryImpl(
        metadataService: sl<QuranMetadataService>(),
        dateService: sl<UmmAlQuraDateService>(),
        preferences: sl<AppPreferences>(),
      ),
    );
  }

  if (!sl.isRegistered<IndexRepository>()) {
    sl.registerLazySingleton<IndexRepository>(
      () => IndexRepositoryImpl(
        preferences: sl<AppPreferences>(),
        metadataService: sl<QuranMetadataService>(),
        readingRepository: sl<QuranReadingRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<AudioRepository>()) {
    sl.registerLazySingleton<AudioRepository>(
      () => AudioRepositoryImpl(
        remoteDataSource: sl<AudioRemoteDataSource>(),
        cacheDataSource: sl<AudioCacheDataSource>(),
        metadataService: sl<QuranMetadataService>(),
        preferences: sl.isRegistered<AppPreferences>() ? sl<AppPreferences>() : null,
      ),
    );
  }

  if (!sl.isRegistered<PlaybackRepository>()) {
    sl.registerLazySingleton<PlaybackRepository>(
      () => PlaybackRepositoryImpl(
        playerService: sl<AudioPlayerService>(),
        audioRepository: sl<AudioRepository>(),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<TafsirRepository>()) {
    sl.registerLazySingleton<TafsirRepository>(
      () => TafsirRepositoryImpl(
        localDataSource: sl<TafsirLocalDataSource>(),
        remoteDataSource: sl<TafsirRemoteDataSource>(),
        preferences: sl.isRegistered<AppPreferences>() ? sl<AppPreferences>() : null,
      ),
    );
  }

  // ---------------------------------------------------------
  // 3. Presentation / Cubits & Blocs (Factories)
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranPagePlayerBloc>()) {
    sl.registerFactory<QuranPagePlayerBloc>(
      () => QuranPagePlayerBloc(
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<QuranReaderCubit>()) {
    sl.registerFactory<QuranReaderCubit>(
      () => QuranReaderCubit(
        sl<QuranReadingRepository>(),
        metadataService: sl<QuranMetadataService>(),
      ),
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

  if (!sl.isRegistered<SearchCubit>()) {
    sl.registerFactory<SearchCubit>(
      () => SearchCubit(sl<SearchRepository>()),
    );
  }

  if (!sl.isRegistered<TodayCubit>()) {
    sl.registerFactory<TodayCubit>(
      () => TodayCubit(sl<TodayRepository>()),
    );
  }

  if (!sl.isRegistered<IndexCubit>()) {
    sl.registerFactory<IndexCubit>(
      () => IndexCubit(sl<IndexRepository>()),
    );
  }

  if (!sl.isRegistered<ReciterSelectionCubit>()) {
    sl.registerFactory<ReciterSelectionCubit>(
      () => ReciterSelectionCubit(
        audioRepository: sl<AudioRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<ReciterSurahsCubit>()) {
    sl.registerFactory<ReciterSurahsCubit>(
      () => ReciterSurahsCubit(
        audioRepository: sl<AudioRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<AudioPlaybackCubit>()) {
    sl.registerLazySingleton<AudioPlaybackCubit>(
      () => AudioPlaybackCubit(
        playbackRepository: sl<PlaybackRepository>(),
      ),
    );
  }
}

/// Resets all registrations in the service locator (useful for test isolation).
Future<void> resetInjection() async {
  if (sl.isRegistered<PlaybackRepository>()) {
    try {
      await sl<PlaybackRepository>().dispose();
    } catch (_) {}
  }
  if (sl.isRegistered<HiveStorageService>()) {
    try {
      await sl<HiveStorageService>().closeAll();
    } catch (_) {}
  }
  await sl.reset();
}
