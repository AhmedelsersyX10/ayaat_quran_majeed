import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/storage/app_preferences.dart';
import 'package:ayaat_quran_majeed/features/today/data/services/umm_al_qura_date_service.dart';
import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';

/// Implementation of [TodayRepository] providing offline deterministic Ayah selection
/// based on the local civil date and Umm al-Qura calendar conversions.
class TodayRepositoryImpl implements TodayRepository {
  final QuranMetadataService _metadataService;
  final UmmAlQuraDateService _dateService;
  final AppPreferences _preferences;

  const TodayRepositoryImpl({
    required QuranMetadataService metadataService,
    required UmmAlQuraDateService dateService,
    required AppPreferences preferences,
  }) : _metadataService = metadataService,
       _dateService = dateService,
       _preferences = preferences;

  @override
  Future<TodayAyah> getTodayAyah({DateTime? forDate}) async {
    final civilDate = forDate ?? DateTime.now();

    // 1. Verify Quran metadata availability
    final allVerses = _metadataService.allVersesRawData;
    if (allVerses.isEmpty) {
      throw const GeneralFailure(AppStrings.todayLoadFailed);
    }

    // 2. Compute UTC civil-day ordinal from local year/month/day
    final utcCivil = DateTime.utc(
      civilDate.year,
      civilDate.month,
      civilDate.day,
    );
    final epochDays = utcCivil.difference(DateTime.utc(1970, 1, 1)).inDays;

    // 3. Modulo the verified 6236 ordered qcf Quran verses (safe wrap)
    final totalVerses = allVerses.length;
    final verseIndex = ((epochDays % totalVerses) + totalVerses) % totalVerses;
    final verseData = allVerses[verseIndex];

    final surahNumber = verseData['sora'] as int?;
    final ayahNumber = verseData['aya_no'] as int?;

    if (surahNumber == null || ayahNumber == null) {
      throw const GeneralFailure(AppStrings.todayLoadFailed);
    }

    // 4. Retrieve verse text, end symbol, page number, and surah name
    final ayahText = _metadataService.getVerse(
      surahNumber,
      ayahNumber,
      verseEndSymbol: false,
    );
    final ayahEndSymbol = _metadataService.getVerseEndSymbol(ayahNumber);
    final pageNumber = _metadataService.getPageNumber(surahNumber, ayahNumber);
    final surahName = _metadataService.getSurahNameArabic(surahNumber);

    if (ayahText.isEmpty) {
      throw const GeneralFailure(AppStrings.todayLoadFailed);
    }

    // 5. Date conversions with user-configured Hijri offset
    final offset = _preferences.hijriOffset;
    final hijri = _dateService.getHijriDate(civilDate, hijriOffset: offset);
    final gregorian = _dateService.getGregorianDate(civilDate);

    return TodayAyah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      ayahEndSymbol: ayahEndSymbol,
      pageNumber: pageNumber,
      surahNameArabic: surahName,
      hijriDay: hijri.dayArabic,
      hijriMonthName: hijri.monthArabic,
      gregorianDay: gregorian.dayArabic,
      gregorianMonthName: gregorian.monthArabic,
      localDate: DateTime(civilDate.year, civilDate.month, civilDate.day),
    );
  }
}
