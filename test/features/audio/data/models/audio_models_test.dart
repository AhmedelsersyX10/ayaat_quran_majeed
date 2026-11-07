import 'package:ayaat_quran_majeed/features/audio/data/models/ayah_timing_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/moshaf_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/reciter_model.dart';
import 'package:ayaat_quran_majeed/features/audio/data/models/timing_read_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AyahTimingModel Tests', () {
    test('fromJson and toJson roundtrip correctly', () {
      final json = {
        'ayah': 1,
        'start_time': 0,
        'end_time': 13189,
      };

      final model = AyahTimingModel.fromJson(json);
      expect(model.ayah, equals(1));
      expect(model.startTime, equals(0));
      expect(model.endTime, equals(13189));

      final serialized = model.toJson();
      expect(serialized['ayah'], equals(1));
      expect(serialized['start_time'], equals(0));
      expect(serialized['end_time'], equals(13189));
    });

    test('parses numeric strings safely', () {
      final json = {
        'ayah': '2',
        'start_time': '13189',
        'end_time': '25000',
      };

      final model = AyahTimingModel.fromJson(json);
      expect(model.ayah, equals(2));
      expect(model.startTime, equals(13189));
      expect(model.endTime, equals(25000));
    });

    test('toEntity maps fields accurately', () {
      const model = AyahTimingModel(ayah: 7, startTime: 5000, endTime: 9000);
      final entity = model.toEntity();

      expect(entity.ayah, equals(7));
      expect(entity.startTimeMs, equals(5000));
      expect(entity.endTimeMs, equals(9000));
    });
  });

  group('TimingReadModel Tests', () {
    test('fromJson parses API response format correctly', () {
      final json = {
        'id': 1,
        'name': 'إبراهيم الأخضر',
        'rewaya': 'حفص عن عاصم',
        'folder_url': 'https://cdn.mp3quran.net/audio/akdr/r1/',
        'soar_count': 114,
        'soar_link': 'https://www.mp3quran.net/api/v3/ayat_timing/soar?read=1',
      };

      final model = TimingReadModel.fromJson(json);
      expect(model.id, equals(1));
      expect(model.name, equals('إبراهيم الأخضر'));
      expect(model.rewaya, equals('حفص عن عاصم'));
      expect(model.folderUrl, equals('https://cdn.mp3quran.net/audio/akdr/r1/'));
      expect(model.soarCount, equals(114));
    });
  });

  group('MoshafModel Tests', () {
    test('fromJson parses comma-separated surah_list into integers', () {
      final json = {
        'id': 1,
        'name': 'حفص عن عاصم - مرتل',
        'server': 'https://cdn.mp3quran.net/audio/akdr/r1/',
        'surah_total': 114,
        'moshaf_type': 11,
        'surah_list': '1, 2, 3, 114',
      };

      final model = MoshafModel.fromJson(json);
      expect(model.id, equals(1));
      expect(model.name, equals('حفص عن عاصم - مرتل'));
      expect(model.server, equals('https://cdn.mp3quran.net/audio/akdr/r1/'));
      expect(model.surahTotal, equals(114));
      expect(model.moshafType, equals(11));
      expect(model.surahList, equals([1, 2, 3, 114]));
    });

    test('toEntity accurately assigns hasTiming according to flag', () {
      const model = MoshafModel(
        id: 5,
        name: 'ورش',
        server: 'https://server.com/',
        surahTotal: 114,
        moshafType: 1,
        surahList: [1, 2],
      );

      final entityWithoutTiming = model.toEntity(hasTiming: false);
      expect(entityWithoutTiming.hasTiming, isFalse);

      final entityWithTiming = model.toEntity(hasTiming: true);
      expect(entityWithTiming.hasTiming, isTrue);
    });
  });

  group('ReciterModel Tests', () {
    test('fromJson excludes audio-tafsir / المختصر الصوتي editions', () {
      final json = {
        'id': 100,
        'name': 'القارئ التجريبي',
        'letter': 'ق',
        'moshaf': [
          {
            'id': 1,
            'name': 'حفص عن عاصم - مرتل',
            'server': 'https://server.com/hafs/',
            'surah_total': 114,
            'moshaf_type': 1,
            'surah_list': '1,2',
          },
          {
            'id': 2,
            'name': 'المختصر الصوتي لتفسير القرآن الكريم',
            'server': 'https://server.com/tafsir/',
            'surah_total': 114,
            'moshaf_type': 99,
            'surah_list': '1,2',
          },
          {
            'id': 3,
            'name': 'مختصر تفسير سورة البقرة',
            'server': 'https://server.com/tafsir2/',
            'surah_total': 1,
            'moshaf_type': 99,
            'surah_list': '2',
          },
        ],
      };

      final model = ReciterModel.fromJson(json);
      expect(model.id, equals(100));
      expect(model.name, equals('القارئ التجريبي'));
      // Only the non-tafsir moshaf must remain
      expect(model.moshafs.length, equals(1));
      expect(model.moshafs.first.name, equals('حفص عن عاصم - مرتل'));
    });

    test('toEntity enriches moshafs with verified timingSupportedMoshafIds', () {
      final json = {
        'id': 1,
        'name': 'محمود خليل الحصري',
        'letter': 'م',
        'moshaf': [
          {
            'id': 118,
            'name': 'حفص مرتل',
            'server': 'https://server.com/',
            'surah_total': 114,
            'moshaf_type': 1,
            'surah_list': '1,2',
          },
          {
            'id': 999,
            'name': 'رواية نادرة',
            'server': 'https://server.com/',
            'surah_total': 114,
            'moshaf_type': 2,
            'surah_list': '1,2',
          },
        ],
      };

      final model = ReciterModel.fromJson(json);
      final entity = model.toEntity(timingSupportedMoshafIds: {118});

      expect(entity.moshafs[0].hasTiming, isTrue);
      expect(entity.moshafs[1].hasTiming, isFalse);
    });
  });
}
