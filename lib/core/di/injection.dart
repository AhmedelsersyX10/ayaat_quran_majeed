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
import 'package:ayaat_quran_majeed/features/bookmarks/data/datasources/bookmarks_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/data/repositories/index_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/datasources/khatma_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/repositories/khatma_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/services/khatma_reminder_service_impl.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_reminder_service.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/repositories/notes_repository.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/data/repositories/search_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
import 'package:ayaat_quran_majeed/features/share/data/datasources/share_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/share/data/repositories/share_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/share/domain/repositories/share_repository.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/format_share_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/save_ayah_image_to_gallery_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_image_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/cubit/share_cubit.dart';
import 'package:ayaat_quran_majeed/features/starred/data/datasources/starred_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/starred/data/repositories/starred_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/repositories/starred_repository.dart';
import 'package:ayaat_quran_majeed/features/starred/presentation/cubit/starred_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/datasources/tafsir_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/repositories/tafsir_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/repositories/tafsir_repository.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/add_to_my_library_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/delete_downloaded_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/download_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_all_catalog_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_available_tafsir_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_my_library_books_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_page_tafsir_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/get_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/remove_from_my_library_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/set_selected_tafsir_book_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/usecases/update_my_library_order_use_case.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/library_cubit.dart';
import 'package:ayaat_quran_majeed/features/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:ayaat_quran_majeed/features/today/data/repositories/today_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/today/data/services/umm_al_qura_date_service.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/repositories/settings_repository.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_reading_cubit.dart';
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
    sl.registerLazySingleton<HiveStorageService>(
      () => HiveStorageServiceImpl(),
    );
  }

  if (sl.isRegistered<PreferencesStorage>() &&
      !sl.isRegistered<AppPreferences>()) {
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

  if (!sl.isRegistered<KhatmaLocalDataSource>()) {
    sl.registerLazySingleton<KhatmaLocalDataSource>(
      () => KhatmaLocalDataSourceImpl(hiveStorage: sl<HiveStorageService>()),
    );
  }

  if (!sl.isRegistered<KhatmaWirdCalculator>()) {
    sl.registerLazySingleton<KhatmaWirdCalculator>(
      () => KhatmaWirdCalculator(metadataService: sl<QuranMetadataService>()),
    );
  }

  if (!sl.isRegistered<KhatmaReminderService>()) {
    sl.registerLazySingleton<KhatmaReminderService>(
      () => KhatmaReminderServiceImpl(),
    );
  }

  if (!sl.isRegistered<ShareLocalDataSource>()) {
    sl.registerLazySingleton<ShareLocalDataSource>(
      () => const ShareLocalDataSourceImpl(),
    );
  }

  if (!sl.isRegistered<SettingsLocalDataSource>()) {
    sl.registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(
        preferences: sl.isRegistered<AppPreferences>()
            ? sl<AppPreferences>()
            : null,
      ),
    );
  }

  // ---------------------------------------------------------
  // 4. Repositories
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranReadingRepository>()) {
    sl.registerLazySingleton<QuranReadingRepository>(
      () => QuranReadingRepository(metadataService: sl<QuranMetadataService>()),
    );
  }

  if (!sl.isRegistered<BookmarkRepository>()) {
    sl.registerLazySingleton<BookmarkRepository>(
      () => BookmarkRepositoryImpl(
        BookmarksLocalDataSourceImpl(
          hiveStorageService: sl<HiveStorageService>(),
          metadataService: sl<QuranMetadataService>(),
        ),
      ),
    );
  }

  if (!sl.isRegistered<StarredRepository>()) {
    sl.registerLazySingleton<StarredRepository>(
      () => StarredRepositoryImpl(
        localDataSource: StarredLocalDataSourceImpl(
          hiveStorageService: sl.isRegistered<HiveStorageService>()
              ? sl<HiveStorageService>()
              : null,
          preferencesStorage: sl.isRegistered<PreferencesStorage>()
              ? sl<PreferencesStorage>()
              : null,
        ),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<NotesRepository>()) {
    sl.registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(
        localDataSource: NotesLocalDataSourceImpl(
          hiveStorageService: sl.isRegistered<HiveStorageService>()
              ? sl<HiveStorageService>()
              : null,
          preferencesStorage: sl.isRegistered<PreferencesStorage>()
              ? sl<PreferencesStorage>()
              : null,
        ),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchRepository>()) {
    sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(metadataService: sl<QuranMetadataService>()),
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
        preferences: sl.isRegistered<AppPreferences>()
            ? sl<AppPreferences>()
            : null,
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
        preferences: sl.isRegistered<AppPreferences>()
            ? sl<AppPreferences>()
            : null,
      ),
    );
  }

  if (!sl.isRegistered<KhatmaRepository>()) {
    sl.registerLazySingleton<KhatmaRepository>(
      () => KhatmaRepositoryImpl(
        localDataSource: sl<KhatmaLocalDataSource>(),
        metadataService: sl<QuranMetadataService>(),
        calculator: sl<KhatmaWirdCalculator>(),
      ),
    );
  }

  if (!sl.isRegistered<ShareRepository>()) {
    sl.registerLazySingleton<ShareRepository>(
      () => ShareRepositoryImpl(
        localDataSource: sl<ShareLocalDataSource>(),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<SettingsRepository>()) {
    sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        localDataSource: sl<SettingsLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetPageTafsirUseCase>()) {
    sl.registerLazySingleton<GetPageTafsirUseCase>(
      () => GetPageTafsirUseCase(
        repository: sl<TafsirRepository>(),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<GetSelectedTafsirBookUseCase>()) {
    sl.registerLazySingleton<GetSelectedTafsirBookUseCase>(
      () => GetSelectedTafsirBookUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<SetSelectedTafsirBookUseCase>()) {
    sl.registerLazySingleton<SetSelectedTafsirBookUseCase>(
      () => SetSelectedTafsirBookUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<GetAvailableTafsirBooksUseCase>()) {
    sl.registerLazySingleton<GetAvailableTafsirBooksUseCase>(
      () => GetAvailableTafsirBooksUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<GetMyLibraryBooksUseCase>()) {
    sl.registerLazySingleton<GetMyLibraryBooksUseCase>(
      () => GetMyLibraryBooksUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<GetAllCatalogBooksUseCase>()) {
    sl.registerLazySingleton<GetAllCatalogBooksUseCase>(
      () => GetAllCatalogBooksUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateMyLibraryOrderUseCase>()) {
    sl.registerLazySingleton<UpdateMyLibraryOrderUseCase>(
      () => UpdateMyLibraryOrderUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<AddToMyLibraryUseCase>()) {
    sl.registerLazySingleton<AddToMyLibraryUseCase>(
      () => AddToMyLibraryUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<RemoveFromMyLibraryUseCase>()) {
    sl.registerLazySingleton<RemoveFromMyLibraryUseCase>(
      () => RemoveFromMyLibraryUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<DownloadTafsirBookUseCase>()) {
    sl.registerLazySingleton<DownloadTafsirBookUseCase>(
      () => DownloadTafsirBookUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteDownloadedBookUseCase>()) {
    sl.registerLazySingleton<DeleteDownloadedBookUseCase>(
      () => DeleteDownloadedBookUseCase(sl<TafsirRepository>()),
    );
  }

  if (!sl.isRegistered<FormatShareTextUseCase>()) {
    sl.registerLazySingleton<FormatShareTextUseCase>(
      () => FormatShareTextUseCase(sl<ShareRepository>()),
    );
  }

  if (!sl.isRegistered<ShareAyahTextUseCase>()) {
    sl.registerLazySingleton<ShareAyahTextUseCase>(
      () => ShareAyahTextUseCase(sl<ShareRepository>()),
    );
  }

  if (!sl.isRegistered<ShareAyahImageUseCase>()) {
    sl.registerLazySingleton<ShareAyahImageUseCase>(
      () => ShareAyahImageUseCase(sl<ShareRepository>()),
    );
  }

  if (!sl.isRegistered<SaveAyahImageToGalleryUseCase>()) {
    sl.registerLazySingleton<SaveAyahImageToGalleryUseCase>(
      () => SaveAyahImageToGalleryUseCase(sl<ShareRepository>()),
    );
  }

  // ---------------------------------------------------------
  // 3. Presentation / Cubits & Blocs (Factories)
  // ---------------------------------------------------------
  if (!sl.isRegistered<QuranReaderCubit>()) {
    sl.registerFactory<QuranReaderCubit>(
      () => QuranReaderCubit(
        sl<QuranReadingRepository>(),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<BookmarkCubit>()) {
    sl.registerLazySingleton<BookmarkCubit>(
      () => BookmarkCubit(sl<BookmarkRepository>()),
    );
  }

  if (!sl.isRegistered<StarredCubit>()) {
    sl.registerLazySingleton<StarredCubit>(
      () => StarredCubit(sl<StarredRepository>()),
    );
  }

  if (!sl.isRegistered<NotesCubit>()) {
    sl.registerLazySingleton<NotesCubit>(
      () => NotesCubit(
        repository: sl<NotesRepository>(),
        metadataService: sl<QuranMetadataService>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchCubit>()) {
    sl.registerFactory<SearchCubit>(() => SearchCubit(sl<SearchRepository>()));
  }

  if (!sl.isRegistered<TodayCubit>()) {
    sl.registerFactory<TodayCubit>(() => TodayCubit(sl<TodayRepository>()));
  }

  if (!sl.isRegistered<IndexCubit>()) {
    sl.registerFactory<IndexCubit>(() => IndexCubit(sl<IndexRepository>()));
  }

  if (!sl.isRegistered<ReciterSelectionCubit>()) {
    sl.registerFactory<ReciterSelectionCubit>(
      () => ReciterSelectionCubit(audioRepository: sl<AudioRepository>()),
    );
  }

  if (!sl.isRegistered<ReciterSurahsCubit>()) {
    sl.registerFactory<ReciterSurahsCubit>(
      () => ReciterSurahsCubit(audioRepository: sl<AudioRepository>()),
    );
  }

  if (!sl.isRegistered<AudioPlaybackCubit>()) {
    sl.registerLazySingleton<AudioPlaybackCubit>(
      () => AudioPlaybackCubit(playbackRepository: sl<PlaybackRepository>()),
    );
  }

  if (!sl.isRegistered<TafsirCubit>()) {
    sl.registerFactory<TafsirCubit>(
      () => TafsirCubit(
        getPageTafsirUseCase: sl<GetPageTafsirUseCase>(),
        getSelectedTafsirBookUseCase: sl<GetSelectedTafsirBookUseCase>(),
        setSelectedTafsirBookUseCase: sl<SetSelectedTafsirBookUseCase>(),
        getAvailableTafsirBooksUseCase: sl<GetAvailableTafsirBooksUseCase>(),
      ),
    );
  }

  if (!sl.isRegistered<LibraryCubit>()) {
    sl.registerFactory<LibraryCubit>(
      () => LibraryCubit(
        getMyLibraryBooksUseCase: sl<GetMyLibraryBooksUseCase>(),
        getAllCatalogBooksUseCase: sl<GetAllCatalogBooksUseCase>(),
        updateMyLibraryOrderUseCase: sl<UpdateMyLibraryOrderUseCase>(),
        addToMyLibraryUseCase: sl<AddToMyLibraryUseCase>(),
        removeFromMyLibraryUseCase: sl<RemoveFromMyLibraryUseCase>(),
        downloadTafsirBookUseCase: sl<DownloadTafsirBookUseCase>(),
        deleteDownloadedBookUseCase: sl<DeleteDownloadedBookUseCase>(),
      ),
    );
  }

  if (!sl.isRegistered<KhatmaCubit>()) {
    sl.registerFactory<KhatmaCubit>(
      () => KhatmaCubit(
        repository: sl<KhatmaRepository>(),
        reminderService: sl<KhatmaReminderService>(),
      ),
    );
  }

  if (!sl.isRegistered<ShareCubit>()) {
    sl.registerFactory<ShareCubit>(
      () => ShareCubit(
        formatShareTextUseCase: sl<FormatShareTextUseCase>(),
        shareAyahTextUseCase: sl<ShareAyahTextUseCase>(),
        shareAyahImageUseCase: sl<ShareAyahImageUseCase>(),
        saveAyahImageToGalleryUseCase: sl<SaveAyahImageToGalleryUseCase>(),
        metadataService: sl<QuranMetadataService>(),
        tafsirRepository: sl.isRegistered<TafsirRepository>()
            ? sl<TafsirRepository>()
            : null,
      ),
    );
  }

  if (!sl.isRegistered<SettingsCubit>()) {
    sl.registerFactory<SettingsCubit>(
      () => SettingsCubit(repository: sl<SettingsRepository>()),
    );
  }
}

/// Resets all registrations in the service locator (useful for test isolation).
Future<void> resetInjection() async {
  if (sl.isRegistered<BookmarkCubit>()) {
    try {
      await sl<BookmarkCubit>().close();
    } catch (_) {}
  }
  if (sl.isRegistered<StarredCubit>()) {
    try {
      await sl<StarredCubit>().close();
    } catch (_) {}
  }
  if (sl.isRegistered<NotesCubit>()) {
    try {
      await sl<NotesCubit>().close();
    } catch (_) {}
  }
  if (sl.isRegistered<SettingsCubit>()) {
    try {
      await sl<SettingsCubit>().close();
    } catch (_) {}
  }
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
