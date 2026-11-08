import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/network/api_client.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_cache_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/datasources/audio_remote_data_source.dart';
import 'package:ayaat_quran_majeed/features/audio/data/services/audio_player_service.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/playback_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/audio_playback_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/domain/repositories/search_repository.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetInjection();
  });

  tearDown(() async {
    await resetInjection();
  });

  group('Central Dependency Injection Tests', () {
    test('initInjection registers all core singletons and repositories', () async {
      await initInjection();

      expect(sl.isRegistered<AudioPlayer>(), isTrue);
      expect(sl.isRegistered<ApiClient>(), isTrue);
      expect(sl.isRegistered<HiveStorageService>(), isTrue);
      expect(sl.isRegistered<QuranMetadataService>(), isTrue);
      expect(sl.isRegistered<UmmAlQuraDateService>(), isTrue);
      expect(sl.isRegistered<QuranReadingRepository>(), isTrue);
      expect(sl.isRegistered<BookmarkRepository>(), isTrue);
      expect(sl.isRegistered<QuranSearchRepository>(), isTrue);
      expect(sl.isRegistered<SearchRepository>(), isTrue);
      expect(sl.isRegistered<TodayRepository>(), isTrue);
      expect(sl.isRegistered<IndexRepository>(), isTrue);
      expect(sl.isRegistered<AudioRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<AudioCacheDataSource>(), isTrue);
      expect(sl.isRegistered<AudioPlayerService>(), isTrue);
      expect(sl.isRegistered<AudioRepository>(), isTrue);
      expect(sl.isRegistered<PlaybackRepository>(), isTrue);

      expect(sl.isRegistered<QuranPagePlayerBloc>(), isTrue);
      expect(sl.isRegistered<QuranReaderCubit>(), isTrue);
      expect(sl.isRegistered<BookmarkCubit>(), isTrue);
      expect(sl.isRegistered<QuranSearchCubit>(), isTrue);
      expect(sl.isRegistered<SearchCubit>(), isTrue);
      expect(sl.isRegistered<TodayCubit>(), isTrue);
      expect(sl.isRegistered<IndexCubit>(), isTrue);
      expect(sl.isRegistered<ReciterSelectionCubit>(), isTrue);
      expect(sl.isRegistered<AudioPlaybackCubit>(), isTrue);
    });

    test('Singletons return identical instances across multiple resolutions', () async {
      await initInjection();

      final player1 = sl<AudioPlayer>();
      final player2 = sl<AudioPlayer>();
      expect(identical(player1, player2), isTrue);

      final client1 = sl<ApiClient>();
      final client2 = sl<ApiClient>();
      expect(identical(client1, client2), isTrue);
    });

    test('Factories produce fresh, distinct instances for Cubits', () async {
      await initInjection();

      final cubit1 = sl<BookmarkCubit>();
      final cubit2 = sl<BookmarkCubit>();
      expect(identical(cubit1, cubit2), isFalse);

      await cubit1.close();
      await cubit2.close();
    });

    test('resetInjection unregisters all dependencies', () async {
      await initInjection();
      expect(sl.isRegistered<ApiClient>(), isTrue);

      await resetInjection();
      expect(sl.isRegistered<ApiClient>(), isFalse);
      expect(sl.isRegistered<AudioPlayer>(), isFalse);
    });
  });
}
