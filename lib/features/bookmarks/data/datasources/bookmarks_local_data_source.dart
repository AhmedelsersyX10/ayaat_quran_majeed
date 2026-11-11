import 'dart:convert';
import 'package:ayaat_quran_majeed/core/storage/hive_storage_service.dart';
import 'package:ayaat_quran_majeed/core/storage/storage_keys.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:hive/hive.dart';

abstract class BookmarksLocalDataSource {
  /// Loads all bookmarks, guaranteeing the 4 standard slots exist.
  Future<List<BookmarkModel>> getBookmarks();

  /// Persists bookmarks list.
  Future<void> saveBookmarks(List<BookmarkModel> bookmarks);
}

class BookmarksLocalDataSourceImpl implements BookmarksLocalDataSource {
  final HiveStorageService? _hiveStorageService;
  final QuranMetadataService? _metadataService;

  BookmarksLocalDataSourceImpl({
    HiveStorageService? hiveStorageService,
    QuranMetadataService? metadataService,
  }) : _hiveStorageService = hiveStorageService,
       _metadataService = metadataService;

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
  Future<List<BookmarkModel>> getBookmarks() async {
    try {
      final box = await _getBox();
      final dynamic raw = box.get(AppStorageKeys.legacyBookmarks);
      if (raw == null) {
        return _buildInitialDefaultModels();
      }

      List<dynamic> list;
      if (raw is String) {
        if (raw.isEmpty) return _buildInitialDefaultModels();
        final decoded = json.decode(raw);
        if (decoded is List) {
          list = decoded;
        } else {
          return _buildInitialDefaultModels();
        }
      } else if (raw is List) {
        list = raw;
      } else {
        return _buildInitialDefaultModels();
      }

      final parsed = <BookmarkModel>[];
      for (final item in list) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          parsed.add(BookmarkModel.fromMap(map));
        }
      }

      return _normalizeWithDefaults(parsed);
    } catch (_) {
      return _buildInitialDefaultModels();
    }
  }

  @override
  Future<void> saveBookmarks(List<BookmarkModel> bookmarks) async {
    final box = await _getBox();
    final jsonList = bookmarks.map((b) => b.toMap()).toList(growable: false);
    final encoded = json.encode(jsonList);
    await box.put(AppStorageKeys.legacyBookmarks, encoded);
  }

  List<BookmarkModel> _buildInitialDefaultModels() {
    return BookmarkItem.defaultSlots()
        .map(BookmarkModel.fromEntity)
        .toList(growable: true);
  }

  List<BookmarkModel> _normalizeWithDefaults(List<BookmarkModel> existing) {
    final Map<String, BookmarkModel> map = {};
    final customList = <BookmarkModel>[];

    for (final item in existing) {
      String? matchedId;
      if (item.id == BookmarkItem.defaultRedId ||
          item.id == BookmarkItem.defaultYellowId ||
          item.id == BookmarkItem.defaultGreenId ||
          item.id == BookmarkItem.defaultBlueId) {
        matchedId = item.id;
      } else if (item.colorHex.toUpperCase().contains('C9484A') ||
          item.name.contains('الأحمر')) {
        matchedId = BookmarkItem.defaultRedId;
      } else if (item.colorHex.toUpperCase().contains('D7AC3C') ||
          item.name.contains('الأصفر')) {
        matchedId = BookmarkItem.defaultYellowId;
      } else if (item.colorHex.toUpperCase().contains('62A77B') ||
          item.name.contains('الأخضر')) {
        matchedId = BookmarkItem.defaultGreenId;
      } else if (item.colorHex.toUpperCase().contains('218FC9') ||
          item.name.contains('الأزرق')) {
        matchedId = BookmarkItem.defaultBlueId;
      }

      if (matchedId != null) {
        int? page = item.pageNumber;
        if (page == null &&
            item.surahNumber != null &&
            item.verseNumber != null) {
          page = _metadataService?.getPageNumber(
            item.surahNumber!,
            item.verseNumber!,
          );
        }

        map[matchedId] = BookmarkModel(
          id: matchedId,
          name: item.name.isNotEmpty ? item.name : _defaultNameForId(matchedId),
          colorHex: item.colorHex.isNotEmpty
              ? item.colorHex
              : _defaultColorForId(matchedId),
          surahNumber: item.surahNumber,
          verseNumber: item.verseNumber,
          pageNumber: page,
          updatedAt:
              item.updatedAt ??
              (item.surahNumber != null ? DateTime.now() : null),
          isDefault: true,
        );
      } else {
        int? page = item.pageNumber;
        if (page == null &&
            item.surahNumber != null &&
            item.verseNumber != null) {
          page = _metadataService?.getPageNumber(
            item.surahNumber!,
            item.verseNumber!,
          );
        }
        customList.add(
          BookmarkModel(
            id: item.id,
            name: item.name,
            colorHex: item.colorHex,
            surahNumber: item.surahNumber,
            verseNumber: item.verseNumber,
            pageNumber: page,
            updatedAt: item.updatedAt,
            isDefault: item.isDefault,
          ),
        );
      }
    }

    final result = <BookmarkModel>[];
    for (final def in BookmarkItem.defaultSlots()) {
      if (map.containsKey(def.id)) {
        result.add(map[def.id]!);
      } else {
        result.add(BookmarkModel.fromEntity(def));
      }
    }

    result.addAll(customList);
    return result;
  }

  String _defaultNameForId(String id) {
    switch (id) {
      case BookmarkItem.defaultRedId:
        return 'الأحمر';
      case BookmarkItem.defaultYellowId:
        return 'الأصفر';
      case BookmarkItem.defaultGreenId:
        return 'الأخضر';
      case BookmarkItem.defaultBlueId:
        return 'الأزرق';
      default:
        return '';
    }
  }

  String _defaultColorForId(String id) {
    switch (id) {
      case BookmarkItem.defaultRedId:
        return '#C9484A';
      case BookmarkItem.defaultYellowId:
        return '#D7AC3C';
      case BookmarkItem.defaultGreenId:
        return '#62A77B';
      case BookmarkItem.defaultBlueId:
        return '#218FC9';
      default:
        return '#C9484A';
    }
  }
}
