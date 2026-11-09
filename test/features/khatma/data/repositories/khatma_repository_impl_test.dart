import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/datasources/khatma_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/models/khatma_model.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/repositories/khatma_repository_impl.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeKhatmaLocalDataSource implements KhatmaLocalDataSource {
  KhatmaModel? storedModel;

  @override
  Future<KhatmaModel?> getActiveKhatma() async => storedModel;

  @override
  Future<void> saveActiveKhatma(KhatmaModel model) async {
    storedModel = model;
  }

  @override
  Future<void> deleteActiveKhatma() async {
    storedModel = null;
  }
}

void main() {
  late FakeKhatmaLocalDataSource localDataSource;
  late QuranMetadataService metadataService;
  late KhatmaWirdCalculator calculator;
  late KhatmaRepository repository;
  late DateTime fixedTime;

  setUp(() {
    localDataSource = FakeKhatmaLocalDataSource();
    metadataService = const QuranMetadataService();
    calculator = KhatmaWirdCalculator(metadataService: metadataService);
    fixedTime = DateTime(2026, 11, 10, 10, 0);

    repository = KhatmaRepositoryImpl(
      localDataSource: localDataSource,
      metadataService: metadataService,
      calculator: calculator,
      clock: () => fixedTime,
    );
  });

  group('KhatmaRepositoryImpl Tests', () {
    test('getActiveKhatma returns null when empty', () async {
      final active = await repository.getActiveKhatma();
      expect(active, isNull);
    });

    test('createKhatma calculates wirds, saves and returns active khatma', () async {
      final startDate = DateTime(2026, 11, 10);
      final khatma = await repository.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
        reminderEnabled: true,
        reminderHour: 19,
        reminderMinute: 0,
      );

      expect(khatma.programId, equals('meaning_29'));
      expect(khatma.totalDays, equals(29));
      expect(khatma.wirds.length, equals(29));
      expect(khatma.completedWirdsCount, equals(0));
      expect(khatma.reminderEnabled, isTrue);
      expect(khatma.reminderTimeHour, equals(19));
      expect(khatma.currentWird.dayNumber, equals(1));
      expect(localDataSource.storedModel, isNotNull);
    });

    test('completeCurrentWird marks active wird as completed', () async {
      final startDate = DateTime(2026, 11, 10);
      await repository.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
      );

      final updated = await repository.completeCurrentWird();
      expect(updated.completedWirdsCount, equals(1));
      expect(updated.wirds[0].isCompleted, isTrue);
      expect(updated.wirds[0].completedAt, equals(fixedTime));
      expect(updated.currentWird.dayNumber, equals(2));
      expect(updated.isCompleted, isFalse);
    });

    test('completing all wirds marks khatma as completed', () async {
      // Create a small test khatma with 3 days
      final program3 = KhatmaProgram.findById('parts_3')!;
      final startDate = DateTime(2026, 11, 10);
      await repository.createKhatma(
        program: program3,
        startDate: startDate,
      );

      await repository.completeWird(1);
      await repository.completeWird(2);
      final finalKhatma = await repository.completeWird(3);

      expect(finalKhatma.completedWirdsCount, equals(3));
      expect(finalKhatma.isCompleted, isTrue);
      expect(finalKhatma.completedAt, equals(fixedTime));
    });

    test('uncompleteWird reverts completion state', () async {
      final startDate = DateTime(2026, 11, 10);
      await repository.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
      );

      await repository.completeWird(1);
      var current = await repository.getActiveKhatma();
      expect(current!.completedWirdsCount, equals(1));

      final reverted = await repository.uncompleteWird(1);
      expect(reverted.completedWirdsCount, equals(0));
      expect(reverted.wirds[0].isCompleted, isFalse);
      expect(reverted.wirds[0].completedAt, isNull);
    });

    test('deleteKhatma deletes from storage', () async {
      final startDate = DateTime(2026, 11, 10);
      await repository.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
      );
      expect(localDataSource.storedModel, isNotNull);

      await repository.deleteKhatma();
      expect(localDataSource.storedModel, isNull);
      expect(await repository.getActiveKhatma(), isNull);
    });

    test('updateReminder toggles switch and updates time', () async {
      final startDate = DateTime(2026, 11, 10);
      await repository.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: startDate,
        reminderEnabled: false,
      );

      final updated = await repository.updateReminder(
        enabled: true,
        hour: 20,
        minute: 15,
      );

      expect(updated.reminderEnabled, isTrue);
      expect(updated.reminderTimeHour, equals(20));
      expect(updated.reminderTimeMinute, equals(15));
    });

    test('throws KhatmaException when modifying without active khatma', () async {
      expect(
        () => repository.completeWird(1),
        throwsA(isA<KhatmaException>()),
      );
      expect(
        () => repository.completeCurrentWird(),
        throwsA(isA<KhatmaException>()),
      );
      expect(
        () => repository.uncompleteWird(1),
        throwsA(isA<KhatmaException>()),
      );
      expect(
        () => repository.updateReminder(enabled: true),
        throwsA(isA<KhatmaException>()),
      );
    });
  });
}

