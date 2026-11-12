import 'package:ayaat_quran_majeed/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/app_settings.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/repositories/settings_repository.dart';

/// Implementation of [SettingsRepository] coordinating local preferences
/// and static source attributions.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  const SettingsRepositoryImpl({
    required SettingsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  AppSettings getSettings() {
    return AppSettings(
      keepScreenAwake: _localDataSource.getKeepScreenAwake(),
      hijriOffset: _localDataSource.getHijriOffset(),
      mushafFontSize: _localDataSource.getMushafFontSize(),
      isMushafTextSizingSupported: false,
    );
  }

  @override
  Future<void> setKeepScreenAwake(bool value) =>
      _localDataSource.setKeepScreenAwake(value);

  @override
  Future<void> setHijriOffset(int offset) =>
      _localDataSource.setHijriOffset(offset);

  @override
  Future<void> setMushafFontSize(double fontSize) =>
      _localDataSource.setMushafFontSize(fontSize);

  @override
  List<ContentSource> getSourcesAndAttributions() {
    return const [
      ContentSource(
        title: 'محرك المصحف والخطوط',
        provider: 'مجمع الملك فهد لطباعة المصحف الشريف بالمدينة المنورة',
        description:
            'خطوط الرسم العثماني حفص (QCF v2) عالية الدقة عبر حزمة qcf_quran_plus 0.1.1.',
        category: ContentSourceCategory.quranEngine,
        url: 'https://qurancomplex.gov.sa/',
      ),
      ContentSource(
        title: 'التفسير الميسر',
        provider: 'مجمع الملك فهد لطباعة المصحف الشريف',
        description:
            'تفسير نخبة من العلماء بإشراف وزارة الشؤون الإسلامية والدعوة والإرشاد بالمملكة العربية السعودية.',
        category: ContentSourceCategory.tafsir,
        url: 'https://qurancomplex.gov.sa/',
      ),
      ContentSource(
        title: 'الترجمة الإنجليزية للمعاني',
        provider: 'صحيح إنترناشونال (Saheeh International)',
        description: 'ترجمة معتمدة لمعاني القرآن الكريم باللغة الإنجليزية.',
        category: ContentSourceCategory.tafsir,
      ),
      ContentSource(
        title: 'بيانات وتفاسير المكتبة الإلكترونية',
        provider: 'مستودع noureddin/Quran-App-Data',
        description:
            'ملفات تفاسير وترجمات رقمية مفتوحة المصدر للاستخدام غير الربحي.',
        category: ContentSourceCategory.openSource,
        url: 'https://github.com/noureddin/Quran-App-Data',
      ),
      ContentSource(
        title: 'التلاوات الصوتية وتوقيت الآيات',
        provider: 'شبكة MP3Quran.net',
        description:
            'تسجيلات المصحف المرتل لكبار القراء مع بيانات توقيت الآيات لمتابعة التلاوة.',
        category: ContentSourceCategory.audio,
        url: 'https://mp3quran.net/',
      ),
      ContentSource(
        title: 'التقويم الهجري',
        provider: 'تقويم أم القرى',
        description:
            'الحساب الفلكي المعتمد في المملكة العربية السعودية مع إمكانية الضبط اليدوي (±١ يوم).',
        category: ContentSourceCategory.calendar,
      ),
      ContentSource(
        title: 'تراخيص البرمجيات مفتوحة المصدر',
        provider: 'Flutter & Open Source Community',
        description:
            'مكتبات وأدوات برمجية منشورة بموجب رخص مفتوحة المصدر (MIT, BSD, Apache 2.0).',
        category: ContentSourceCategory.openSource,
      ),
    ];
  }
}
