import 'package:ayaat_quran_majeed/features/khatma/data/models/khatma_model.dart';
import 'package:ayaat_quran_majeed/features/khatma/data/models/khatma_wird_model.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma.dart';
import 'package:ayaat_quran_majeed/features/khatma/domain/entities/khatma_wird.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const metadataService = QuranMetadataService();

  group('Khatma Model Serialization & Re-enrichment Tests', () {
    final wird = KhatmaWird(
      dayNumber: 1,
      scheduledDate: DateTime(2026, 11, 10),
      startSurahNumber: 1,
      startAyahNumber: 1,
      endSurahNumber: 2,
      endAyahNumber: 141,
      startPageNumber: 1,
      endPageNumber: 21,
      startSurahName: 'الفاتحة',
      endSurahName: 'البقرة',
      firstVerseText: 'بِسْمِ ٱللَّهِ',
      lastVerseText: 'تِلْكَ أُمَّةٌ',
      rangeText: 'من الفاتحة إلى البقرة: ١٤١',
      isCompleted: true,
      completedAt: DateTime(2026, 11, 10, 15, 0),
    );

    final khatma = Khatma(
      id: 'khatma_12345',
      programId: 'meaning_29',
      programTitle: 'ختمة شهر (٢٩ يومًا)',
      totalDays: 29,
      startDate: DateTime(2026, 11, 10),
      wirds: [wird],
      reminderEnabled: true,
      reminderTimeHour: 19,
      reminderTimeMinute: 30,
      completedWirdsCount: 1,
      isCompleted: false,
      createdAt: DateTime(2026, 11, 10, 8, 0),
    );

    test('KhatmaWirdModel roundtrip serialization', () {
      final model = KhatmaWirdModel.fromEntity(wird);
      final map = model.toMap();
      final fromMap = KhatmaWirdModel.fromMap(map);
      final restored = fromMap.toEntity(metadataService);

      expect(restored.dayNumber, equals(wird.dayNumber));
      expect(restored.scheduledDate, equals(wird.scheduledDate));
      expect(restored.startSurahNumber, equals(wird.startSurahNumber));
      expect(restored.startAyahNumber, equals(wird.startAyahNumber));
      expect(restored.endSurahNumber, equals(wird.endSurahNumber));
      expect(restored.endAyahNumber, equals(wird.endAyahNumber));
      expect(restored.isCompleted, equals(wird.isCompleted));
      expect(restored.completedAt, equals(wird.completedAt));

      // Re-enriched fields from QuranMetadataService
      expect(restored.startPageNumber, equals(1));
      expect(restored.endPageNumber, equals(21));
      expect(restored.startSurahName, isNotEmpty);
      expect(restored.endSurahName, isNotEmpty);
      expect(restored.firstVerseText, isNotEmpty);
      expect(restored.lastVerseText, isNotEmpty);
    });

    test('KhatmaModel roundtrip serialization', () {
      final model = KhatmaModel.fromEntity(khatma);
      final map = model.toMap();
      final fromMap = KhatmaModel.fromMap(map);
      final restored = fromMap.toEntity(metadataService);

      expect(restored.id, equals(khatma.id));
      expect(restored.programId, equals(khatma.programId));
      expect(restored.programTitle, equals(khatma.programTitle));
      expect(restored.totalDays, equals(khatma.totalDays));
      expect(restored.startDate, equals(khatma.startDate));
      expect(restored.reminderEnabled, equals(khatma.reminderEnabled));
      expect(restored.reminderTimeHour, equals(khatma.reminderTimeHour));
      expect(restored.reminderTimeMinute, equals(khatma.reminderTimeMinute));
      expect(restored.completedWirdsCount, equals(khatma.completedWirdsCount));
      expect(restored.wirds.length, equals(1));
      expect(restored.wirds.first.dayNumber, equals(1));
    });
  });
}

