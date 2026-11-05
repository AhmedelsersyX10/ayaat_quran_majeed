import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:ayaat_quran_majeed/quran/data/models/selected_ayah.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/quran_reading_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReadingRepository implements QuranReadingRepository {
  ReadingPosition currentPosition;

  _FakeReadingRepository({required this.currentPosition});

  @override
  QuranMetadataService get metadataService => const QuranMetadataService();

  @override
  ReadingPosition validateAndNormalize(ReadingPosition rawPosition) => rawPosition;

  @override
  Future<ReadingPosition> loadLastPosition() async => currentPosition;

  @override
  Future<void> savePosition(ReadingPosition position) async {
    currentPosition = position;
  }
}

void main() {
  group('QuranReaderCubit Ayah Selection Tests (Task 2.05)', () {
    late _FakeReadingRepository repository;
    late QuranReaderCubit cubit;
    const metadataService = QuranMetadataService();

    setUp(() {
      repository = _FakeReadingRepository(
        currentPosition: const ReadingPosition(
          page: 1,
          surahNumber: 1,
          ayahNumber: 1,
        ),
      );
      cubit = QuranReaderCubit(
        repository,
        metadataService: metadataService,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial reading state has null selectedAyah', () {
      expect(cubit.state.selectedAyah, isNull);
    });

    test('selectAyah sets selectedAyah with correct surah, ayah, and page', () {
      // Surah Al-Fatihah, Ayah 1 (Page 1)
      cubit.selectAyah(1, 1);

      expect(
        cubit.state.selectedAyah,
        equals(const SelectedAyah(surahNumber: 1, ayahNumber: 1, pageNumber: 1)),
      );
    });

    test('selectAyah handles multi-line verse (Al-Baqarah Ayah 6 on Page 3 matching Ref 19)', () {
      // Surah 2, Ayah 6 is on Page 3 and spans lines 1 and 2
      cubit.selectAyah(2, 6);

      final selected = cubit.state.selectedAyah;
      expect(selected, isNotNull);
      expect(selected!.surahNumber, 2);
      expect(selected.ayahNumber, 6);
      expect(selected.pageNumber, 3);
    });

    test('selectAyah clamps out of range surah and ayah numbers safely', () {
      // Negative surah and ayah clamp to 1:1
      cubit.selectAyah(-5, -10);
      expect(cubit.state.selectedAyah?.surahNumber, 1);
      expect(cubit.state.selectedAyah?.ayahNumber, 1);

      // Surah > 114 clamps to 114 (An-Nas), ayah > 6 clamps to 6
      cubit.selectAyah(200, 500);
      expect(cubit.state.selectedAyah?.surahNumber, 114);
      expect(cubit.state.selectedAyah?.ayahNumber, 6);
      expect(cubit.state.selectedAyah?.pageNumber, 604);
    });

    test('clearSelectedAyah removes the active selection', () {
      cubit.selectAyah(2, 255);
      expect(cubit.state.selectedAyah, isNotNull);

      cubit.clearSelectedAyah();
      expect(cubit.state.selectedAyah, isNull);
    });

    test('SelectedAyah equality and hashCode work correctly', () {
      const a = SelectedAyah(surahNumber: 2, ayahNumber: 6, pageNumber: 2);
      const b = SelectedAyah(surahNumber: 2, ayahNumber: 6, pageNumber: 2);
      const c = SelectedAyah(surahNumber: 2, ayahNumber: 7, pageNumber: 2);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('SelectedAyah(surah: 2, ayah: 6, page: 2)'));
    });
  });
}
