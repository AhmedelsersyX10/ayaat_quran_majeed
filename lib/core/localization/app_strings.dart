import 'package:easy_localization/easy_localization.dart' as ez;

/// Semantic translation keys for the entire application.
///
/// Guarantees compile-time safety and prevents typos in translation lookup.
/// Use with [AppStrings.tr] or `.tr()` from `easy_localization`.
abstract class AppStrings {
  // General & Common Actions
  static const String appName = 'app_name';
  static const String retry = 'retry';
  static const String cancel = 'cancel';
  static const String close = 'close';
  static const String save = 'save';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String confirm = 'confirm';
  static const String done = 'done';
  static const String add = 'add';
  static const String share = 'share';
  static const String copy = 'copy';
  static const String copiedSuccess = 'copied_success';
  static const String error = 'error';
  static const String loading = 'loading';
  static const String reset = 'reset';
  static const String selected = 'selected';
  static const String ok = 'ok';

  // Bottom Navigation (Screens 03, 10, 11, 12, 13, 26, 27, 28, 30, 31)
  static const String navSurahs = 'nav_surahs';
  static const String navKhatma = 'nav_khatma';
  static const String navBookmarks = 'nav_bookmarks';
  static const String navStarred = 'nav_starred';
  static const String navNotes = 'nav_notes';

  // Index & Quran Reader (Screens 01-05)
  static const String indexTitle = 'index_title';
  static const String tabSurahs = 'tab_surahs';
  static const String tabQuarters = 'tab_quarters';
  static const String indexLoadFailed = 'index_load_failed';
  static const String emptyIndex = 'empty_index';
  static const String searchQuranHint = 'search_quran_hint';
  static const String page = 'page';
  static const String surah = 'surah';
  static const String juz = 'juz';
  static const String hizb = 'hizb';
  static const String quarter = 'quarter';
  static const String ayah = 'ayah';
  static const String ayahs = 'ayahs';
  static const String makki = 'makki';
  static const String madani = 'madani';
  static const String lastRead = 'last_read';
  static const String alQuran = 'al_quran';
  static const String alJuz = 'al_juz';
  static const String alPage = 'al_page';

  // Khatma (Screens 06-10, 14, 23, 24, 25, 26, 31, 32, 33, 35)
  static const String khatmaTitle = 'khatma_title';
  static const String newKhatma = 'new_khatma';
  static const String suggestedKhatma = 'suggested_khatma';
  static const String otherKhatma = 'other_khatma';
  static const String startFrom = 'start_from';
  static const String fromBeginning = 'from_beginning';
  static const String fromSurah = 'from_surah';
  static const String dailyWird = 'daily_wird';
  static const String wirdOfToday = 'wird_of_today';
  static const String programPicker = 'program_picker';
  static const String allWirds = 'all_wirds';
  static const String deleteKhatma = 'delete_khatma';
  static const String reminder = 'reminder';
  static const String dailyWirdReminder = 'daily_wird_reminder';
  static const String completedWird = 'completed_wird';
  static const String congratulationsWird = 'congratulations_wird';
  static const String emptyKhatmaTitle = 'empty_khatma_title';
  static const String emptyKhatmaDesc = 'empty_khatma_desc';
  static const String khatmaGuidanceDesc = 'khatma_guidance_desc';
  static const String startKhatmaBtn = 'start_khatma_btn';
  static const String reminderTimePickerTitle = 'reminder_time_picker_title';
  static const String amPeriod = 'am_period';
  static const String pmPeriod = 'pm_period';
  static const String monthsCategory = 'months_category';
  static const String otherCategory = 'other_category';
  static const String afterTwoDays = 'after_two_days';
  static const String today = 'today';
  static const String yesterday = 'yesterday';
  static const String tomorrow = 'tomorrow';

