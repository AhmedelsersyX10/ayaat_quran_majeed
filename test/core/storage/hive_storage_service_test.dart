import 'dart:io';
import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late HiveStorageServiceImpl service;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_storage_test_');
    service = HiveStorageServiceImpl();
    await service.init(storagePath: tempDir.path);
  });

  tearDown(() async {
    await service.closeAll();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('HiveStorageService Lifecycle & CRUD Tests', () {
    test('isInitialized returns true after init', () {
      expect(service.isInitialized, isTrue);
    });

    test('opens and retrieves box cleanly', () async {
      expect(service.isBoxOpen('test_box'), isFalse);
      final box = await service.openBox<String>('test_box');
      expect(service.isBoxOpen('test_box'), isTrue);
      expect(box.isOpen, isTrue);

      final retrieved = service.getBox<String>('test_box');
      expect(retrieved, equals(box));
    });

    test('puts, gets, and deletes data within box', () async {
      final box = await service.openBox<dynamic>('data_box');
      await box.put('key1', 'value1');
      await box.put('key2', 123);

      expect(box.get('key1'), equals('value1'));
      expect(box.get('key2'), equals(123));

      await box.delete('key1');
      expect(box.get('key1'), isNull);
      expect(box.get('key2'), equals(123));
    });

    test('clears box entries cleanly', () async {
      final box = await service.openBox<String>('clear_box');
      await box.put('a', '1');
      await box.put('b', '2');
      expect(box.length, equals(2));

      await service.clearBox('clear_box');
      expect(box.length, equals(0));
    });

    test('closes box properly', () async {
      await service.openBox<String>('close_box');
      expect(service.isBoxOpen('close_box'), isTrue);

      await service.closeBox('close_box');
      expect(service.isBoxOpen('close_box'), isFalse);
    });

    test('compactBox compacts an opened box cleanly', () async {
      final box = await service.openBox<String>('compact_box');
      await box.put('k1', 'v1');
      await box.delete('k1');
      await service.compactBox('compact_box');
      expect(box.isOpen, isTrue);
    });

    test('compactAll compacts all open boxes cleanly', () async {
      final b1 = await service.openBox<String>('box_one');
      final b2 = await service.openBox<String>('box_two');
      await b1.put('k1', 'v1');
      await b2.put('k2', 'v2');
      await service.compactAll();
      expect(b1.isOpen, isTrue);
      expect(b2.isOpen, isTrue);
    });

    test('throws CacheException when getting an unopened box', () {
      expect(
        () => service.getBox('unopened_box'),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('HiveStorageService Self-Healing & Corruption Recovery Tests', () {
    test('automatically recovers when opening a corrupted box file', () async {
      const boxName = 'corrupted_box';

      // 1. Create a valid box, put data, and close it
      final box = await service.openBox<String>(boxName);
      await box.put('pre_corruption_key', 'pre_corruption_value');
      await service.closeBox(boxName);

      // 2. Locate the box file on disk and intentionally corrupt it
      final boxFile = File('${tempDir.path}/$boxName.hive');
      expect(boxFile.existsSync(), isTrue);

      // Write invalid garbage bytes to simulate file corruption
      boxFile.writeAsBytesSync(<int>[0xFF, 0xFE, 0x00, 0x12, 0x34, 0x56, 0x78]);

      // 3. Open the corrupted box — service must detect corruption, delete the file,
      // and re-create a clean, empty box without throwing an unhandled crash
      final recoveredBox = await service.openBox<String>(boxName);
      expect(recoveredBox.isOpen, isTrue);
      expect(recoveredBox.isEmpty, isTrue);

      // 4. Verify the recovered box is completely functional for new writes
      await recoveredBox.put('post_recovery_key', 'post_recovery_value');
      expect(
        recoveredBox.get('post_recovery_key'),
        equals('post_recovery_value'),
      );
    });
  });
}
