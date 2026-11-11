import 'dart:convert';
import 'dart:ui';
import 'package:ayaat_quran_majeed/features/bookmarks/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookmarkModel Data Layer Tests', () {
    test(
      'Entity to Model and Model to Entity conversion preserves all values',
      () {
        final now = DateTime.now();
        final entity = BookmarkItem(
          id: 'yellow',
          name: 'الأصفر',
          colorHex: '#D7AC3C',
          surahNumber: 2,
          verseNumber: 142,
          pageNumber: 22,
          updatedAt: now,
          isDefault: true,
        );

        final model = BookmarkModel.fromEntity(entity);
        expect(model.id, equals(entity.id));
        expect(model.name, equals(entity.name));
        expect(model.colorHex, equals(entity.colorHex));
        expect(model.surahNumber, equals(entity.surahNumber));
        expect(model.verseNumber, equals(entity.verseNumber));
        expect(model.pageNumber, equals(entity.pageNumber));
        expect(model.updatedAt, equals(entity.updatedAt));
        expect(model.isDefault, equals(entity.isDefault));

        final restoredEntity = model.toEntity();
        expect(restoredEntity, equals(entity));
      },
    );

    test('Serialization to Map and JSON contains both new and legacy keys', () {
      final model = BookmarkModel(
        id: 'green',
        name: 'الأخضر',
        colorHex: '#62A77B',
        surahNumber: 3,
        verseNumber: 18,
        pageNumber: 52,
        isDefault: true,
      );

      final map = model.toMap();
      expect(map['id'], equals('green'));
      expect(map['name'], equals('الأخضر'));
      expect(map['colorHex'], equals('#62A77B'));
      expect(
        map['color'],
        equals('FF62A77B'),
      ); // legacy color string with FF alpha prefix
      expect(map['surahNumber'], equals(3));
      expect(map['suraNumber'], equals(3)); // legacy alias
      expect(map['verseNumber'], equals(18));
      expect(map['pageNumber'], equals(52));
      expect(map['isDefault'], isTrue);

      final jsonStr = model.toJson();
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      expect(decoded['id'], equals('green'));
      expect(decoded['suraNumber'], equals(3));
    });

    test('Deserializes legacy map correctly without failing', () {
      final legacyMap = {
        'name': 'علامة سابقة',
        'suraNumber': 18,
        'verseNumber': 10,
        'color': '218FC9',
      };

      final model = BookmarkModel.fromMap(legacyMap);
      expect(model.name, equals('علامة سابقة'));
      expect(model.surahNumber, equals(18));
      expect(model.suraNumber, equals(18));
      expect(model.verseNumber, equals(10));
      expect(model.colorHex, equals('#218FC9'));
      expect(model.color, equals('FF218FC9'));
      // Verify legacy caller pattern has non-zero (opaque) alpha channel
      final parsedColor = Color(int.parse("0x${model.color}"));
      expect(parsedColor.alpha, equals(255));
    });
  });
}