  // Bookmarks (Screens 11, 27)
  static const String bookmarksTitle = 'bookmarks_title';
  static const String emptyBookmarksTitle = 'empty_bookmarks_title';
  static const String emptyBookmarksDesc = 'empty_bookmarks_desc';
  static const String editBookmarks = 'edit_bookmarks';
  static const String anotherBookmark = 'another_bookmark';
  static const String newBookmark = 'new_bookmark';
  static const String bookmarkName = 'bookmark_name';
  static const String bookmarkSaved = 'bookmark_saved';
  static const String bookmarkDeleted = 'bookmark_deleted';
  static const String colorRed = 'color_red';
  static const String colorYellow = 'color_yellow';
  static const String colorGreen = 'color_green';
  static const String colorBlue = 'color_blue';

  // Starred Verses (Screens 12, 28)
  static const String starredTitle = 'starred_title';
  static const String emptyStarredTitle = 'empty_starred_title';
  static const String emptyStarredDesc = 'empty_starred_desc';

  // Notes (Screens 13, 29, 30)
  static const String notesTitle = 'notes_title';
  static const String emptyNotesTitle = 'empty_notes_title';
  static const String emptyNotesDesc = 'empty_notes_desc';
  static const String addNote = 'add_note';
  static const String editNote = 'edit_note';
  static const String noteHint = 'note_hint';
  static const String shareNote = 'share_note';
  static const String noteSaved = 'note_saved';
  static const String noteDeleted = 'note_deleted';

  // Ayah Options & Recitation Settings (Screens 19, 20, 22, 38, 39, 40)
  static const String ayahOptions = 'ayah_options';
  static const String redBookmark = 'red_bookmark';
  static const String recitation = 'recitation';
  static const String library = 'library';
  static const String librarySubtitle = 'library_subtitle';
  static const String tafsir = 'tafsir';
  static const String play = 'play';
  static const String pause = 'pause';
  static const String saveBookmark = 'save_bookmark';
  static const String starAyah = 'star_ayah';
  static const String addNoteAction = 'add_note_action';
  static const String recitationSettings = 'recitation_settings';
  static const String recitationRange = 'recitation_range';
  static const String repeatSection = 'repeat_section';
  static const String repeatRange = 'repeat_range';
  static const String repeatAyah = 'repeat_ayah';
  static const String repeatCount = 'repeat_count';
  static const String fromAyah = 'from_ayah';
  static const String toAyah = 'to_ayah';
  static const String selectAyah = 'select_ayah';
  static const String playTo = 'play_to';
  static const String endOfSurah = 'end_of_surah';
  static const String endOfPage = 'end_of_page';
  static const String endOfJuz = 'end_of_juz';
  static const String customAyah = 'custom_ayah';
  static const String stopAfter = 'stop_after';

  // Reciters & Surah Downloads (Screens 18, 36)
  static const String recitersTitle = 'reciters_title';
  static const String searchReciter = 'search_reciter';
  static const String allReciters = 'all_reciters';
  static const String downloadSurah = 'download_surah';
  static const String downloadedSurah = 'downloaded_surah';
  static const String reciterNotFound = 'reciter_not_found';
  static const String playbackError = 'playback_error';
  static const String playbackStopped = 'playback_stopped';

  // Tafsir & Library (Screens 17, 34)
  static const String muyassarTafsir = 'muyassar_tafsir';
  static const String libraryEditTitle = 'library_edit_title';
  static const String myLibrary = 'my_library';
  static const String availableBooks = 'available_books';
  static const String tafasirCategory = 'tafasir_category';
  static const String translationsCategory = 'translations_category';

  // Today Sheet (Screen 16)
  static const String todayTitle = 'today_title';
  static const String todayAyah = 'today_ayah';
  static const String hijriCalendar = 'hijri_calendar';
  static const String gregorianCalendar = 'gregorian_calendar';
  static const String todayLoadFailed = 'today_load_failed';

  // Search (Screens 15, 21)
  static const String searchHint = 'search_hint';
  static const String searchVersesHeader = 'search_verses_header';
  static const String goToPage = 'go_to_page';
  static const String searchResults = 'search_results';
  static const String noSearchResults = 'no_search_results';

  // Settings & Routing
  static const String settings = 'settings';
  static const String theme = 'theme';
  static const String pageNotFound = 'page_not_found';
  static const String returnHome = 'return_home';
  static const String networkError = 'network_error';
  static const String cacheError = 'cache_error';
  static const String serverError = 'server_error';

