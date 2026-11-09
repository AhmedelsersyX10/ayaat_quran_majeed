import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_program.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/services/khatma_wird_calculator.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MockKhatmaRepository implements KhatmaRepository {
  Khatma? activeKhatma;
  bool shouldThrow = false;

  final KhatmaWirdCalculator calculator =
      const KhatmaWirdCalculator(metadataService: QuranMetadataService());

  @override
  Future<Khatma?> getActiveKhatma() async {
    if (shouldThrow) throw const KhatmaException('Storage failure');
    return activeKhatma;
  }

  @override
  Future<Khatma> createKhatma({
    required KhatmaProgram program,
    required DateTime startDate,
    int startWirdNumber = 1,
    bool reminderEnabled = false,
    int reminderHour = 19,
    int reminderMinute = 0,
  }) async {
    if (shouldThrow) throw const KhatmaException('Creation failure');

    final wirds = calculator.calculateWirds(
      program: program,
      startDate: startDate,
      startWirdNumber: startWirdNumber,
    );

    activeKhatma = Khatma(
      id: 'mock_khatma_1',
      programId: program.id,
      programTitle: program.title,
      totalDays: program.totalDays,
      startDate: startDate,
      wirds: wirds,
      reminderEnabled: reminderEnabled,
      reminderTimeHour: reminderHour,
      reminderTimeMinute: reminderMinute,
      completedWirdsCount: wirds.where((w) => w.isCompleted).length,
      createdAt: startDate,
    );
    return activeKhatma!;
  }

  @override
  Future<Khatma> completeWird(int wirdNumber, {DateTime? completionDate}) async {
    if (shouldThrow || activeKhatma == null) throw const KhatmaException('Error completing wird');

    final updatedWirds = activeKhatma!.wirds.map((w) {
      if (w.dayNumber == wirdNumber) {
        return w.copyWith(isCompleted: true, completedAt: completionDate ?? DateTime.now());
      }
      return w;
    }).toList();

    activeKhatma = activeKhatma!.copyWith(
      wirds: updatedWirds,
      completedWirdsCount: updatedWirds.where((w) => w.isCompleted).length,
    );
    return activeKhatma!;
  }

  @override
  Future<Khatma> completeCurrentWird({DateTime? completionDate}) async {
    if (activeKhatma == null) throw const KhatmaException('No active khatma');
    return completeWird(activeKhatma!.currentWird.dayNumber, completionDate: completionDate);
  }

  @override
  Future<Khatma> uncompleteWird(int wirdNumber) async {
    if (shouldThrow || activeKhatma == null) throw const KhatmaException('Error uncompleting wird');

    final updatedWirds = activeKhatma!.wirds.map((w) {
      if (w.dayNumber == wirdNumber) {
        return w.copyWith(isCompleted: false, completedAt: null);
      }
      return w;
    }).toList();

    activeKhatma = activeKhatma!.copyWith(
      wirds: updatedWirds,
      completedWirdsCount: updatedWirds.where((w) => w.isCompleted).length,
    );
    return activeKhatma!;
  }

  @override
  Future<void> deleteKhatma() async {
    if (shouldThrow) throw const KhatmaException('Deletion error');
    activeKhatma = null;
  }

  @override
  Future<Khatma> updateReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    if (shouldThrow || activeKhatma == null) throw const KhatmaException('Reminder update error');

    activeKhatma = activeKhatma!.copyWith(
      reminderEnabled: enabled,
      reminderTimeHour: hour ?? activeKhatma!.reminderTimeHour,
      reminderTimeMinute: minute ?? activeKhatma!.reminderTimeMinute,
    );
    return activeKhatma!;
  }
}

