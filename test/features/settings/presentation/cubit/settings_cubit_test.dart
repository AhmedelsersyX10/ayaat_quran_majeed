import 'package:ayaat_quran_majeed/features/settings/domain/entities/app_settings.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/repositories/settings_repository.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSettingsRepository implements SettingsRepository {
  AppSettings settings = const AppSettings();
  bool shouldThrow = false;

  @override
  AppSettings getSettings() {
    if (shouldThrow) throw Exception('Failed to load settings');
    return settings;
  }

  @override
  Future<void> setKeepScreenAwake(bool value) async {
    if (shouldThrow) throw Exception('Failed to save keepScreenAwake');
    settings = settings.copyWith(keepScreenAwake: value);
  }

  @override
  Future<void> setHijriOffset(int offset) async {
    if (shouldThrow) throw Exception('Failed to save hijriOffset');
    settings = settings.copyWith(hijriOffset: offset);
  }

  @override
  Future<void> setMushafFontSize(double fontSize) async {
    if (shouldThrow) throw Exception('Failed to save mushafFontSize');
    settings = settings.copyWith(mushafFontSize: fontSize);
  }

  @override
  List<ContentSource> getSourcesAndAttributions() {
    if (shouldThrow) throw Exception('Failed to get sources');
    return const [
      ContentSource(
        title: 'Test Source',
        provider: 'Test Provider',
        description: 'Test Description',
        category: ContentSourceCategory.quranEngine,
      ),
    ];
  }
}

void main() {
  late MockSettingsRepository repository;
  late SettingsCubit cubit;

  setUp(() {
    repository = MockSettingsRepository();
    cubit = SettingsCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('SettingsCubit', () {
    test('initial state is SettingsInitial', () {
      expect(cubit.state, isA<SettingsInitial>());
    });

    test('loadSettings emits SettingsLoaded with settings and sources', () {
      cubit.loadSettings();

      expect(cubit.state, isA<SettingsLoaded>());
      final state = cubit.state as SettingsLoaded;
      expect(state.settings.keepScreenAwake, isTrue);
      expect(state.sources.length, 1);
    });

    test(
      'toggleKeepScreenAwake updates settings and emits new state',
      () async {
        cubit.loadSettings();
        await cubit.toggleKeepScreenAwake(false);

        expect(cubit.state, isA<SettingsLoaded>());
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.keepScreenAwake, isFalse);
        expect(repository.settings.keepScreenAwake, isFalse);
      },
    );

    test('updateHijriOffset updates offset and emits new state', () async {
      cubit.loadSettings();
      await cubit.updateHijriOffset(1);

      expect(cubit.state, isA<SettingsLoaded>());
      final state = cubit.state as SettingsLoaded;
      expect(state.settings.hijriOffset, 1);
      expect(repository.settings.hijriOffset, 1);
    });

    test(
      'updateMushafFontSize updates font size and emits new state',
      () async {
        cubit.loadSettings();
        await cubit.updateMushafFontSize(28.0);

        expect(cubit.state, isA<SettingsLoaded>());
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.mushafFontSize, 28.0);
        expect(repository.settings.mushafFontSize, 28.0);
      },
    );

    test('emits SettingsFailure when repository throws', () async {
      repository.shouldThrow = true;
      cubit.loadSettings();

      expect(cubit.state, isA<SettingsFailure>());
      final state = cubit.state as SettingsFailure;
      expect(state.message, contains('Failed to load settings'));
    });
  });
}
