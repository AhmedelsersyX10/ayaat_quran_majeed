import 'package:ayaat_quran_majeed/features/settings/domain/entities/app_settings.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings Entity', () {
    test('defaults to expected Quran reading settings', () {
      const settings = AppSettings();

      expect(settings.keepScreenAwake, isTrue);
      expect(settings.hijriOffset, 0);
      expect(settings.mushafFontSize, 23.0);
      expect(settings.isMushafTextSizingSupported, isFalse);
    });

    test('copyWith creates modified copy correctly', () {
      const original = AppSettings();
      final modified = original.copyWith(
        keepScreenAwake: false,
        hijriOffset: 1,
        mushafFontSize: 28.0,
        isMushafTextSizingSupported: true,
      );

      expect(modified.keepScreenAwake, isFalse);
      expect(modified.hijriOffset, 1);
      expect(modified.mushafFontSize, 28.0);
      expect(modified.isMushafTextSizingSupported, isTrue);

      // Verify original remains unchanged
      expect(original.keepScreenAwake, isTrue);
      expect(original.hijriOffset, 0);
    });

    test('value equality and hashCode behave consistently', () {
      const settings1 = AppSettings(
        keepScreenAwake: true,
        hijriOffset: -1,
        mushafFontSize: 25.0,
      );
      const settings2 = AppSettings(
        keepScreenAwake: true,
        hijriOffset: -1,
        mushafFontSize: 25.0,
      );
      const settings3 = AppSettings(
        keepScreenAwake: false,
        hijriOffset: -1,
        mushafFontSize: 25.0,
      );

      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));
      expect(settings1, isNot(equals(settings3)));
      expect(settings1.toString(), contains('keepScreenAwake: true'));
    });
  });

  group('ContentSource Entity', () {
    test('instantiates with all fields and supports equality', () {
      const source1 = ContentSource(
        title: 'Title',
        provider: 'Provider',
        description: 'Description',
        category: ContentSourceCategory.quranEngine,
        url: 'https://example.com',
      );
      const source2 = ContentSource(
        title: 'Title',
        provider: 'Provider',
        description: 'Description',
        category: ContentSourceCategory.quranEngine,
        url: 'https://example.com',
      );
      const source3 = ContentSource(
        title: 'Other',
        provider: 'Provider',
        description: 'Description',
        category: ContentSourceCategory.tafsir,
      );

      expect(source1, equals(source2));
      expect(source1.hashCode, equals(source2.hashCode));
      expect(source1, isNot(equals(source3)));
      expect(source1.toString(), contains('Title'));
    });
  });
}
