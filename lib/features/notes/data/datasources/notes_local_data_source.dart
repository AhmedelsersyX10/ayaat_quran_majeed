import 'dart:convert';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/preferences_storage.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/features/notes/data/models/note_model.dart';
import 'package:hive/hive.dart';

abstract class NotesLocalDataSource {
  /// Loads all stored notes.
  Future<List<NoteModel>> getNotes();

  /// Persists the complete list of notes.
  Future<void> saveNotes(List<NoteModel> notes);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final HiveStorageService? _hiveStorageService;
  final PreferencesStorage? _preferencesStorage;

  NotesLocalDataSourceImpl({
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
  Future<List<NoteModel>> getNotes() async {
    try {
      final box = await _getBox();
      final dynamic raw = box.get(AppStorageKeys.notes);

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

      // Fallback to PreferencesStorage if Hive is empty
      if (list.isEmpty) {
        final legacyString = _preferencesStorage?.getString(AppStorageKeys.notes);
        if (legacyString != null && legacyString.isNotEmpty) {
          try {
            final decodedLegacy = json.decode(legacyString);
            if (decodedLegacy is List && decodedLegacy.isNotEmpty) {
              list = decodedLegacy;
              // Migrate to Hive immediately
              await saveNotes(_parseRawList(list));
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
  Future<void> saveNotes(List<NoteModel> notes) async {
    final box = await _getBox();
    final jsonList = notes.map((m) => m.toMap()).toList(growable: false);
    final encoded = json.encode(jsonList);

    await box.put(AppStorageKeys.notes, encoded);

    // Keep SharedPreferences in sync for backup safety
    try {
      await _preferencesStorage?.setString(AppStorageKeys.notes, encoded);
    } catch (_) {}
  }

  List<NoteModel> _parseRawList(List<dynamic> rawList) {
    final List<NoteModel> result = [];
    final Set<String> seenIds = {};

    for (final raw in rawList) {
      final model = NoteModel.tryParse(raw);
      if (model != null && !seenIds.contains(model.id)) {
        seenIds.add(model.id);
        result.add(model);
      }
    }

    return result;
  }
}