void main() {
  late MockKhatmaRepository repository;
  late KhatmaCubit cubit;
  late DateTime fixedToday;

  setUp(() {
    repository = MockKhatmaRepository();
    fixedToday = DateTime(2026, 11, 10, 10, 0);

    cubit = KhatmaCubit(
      repository: repository,
      clock: () => fixedToday,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('KhatmaCubit Tests', () {
    test('initial state is KhatmaInitial', () {
      expect(cubit.state, equals(const KhatmaInitial()));
    });

    test('loadKhatma emits [loading, empty] when no active khatma', () async {
      final states = <KhatmaState>[];
      cubit.stream.listen(states.add);

      await cubit.loadKhatma();
      await pumpEventQueue();

      expect(states, [
        const KhatmaLoading(),
        const KhatmaEmpty(),
      ]);
    });

    test('loadKhatma emits [loading, loaded] when active khatma exists with correct relative label', () async {
      await repository.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: fixedToday,
      );

      final states = <KhatmaState>[];
      cubit.stream.listen(states.add);

      await cubit.loadKhatma();
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], equals(const KhatmaLoading()));
      expect(states[1], isA<KhatmaLoaded>());

      final loaded = states[1] as KhatmaLoaded;
      expect(loaded.khatma.programId, equals('meaning_29'));
      expect(loaded.currentWird.dayNumber, equals(1));
      expect(loaded.relativeDayLabel, equals('اليوم'));
    });

    test('createKhatma emits [loading, loaded]', () async {
      final states = <KhatmaState>[];
      cubit.stream.listen(states.add);

      await cubit.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: fixedToday,
      );
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], equals(const KhatmaLoading()));
      expect(states[1], isA<KhatmaLoaded>());
      final loaded = states[1] as KhatmaLoaded;
      expect(loaded.currentWird.dayNumber, equals(1));
    });

    test('completeCurrentWird updates progress and emits loaded with justCompletedWird true', () async {
      await cubit.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: fixedToday,
      );

      final states = <KhatmaState>[];
      cubit.stream.listen(states.add);

      await cubit.completeCurrentWird();
      await pumpEventQueue();

      expect(states.length, equals(1));
      expect(states[0], isA<KhatmaLoaded>());
      final loaded = states[0] as KhatmaLoaded;
      expect(loaded.justCompletedWird, isTrue);
      expect(loaded.khatma.completedWirdsCount, equals(1));
      expect(loaded.currentWird.dayNumber, equals(2));
      // Day 2 scheduled for tomorrow -> label is غداً
      expect(loaded.relativeDayLabel, equals('غداً'));
    });

    test('reading ahead to day 3 computes relative label بعد يومين matching Ref 26', () async {
      await cubit.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: fixedToday,
      );

      await cubit.completeCurrentWird(); // Completed day 1
      await cubit.completeCurrentWird(); // Completed day 2

      final loaded = cubit.state as KhatmaLoaded;
      expect(loaded.currentWird.dayNumber, equals(3));
      expect(loaded.relativeDayLabel, equals('بعد يومين'));
    });

    test('deleteKhatma clears active khatma and emits [loading, empty]', () async {
      await cubit.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: fixedToday,
      );

      final states = <KhatmaState>[];
      cubit.stream.listen(states.add);

      await cubit.deleteKhatma();
      await pumpEventQueue();

      expect(states, [
        const KhatmaLoading(),
        const KhatmaEmpty(),
      ]);
    });

    test('toggleReminder and updateReminderTime update settings smoothly', () async {
      await cubit.createKhatma(
        program: KhatmaProgram.defaultProgram,
        startDate: fixedToday,
        reminderEnabled: false,
      );

      await cubit.toggleReminder(true);
      await pumpEventQueue();
      var loaded = cubit.state as KhatmaLoaded;
      expect(loaded.khatma.reminderEnabled, isTrue);

      await cubit.updateReminderTime(21, 45);
      await pumpEventQueue();
      loaded = cubit.state as KhatmaLoaded;
      expect(loaded.khatma.reminderTimeHour, equals(21));
      expect(loaded.khatma.reminderTimeMinute, equals(45));
    });

    test('emits KhatmaFailure on exception', () async {
      repository.shouldThrow = true;

      final states = <KhatmaState>[];
      cubit.stream.listen(states.add);

      await cubit.loadKhatma();
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], equals(const KhatmaLoading()));
      expect(states[1], isA<KhatmaFailure>());
    });
  });
}
