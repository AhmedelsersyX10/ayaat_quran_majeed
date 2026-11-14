import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/get_translation_data.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/translation/translation_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final muyassarData = TranslationData(
    typeText: 'muyassar',
    typeTextInRelatedLanguage: 'التفسير الميسر',
    url: '',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.ar_muyassar,
  );

  final enSahihData = TranslationData(
    typeText: 'en_sahih',
    typeTextInRelatedLanguage: 'Saheeh International',
    url: '',
    typeInNativeLanguage: 'English',
    typeAsEnumValue: Translation.en_sahih,
  );

  group('getVerseTranslationForVerseByVerse & getVerseTranslation Tests', () {
    test('retrieves Al-Fatihah 1:1 for ar_muyassar in O(1)', () {
      final text = getVerseTranslationForVerseByVerse(null, 1, 1, muyassarData);
      expect(text, isNotEmpty);
      expect(text, contains('سورة الفاتحة'));
      expect(text, contains('الرحمة'));
    });

    test('retrieves Al-Fatihah 1:1 for en_sahih in O(1)', () {
      final text = getVerseTranslationForVerseByVerse(null, 1, 1, enSahihData);
      expect(text, isNotEmpty);
      expect(text.toLowerCase(), contains('in the name of allah'));
    });

    test('retrieves An-Nas 114:6 for ar_muyassar', () {
      final text = getVerseTranslationForVerseByVerse(
        null,
        114,
        6,
        muyassarData,
      );
      expect(text, isNotEmpty);
    });

    test('returns empty string for non-existent verse', () {
      final text = getVerseTranslationForVerseByVerse(
        null,
        1,
        999,
        muyassarData,
      );
      expect(text, equals(''));
    });

    test('replaces <br> tags with newline characters', () {
      final dynamicData = [
        {'sura': '2', 'aya': '1', 'text': 'Line 1<br>Line 2'},
      ];
      final customData = TranslationData(
        typeText: 'custom',
        typeTextInRelatedLanguage: 'Custom',
        url: '',
        typeInNativeLanguage: 'العربية',
        typeAsEnumValue: Translation.baghawy,
      );

      final text = getVerseTranslationForVerseByVerse(
        dynamicData,
        2,
        1,
        customData,
      );
      expect(text, equals('Line 1\nLine 2'));
    });

    test('appends verseEndSymbol when requested', () {
      final text = getVerseTranslationForVerseByVerse(
        null,
        1,
        1,
        muyassarData,
        verseEndSymbol: true,
      );
      expect(text, isNotEmpty);
      expect(text, contains('\u06dd1'));
    });

    test(
      'async getVerseTranslation resolves correctly for muyassar and en_sahih',
      () async {
        final muyassarText = await getVerseTranslation(1, 2, muyassarData);
        expect(muyassarText, isNotEmpty);
        expect(muyassarText, contains('الثناء على الله'));

        final enText = await getVerseTranslation(1, 2, enSahihData);
        expect(enText, isNotEmpty);
        expect(enText.toLowerCase(), contains('praise'));
      },
    );
  });
}
