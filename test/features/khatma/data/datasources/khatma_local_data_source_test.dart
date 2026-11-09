import 'dart:io';

import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/datasources/khatma_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/models/khatma_model.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/models/khatma_wird_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late HiveStorageService hiveStorage;
  late KhatmaLocalDataSource dataSource;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('khatma_ds_test_');
    hiveStorage = HiveStorageServiceImpl();
    await hiveStorage.init(storagePath: tempDir.path);
    dataSource = KhatmaLocalDataSourceImpl(hiveStorage: hiveStorage);
  });

  tearDown(() async {
    await hiveStorage.closeAll();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('KhatmaLocalDataSource Tests', () {
    test('returns null when no active khatma is stored', () async {
      final active = await dataSource.getActiveKhatma();
      expect(active, isNull);
    });

    test('saves and retrieves active KhatmaModel accurately', () async {
      final model = KhatmaModel(
        id: 'test_khatma_1',
        programId: 'meaning_29',
        programTitle: 'ختمة شهر (٢٩ يومًا)',
        totalDays: 29,
        startDate: DateTime(2026, 11, 10),
        wirds: [
          KhatmaWirdModel(
            dayNumber: 1,
            scheduledDate: DateTime(2026, 11, 10),
            startSurah: 1,
            startAyah: 1,
            endSurah: 2,
            endAyah: 141,
            rangeText: 'من الفاتحة إلى البقرة: ١٤١',
            isCompleted: false,
          ),
        ],
        reminderEnabled: true,
        reminderTimeHour: 19,
        reminderTimeMinute: 0,
        completedWirdsCount: 0,
        createdAt: DateTime(2026, 11, 10, 8, 0),
      );

      await dataSource.saveActiveKhatma(model);

      final retrieved = await dataSource.getActiveKhatma();
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test_khatma_1'));
      expect(retrieved.programId, equals('meaning_29'));
      expect(retrieved.totalDays, equals(29));
      expect(retrieved.reminderEnabled, isTrue);
      expect(retrieved.wirds.length, equals(1));
      expect(retrieved.wirds.first.rangeText, equals('من الفاتحة إلى البقرة: ١٤١'));
    });

    test('deletes active khatma from storage', () async {
      final model = KhatmaModel(
        id: 'to_delete',
        programId: 'meaning_29',
        programTitle: 'ختمة شهر (٢٩ يومًا)',
        totalDays: 29,
        startDate: DateTime(2026, 11, 10),
        wirds: [],
        createdAt: DateTime(2026, 11, 10),
      );

      await dataSource.saveActiveKhatma(model);
      expect(await dataSource.getActiveKhatma(), isNotNull);

      await dataSource.deleteActiveKhatma();
      expect(await dataSource.getActiveKhatma(), isNull);
    });
  });
}

