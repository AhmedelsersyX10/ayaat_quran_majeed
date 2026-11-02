import 'package:ayaat_quran_majeed/GlobalHelpers/arabic_text_helper.dart';
import 'package:ayaat_quran_majeed/quran/data/models/bookmark_model.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/convert_number_to_ar.dart';
import 'package:ayaat_quran_majeed/quran/data/utils/remove_html_tags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  group('Core Utilities & Normalization Tests', () {
    test('normalizeArabic standardizes hamzas, yaa, and taa marbuta', () {
      expect(normalizeArabic('أحمد'), equals('احمد'));
      expect(normalizeArabic('إبراهيم'), equals('ابراهيم'));
      expect(normalizeArabic('قرآن'), equals('قران'));
      expect(normalizeArabic('هدى'), equals('هدي'));
      expect(normalizeArabic('فاطمة'), equals('فاطمه'));
    });

    test('convertToArabicNumber converts western digits to eastern Arabic-Indic numerals', () {
      expect(convertToArabicNumber('0123456789'), equals('٠١٢٣٤٥٦٧٨٩'));
      expect(convertToArabicNumber('114'), equals('١١٤'));
      expect(convertToArabicNumber('604'), equals('٦٠٤'));
    });

    test('removeHtmlTags strips HTML formatting tags and keeps inner text', () {
      expect(removeHtmlTags('<p>تفسير الآية</p>'), equals('تفسير الآية'));
      expect(removeHtmlTags('<b>نص عريض</b><br/>سطر جديد'), equals('نص عريضسطر جديد'));
      expect(removeHtmlTags('نص عادي بدون وسوم'), equals('نص عادي بدون وسوم'));
    });
  });

  group('Domain Models & Contracts Tests', () {
    test('BookmarkModel serializes and deserializes correctly', () {
      final bookmark = BookmarkModel(
        suraNumber: 2,
        verseNumber: 255,
        name: 'آية الكرسي',
        color: '00FF00',
      );

      final map = bookmark.toMap();
      final restored = BookmarkModel.fromMap(map);

      expect(restored.suraNumber, equals(2));
      expect(restored.verseNumber, equals(255));
      expect(restored.name, equals('آية الكرسي'));
      expect(restored.color, equals('00FF00'));
      expect(restored, equals(bookmark));
    });

    test('ReadingPosition serializes and deserializes correctly', () {
      const position = ReadingPosition(
        page: 187,
        surahNumber: 9,
        ayahNumber: 1,
        viewMode: 'pageview',
      );

      final jsonString = position.toJson();
      final restored = ReadingPosition.fromJson(jsonString);

      expect(restored.page, equals(187));
      expect(restored.surahNumber, equals(9));
      expect(restored.ayahNumber, equals(1));
      expect(restored.viewMode, equals('pageview'));
    });
  });

  group('Quran Metadata Sanity Tests', () {
    test('Quran surahs count is exactly 114', () {
      expect(quran.totalSurahCount, equals(114));
    });

    test('Quran pages count is exactly 604', () {
      expect(quran.totalPagesCount, equals(604));
    });

    test('Al-Fatiha has 7 verses', () {
      expect(quran.getVerseCount(1), equals(7));
    });

    test('Al-Baqarah has 286 verses', () {
      expect(quran.getVerseCount(2), equals(286));
    });
  });
}
