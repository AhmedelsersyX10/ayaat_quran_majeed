import 'dart:convert';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/features/starred/data/models/starred_ayah_model.dart';
import 'package:hive/hive.dart';

abstract class StarredLocalDataSource {
  /// Loads all stored starred verses.
  Future<List<StarredAyahModel>> getStarredVerses();

  /// Persists the list of starred verses.
  Future<void> saveStarredVerses(List<StarredAyahModel> items);
}

class StarredLocalDataSourceImpl implements StarredLocalDataSource {
  final HiveStorageService? _hiveStorageService;
  final PreferencesStorage? _preferencesStorage;

  StarredLocalDataSourceImpl({
    HiveStorageService? hiveStorageService,
    PreferencesStorage? preferencesStorage,
  })  : _hiveStorageService = hiveStorageService,
        _preferencesStorage = preferencesStorage;

  Future<Box<dynamic>> _getBox() async {
    const boxName = AppBoxNames.legacyBox;
    final hiveService = _hiveStorageService;
    if (hiveService != null) {
      if (hiveService.isBoxOpen(boxName)) {
        return hiveService.getBox(boxName);
      }
      return await hiveService.openBox(boxName);
    }
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<StarredAyahModel>> getStarredVerses() async {
    try {
      final box = await _getBox();
      final dynamic raw = box.get(AppStorageKeys.starredVerses);

      List<dynamic> list = [];
      if (raw != null) {
        if (raw is String && raw.isNotEmpty) {
          final decoded = json.decode(raw);
          if (decoded is List) {
            list = decoded;
          }
        } else if (raw is List) {
          list = raw;
        }
      }

      // If Hive is empty, check legacy SharedPreferences 'starredVerses'
      if (list.isEmpty) {
        final legacyString = _preferencesStorage?.getString('starredVerses');
        if (legacyString != null && legacyString.isNotEmpty) {
          try {
            final decodedLegacy = json.decode(legacyString);
            if (decodedLegacy is List && decodedLegacy.isNotEmpty) {
              list = decodedLegacy;
              // Migrate to Hive immediately
              await saveStarredVerses(_parseRawList(list));
            }
          } catch (_) {}
        }
      }

      return _parseRawList(list);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveStarredVerses(List<StarredAyahModel> items) async {
    final box = await _getBox();
    final jsonList = items.map((m) => m.toMap()).toList(growable: false);
    final encoded = json.encode(jsonList);

    await box.put(AppStorageKeys.starredVerses, encoded);

    // Keep legacy SharedPreferences key in sync for backwards compatibility
    try {
      final legacyList = items.map((m) => '${m.surahNumber}:${m.verseNumber}').toList();
      await _preferencesStorage?.setString('starredVerses', json.encode(legacyList));
    } catch (_) {}
  }

  List<StarredAyahModel> _parseRawList(List<dynamic> rawList) {
    final Map<String, StarredAyahModel> uniqueMap = {};
    for (final raw in rawList) {
      final model = StarredAyahModel.tryParse(raw);
      if (model != null) {
        uniqueMap[model.key] = model;
      }
    }
    return uniqueMap.values.toList();
  }
}

