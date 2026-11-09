import 'package:ayaat_quran_majeed/features/tafsir/data/models/tafsir_book_model.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/models/tafsir_catalog.dart';
import 'package:ayaat_quran_majeed/features/tafsir/data/models/tafsir_verse_model.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_book.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_category.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_source_attribution.dart';
import 'package:ayaat_quran_majeed/features/tafsir/domain/entities/tafsir_verse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tafsir Domain Entities & Models Tests', () {
    const attribution = TafsirSourceAttribution(
      provider: 'مجمع الملك فهد',
      sourceProject: 'مشروع آيات',
      sourceUrl: 'https://quran.ksu.edu.sa',
      licenseNotes: 'استخدام غير تجاري',
    );

    test('TafsirSourceAttribution value equality and properties', () {
      const attr2 = TafsirSourceAttribution(
        provider: 'مجمع الملك فهد',
        sourceProject: 'مشروع آيات',
        sourceUrl: 'https://quran.ksu.edu.sa',
        licenseNotes: 'استخدام غير تجاري',
      );

      expect(attribution, equals(attr2));
      expect(attribution.hashCode, equals(attr2.hashCode));
      expect(attribution.provider, 'مجمع الملك فهد');
    });

    test('TafsirBook copyWith and value equality', () {
      const book = TafsirBook(
        id: 'ar_muyassar',
        name: 'التفسير الميسر',
        author: 'مجمع الملك فهد',
        description: 'تفسير ميسر',
        language: 'ar',
        languageName: 'العربية',
        category: TafsirCategory.arabicTafsir,
        isBundled: true,
        isDownloaded: true,
        downloadUrl: 'https://example.com/muyassar.json',
        approximateSizeBytes: 3000000,
        attribution: attribution,
      );

      final downloadedCopy = book.copyWith(isDownloaded: false);
      expect(downloadedCopy.isDownloaded, isFalse);
      expect(downloadedCopy.id, equals(book.id));
      expect(book, equals(book));
      expect(book.hashCode, equals(book.hashCode));
    });

    test('TafsirVerse entity value equality', () {
      const verse1 = TafsirVerse(
        surahNumber: 1,
        ayahNumber: 1,
        text: 'بسم الله الرحمن الرحيم',
        bookId: 'ar_muyassar',
      );
      const verse2 = TafsirVerse(
        surahNumber: 1,
        ayahNumber: 1,
        text: 'بسم الله الرحمن الرحيم',
        bookId: 'ar_muyassar',
      );

      expect(verse1, equals(verse2));
      expect(verse1.hashCode, equals(verse2.hashCode));
    });

    test('TafsirVerseModel cleans HTML tags and converts <br> to newlines', () {
      final jsonMap = {
        'id': '1',
        'sura': '2',
        'aya': '255',
        'text': '<p>{اللَّهُ لَا إِلَهَ إِلَّا هُوَ}<br/>الله الذي لا يستحق الألوهية غيره.</p>',
      };

      final model = TafsirVerseModel.fromJson(jsonMap);
      expect(model.id, equals(1));
      expect(model.surahNumber, equals(2));
      expect(model.ayahNumber, equals(255));
      expect(model.text, equals('{اللَّهُ لَا إِلَهَ إِلَّا هُوَ}\nالله الذي لا يستحق الألوهية غيره.'));

      final entity = model.toEntity(bookId: 'sa3dy');
      expect(entity.bookId, equals('sa3dy'));
      expect(entity.surahNumber, equals(2));
      expect(entity.ayahNumber, equals(255));
      expect(entity.text, equals(model.text));

      final serialized = model.toJson();
      expect(serialized['id'], equals(1));
      expect(serialized['sura'], equals(2));
      expect(serialized['aya'], equals(255));
    });

    test('TafsirBookModel roundtrip serialization', () {
      const model = TafsirBookModel(
        id: 'sa3dy',
        name: 'تفسير السعدي',
        author: 'ابن سعدي',
        description: 'تيسير الكريم الرحمن',
        language: 'ar',
        languageName: 'العربية',
        category: TafsirCategory.arabicTafsir,
        isBundled: false,
        downloadUrl: 'https://example.com/sa3dy.json',
        approximateSizeBytes: 6750000,
        attribution: attribution,
      );

      final jsonMap = model.toJson();
      final fromJson = TafsirBookModel.fromJson(jsonMap);

      expect(fromJson.id, equals(model.id));
      expect(fromJson.name, equals(model.name));
      expect(fromJson.category, equals(model.category));
      expect(fromJson.isBundled, equals(model.isBundled));
      expect(fromJson.attribution, equals(model.attribution));

      final entity = model.toEntity(isDownloaded: true);
      expect(entity.isDownloaded, isTrue);
      expect(entity.id, equals('sa3dy'));
    });
  });

  group('TafsirCatalog Integrity & Invariant Constraints Tests', () {
    test('catalog contains exactly 38 verified books', () {
      expect(TafsirCatalog.books.length, equals(38));
    });

    test('default book is Al-Tafsir Al-Muyassar and is bundled', () {
      expect(TafsirCatalog.defaultBookId, equals('ar_muyassar'));
      final defaultBook = TafsirCatalog.findById('ar_muyassar');
      expect(defaultBook, isNotNull);
      expect(defaultBook!.isBundled, isTrue);
      expect(defaultBook.category, equals(TafsirCategory.arabicTafsir));
      expect(defaultBook.name, equals('التفسير الميسر'));
    });

    test('English Sahih International is bundled', () {
      final sahih = TafsirCatalog.findById('en_sahih');
      expect(sahih, isNotNull);
      expect(sahih!.isBundled, isTrue);
      expect(sahih.category, equals(TafsirCategory.englishTranslation));
    });

    test('strictly excludes ar_ma3any (word meanings), audio tafsir, and Al-Mukhtasar', () {
      expect(TafsirCatalog.findById('ar_ma3any'), isNull);
      expect(TafsirCatalog.findById('mukhtasar'), isNull);
      expect(TafsirCatalog.findById('al_mukhtasar'), isNull);
      expect(TafsirCatalog.findById('audio_tafsir'), isNull);
    });

    test('all non-bundled books have valid remote download URLs', () {
      for (final book in TafsirCatalog.books) {
        if (!book.isBundled) {
          expect(book.downloadUrl, isNotNull);
          expect(
            book.downloadUrl!.startsWith('https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/'),
            isTrue,
            reason: '${book.id} must point to verified noureddin/Quran-App-Data repository',
          );
        }
      }
    });

    test('es_navio and ms_basmeih URLs are correctly fixed to their respective files', () {
      final esNavio = TafsirCatalog.findById('es_navio');
      expect(esNavio, isNotNull);
      expect(esNavio!.downloadUrl, endsWith('/es_navio.json'));

      final msBasmeih = TafsirCatalog.findById('ms_basmeih');
      expect(msBasmeih, isNotNull);
      expect(msBasmeih!.downloadUrl, endsWith('/ms_basmeih.json'));
    });
  });
}