  /// In-memory Arabic fallback dictionary guaranteeing instant, testable
  /// translations even when the EasyLocalization widget tree is not pumped.
  static const Map<String, String> arabicTranslations = {
    appName: 'آيات',
    retry: 'أعد المحاولة',
    cancel: 'إلغاء',
    close: 'إغلاق',
    save: 'حفظ',
    edit: 'تعديل',
    delete: 'حذف',
    confirm: 'تأكيد',
    done: 'تم',
    add: 'إضافة',
    share: 'مشاركة',
    copy: 'نسخ',
    copiedSuccess: 'تم النسخ بنجاح',
    error: 'خطأ',
    loading: 'جارٍ التحميل...',
    reset: 'إعادة ضبط',
    selected: 'تم الاختيار',
    ok: 'حسنًا',
    navSurahs: 'السور',
    navKhatma: 'الختمة',
    navBookmarks: 'الفواصل',
    navStarred: 'مميزة بنجمة',
    navNotes: 'الملاحظات',
    indexTitle: 'الفهرس',
    tabSurahs: 'السور',
    tabQuarters: 'الأرباع',
    indexLoadFailed: 'تعذر تحميل الفهرس',
    emptyIndex: 'لا توجد بيانات للفهرس',
    searchQuranHint: 'ابحث عن سورة أو آية أو صفحة',
    page: 'صفحة',
    surah: 'سورة',
    juz: 'جزء',
    hizb: 'حزب',
    quarter: 'ربع',
    ayah: 'آية',
    ayahs: 'آياتها',
    makki: 'مكية',
    madani: 'مدنية',
    lastRead: 'آخر ما تم قراءته',
    alQuran: 'القرآن الكريم',
    alJuz: 'الجزء',
    alPage: 'الصفحة',
    khatmaTitle: 'الختمة',
    newKhatma: 'ختمة جديدة',
    suggestedKhatma: 'مقترحة',
    otherKhatma: 'أخرى',
    startFrom: 'بدء الختمة من',
    fromBeginning: 'البداية',
    fromSurah: 'سورة معينة',
    dailyWird: 'الورد اليومي',
    wirdOfToday: 'ورد اليوم',
    programPicker: 'برنامج الختمة',
    allWirds: 'جميع الأوراد',
    deleteKhatma: 'حذف الختمة',
    reminder: 'تذكير',
    dailyWirdReminder: 'تنبيه الورد',
    completedWird: 'أكملت هذا الورد',
    congratulationsWird: 'تهانينا! لقد أتممت ورد اليوم',
    emptyKhatmaTitle: 'لا توجد ختمة نشطة',
    emptyKhatmaDesc:
        'ابدأ ختمة جديدة لقراءة القرآن الكريم بانتظام ومتابعة تقدمك',
    khatmaGuidanceDesc:
        'حدّد وردك اليومي أو المدة التي تريد ختم القرآن فيها، وتابع ختمتك في شهر رمضان وطوال العام.',
    startKhatmaBtn: 'بدء ختمة جديدة',
    reminderTimePickerTitle: 'وقت التنبيه',
    amPeriod: 'ص',
    pmPeriod: 'م',
    monthsCategory: 'الأشهر',
    otherCategory: 'أخرى',
    afterTwoDays: 'بعد يومين',
    today: 'اليوم',
    yesterday: 'أمس',
    tomorrow: 'غداً',
    bookmarksTitle: 'الفواصل',
    emptyBookmarksTitle: 'لا توجد فواصل',
    emptyBookmarksDesc: 'أضف فواصل أثناء القراءة للرجوع إليها سريعاً في أي وقت',
    editBookmarks: 'تحرير',
    anotherBookmark: 'فاصل آخر...',
    newBookmark: 'إضافة علامة مرجعية',
    bookmarkName: 'اسم العلامة المرجعية',
    bookmarkSaved: 'تم حفظ العلامة المرجعية',
    bookmarkDeleted: 'تم حذف العلامة المرجعية',
    colorRed: 'الأحمر',
    colorYellow: 'الأصفر',
    colorGreen: 'الأخضر',
    colorBlue: 'الأزرق',
    starredTitle: 'مميزة بنجمة',
    emptyStarredTitle: 'لا توجد آيات مميزة بنجمة',
    emptyStarredDesc: 'اضغط مطولاً على أي آية لإضافتها إلى قائمتك المفضلة',
    notesTitle: 'الملاحظات',
    emptyNotesTitle: 'لا توجد ملاحظات',
    emptyNotesDesc: 'يمكنك تدوين خواطرك وتأملاتك وتفسير الآيات أثناء التلاوة',
    addNote: 'إضافة ملاحظة',
    editNote: 'تعديل الملاحظة',
    noteHint: 'اكتب ملاحظتك وتدبراتك هنا...',
    shareNote: 'مشاركة الملاحظة',
    noteSaved: 'تم حفظ الملاحظة',
    noteDeleted: 'تم حذف الملاحظة',
    ayahOptions: 'خيارات الآية',
    redBookmark: 'الفاصل الأحمر',
    recitation: 'تلاوة',
    library: 'المكتبة',
    librarySubtitle: 'التفسير ومعاني الكلمات',
    tafsir: 'التفسير',
    play: 'تشغيل',
    pause: 'إيقاف مؤقت',
    saveBookmark: 'حفظ كعلامة',
    starAyah: 'تمييز بنجمة',
    addNoteAction: 'ملاحظة',
    recitationSettings: 'إعدادات التلاوة',
    recitationRange: 'نطاق التلاوة',
    repeatSection: 'التكرار',
    repeatRange: 'تكرار النطاق',
    repeatAyah: 'تكرار الآية',
    repeatCount: 'عدد المرات',
    fromAyah: 'من',
    toAyah: 'إلى',
    selectAyah: 'اختيار الآية',
    playTo: 'تشغيل إلى...',
    endOfSurah: 'نهاية السورة',
    endOfPage: 'نهاية الصفحة',
    endOfJuz: 'نهاية الجزء',
    customAyah: 'آية معينة',
    stopAfter: 'توقف بعد',
    recitersTitle: 'القراء',
    searchReciter: 'ابحث عن قارئ',
    allReciters: 'جميع القراء',
    downloadSurah: 'تحميل السورة',
    downloadedSurah: 'تم التحميل',
    reciterNotFound: 'لم يتم العثور على القارئ',
    playbackError: 'خطأ في التشغيل',
    playbackStopped: 'تم إيقاف التشغيل',
    muyassarTafsir: 'التفسير الميسر',
    libraryEditTitle: 'تحرير المكتبة',
    myLibrary: 'مكتبتي',
    availableBooks: 'الكتب المتاحة',
    tafasirCategory: 'التفاسير',
    translationsCategory: 'التراجم',
    todayTitle: 'اليوم',
    todayAyah: 'آية اليوم',
    hijriCalendar: 'التقويم الهجري',
    gregorianCalendar: 'التقويم الميلادي',
    todayLoadFailed: 'تعذر تحميل آية اليوم',
    searchHint: 'ابحث أو أدخل رقم صفحة',
    searchVersesHeader: 'الآيات',
    goToPage: 'الانتقال إلى صفحة',
    searchResults: 'نتائج البحث',
    noSearchResults: 'لا توجد نتائج مطابقة لبحثك',
    settings: 'الإعدادات',
    theme: 'وضع السمة',
    pageNotFound: 'الصفحة غير موجودة',
    returnHome: 'العودة للرئيسية',
    networkError: 'فشل الاتصال بالشبكة',
    cacheError: 'خطأ في الذاكرة المؤقتة',
    serverError: 'خطأ في الخادم',
  };

  /// Translates [key] using EasyLocalization when initialized,
  /// falling back gracefully to the Arabic dictionary in [arabicTranslations].
  static String tr(String key, {List<String>? args}) {
    try {
      final translated = ez.tr(key, args: args);
      if (translated != key) {
        return translated;
      }
    } catch (_) {}

    final fallback = arabicTranslations[key];
    if (fallback != null) {
      if (args != null && args.isNotEmpty) {
        String result = fallback;
        for (int i = 0; i < args.length; i++) {
          result = result.replaceAll('{$i}', args[i]);
        }
        return result;
      }
      return fallback;
    }
    return key;
  }
}
