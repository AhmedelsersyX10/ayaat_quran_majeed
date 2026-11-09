import 'package:ayaat_quran_majeed/core/errors/exceptions.dart';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';

import '../models/khatma_model.dart';

/// Contract for persisting and retrieving the single active Khatma locally.
abstract class KhatmaLocalDataSource {
  /// Retrieves the active Khatma, or returns null if none is saved.
  Future<KhatmaModel?> getActiveKhatma();

  /// Persists [model] as the current active Khatma.
  Future<void> saveActiveKhatma(KhatmaModel model);

  /// Deletes the currently saved active Khatma.
  Future<void> deleteActiveKhatma();
}

/// Implementation of [KhatmaLocalDataSource] backed by Hive document storage.
class KhatmaLocalDataSourceImpl implements KhatmaLocalDataSource {
  final HiveStorageService _hiveStorage;

  const KhatmaLocalDataSourceImpl({required HiveStorageService hiveStorage})
      : _hiveStorage = hiveStorage;

  Future<dynamic> _getBox() async {
    return _hiveStorage.openBox<dynamic>(AppBoxNames.khatmaBox);
  }

  @override
  Future<KhatmaModel?> getActiveKhatma() async {
    try {
      final box = await _getBox();
      final rawData = box.get(AppStorageKeys.activeKhatmaKey);
      if (rawData == null) return null;

      if (rawData is Map) {
        return KhatmaModel.fromMap(rawData);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read active khatma from storage: $e');
    }
  }

  @override
  Future<void> saveActiveKhatma(KhatmaModel model) async {
    try {
      final box = await _getBox();
      await box.put(AppStorageKeys.activeKhatmaKey, model.toMap());
    } catch (e) {
      throw CacheException('Failed to save active khatma to storage: $e');
    }
  }

  @override
  Future<void> deleteActiveKhatma() async {
    try {
      final box = await _getBox();
      await box.delete(AppStorageKeys.activeKhatmaKey);
    } catch (e) {
      throw CacheException('Failed to delete active khatma from storage: $e');
    }
  }
}

