import 'dart:async';
import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:hive/hive.dart';

/// Abstract contract for managing Hive document and object boxes.
/// Pure Dart — no Flutter framework dependencies.
abstract class HiveStorageService {
  /// Checks whether Hive has been initialized.
  bool get isInitialized;

  /// Initializes Hive storage with the given directory [storagePath].
  Future<void> init({String? storagePath});

  /// Opens a box by [boxName] with automatic corruption recovery.
  Future<Box<T>> openBox<T>(String boxName);

  /// Returns an already opened box by [boxName].
  Box<T> getBox<T>(String boxName);

  /// Checks if a box is currently open.
  bool isBoxOpen(String boxName);

  /// Closes an open box by [boxName].
  Future<void> closeBox(String boxName);

  /// Deletes a box and its files from disk.
  Future<void> deleteBoxFromDisk(String boxName);

  /// Clears all entries from the box without deleting the box file.
  Future<void> clearBox(String boxName);

  /// Closes all currently opened boxes.
  Future<void> closeAll();
}

/// Implementation of [HiveStorageService] with self-healing corruption recovery.
class HiveStorageServiceImpl implements HiveStorageService {
  bool _isInitialized = false;
  final Map<String, Box<dynamic>> _openBoxes = {};

  HiveStorageServiceImpl();

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> init({String? storagePath}) async {
    try {
      if (storagePath != null && storagePath.isNotEmpty) {
        Hive.init(storagePath);
      }
      _isInitialized = true;
    } catch (e) {
      throw CacheException('Failed to initialize Hive at path "$storagePath": $e');
    }
  }

  @override
  Future<Box<T>> openBox<T>(String boxName) async {
    if (isBoxOpen(boxName)) {
      return getBox<T>(boxName);
    }

    try {
      final box = await Hive.openBox<T>(boxName);
      _openBoxes[boxName] = box;
      return box;
    } catch (error) {
      // Corruption or fatal read failure detected.
      // Attempt self-healing by deleting corrupted box file and recreating it.
      try {
        _openBoxes.remove(boxName);
        await Hive.deleteBoxFromDisk(boxName);
        final recoveredBox = await Hive.openBox<T>(boxName);
        _openBoxes[boxName] = recoveredBox;
        return recoveredBox;
      } catch (recoveryError) {
        throw CacheException(
          'Failed to open and recover corrupted Hive box "$boxName": $recoveryError (Original: $error)',
        );
      }
    }
  }

  @override
  Box<T> getBox<T>(String boxName) {
    try {
      if (_openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen) {
        return _openBoxes[boxName]! as Box<T>;
      }
      final box = Hive.box<T>(boxName);
      _openBoxes[boxName] = box;
      return box;
    } catch (e) {
      throw CacheException('Box "$boxName" is not opened or accessible: $e');
    }
  }

  @override
  bool isBoxOpen(String boxName) {
    if (_openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen) {
      return true;
    }
    return Hive.isBoxOpen(boxName);
  }

  @override
  Future<void> closeBox(String boxName) async {
    try {
      if (_openBoxes.containsKey(boxName)) {
        final box = _openBoxes[boxName]!;
        if (box.isOpen) {
          await box.close();
        }
        _openBoxes.remove(boxName);
      } else if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
    } catch (e) {
      throw CacheException('Failed to close box "$boxName": $e');
    }
  }

  @override
  Future<void> deleteBoxFromDisk(String boxName) async {
    try {
      _openBoxes.remove(boxName);
      await Hive.deleteBoxFromDisk(boxName);
    } catch (e) {
      throw CacheException('Failed to delete box "$boxName" from disk: $e');
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    try {
      final box = isBoxOpen(boxName) ? getBox(boxName) : await openBox(boxName);
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear box "$boxName": $e');
    }
  }

  @override
  Future<void> closeAll() async {
    try {
      _openBoxes.clear();
      await Hive.close();
    } catch (e) {
      throw CacheException('Failed to close all Hive boxes: $e');
    }
  }
}
