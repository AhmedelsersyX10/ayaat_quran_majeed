# إعلان أمان البيانات وسياسة الخصوصية — تطبيق آيـات
# Data Safety & Privacy Policy — Ayaat App

**اسم التطبيق / App Name:** آيـات (Ayaat Quran Majeed)  
**معرّف الحزمة / Package ID:** `com.quran.ayaatquranmajeed`  
**تاريخ التحديث / Last Updated:** 2026-11-14  

---

## 1. ملخص أمان البيانات والخصوصية / Executive Summary

تطبيق **آيـات** هو مصحف إلكتروني وقارئ قرآني صُمم بالكامل مع إعطاء الأولوية القصوى لخصوصية المستخدم وأمانه:
- **لا يجمع أي بيانات شخصية:** التطبيق لا يطلب ولا يجمع ولا يرفع أي بيانات خاصة أو هوية للمستخدم.
- **لا توجد إعلانات أو متتبعات:** التطبيق خالٍ تماماً من أي شبكات إعلانية أو مكتبات تتبع أو تحليلات لأطراف ثالثة.
- **تخزين محلي فقط (Local-Only):** جميع التفضيلات، الفواصل، الآيات المميزة، الملاحظات، وسجل الختمة تُحفظ محلياً على جهاز المستخدم فقط (عبر Hive و SharedPreferences) ولا تُرسل لأي خادم خارجي.
- **اتصالات مشفرة (HTTPS In Transit):** أي محتوى يتم تنزيله (تلاوات صوتية من شبكة mp3quran، أو كتب التفسير) يتم حصراً عبر بروتوكولات HTTPS الآمنة والمشفرة.

---

## 2. إجابات نموذج "أمان البيانات" في Google Play Console
## Google Play Data Safety Questionnaire Answers

عند تعبئة قسم **Data Safety (أمان البيانات)** في متجر Google Play، استخدم الإجابات التالية بدقة:

### أ. الأسئلة العامة / General Questions
1. **Does your app collect or share any of the required user data types?**  
   - **الإجابة:** `No` (لا يجمع التطبيق ولا يشارك أي نوع من بيانات المستخدمين).
2. **Is all of the user data collected by your app encrypted in transit?**  
   - **الإجابة:** `Yes` (كافة الاتصالات الشبكية لجلب التلاوات وكتب التفسير مشفرة عبر HTTPS).
3. **Do you provide a way for users to request that their data be deleted?**  
   - **الإجابة:** `Not applicable` (لا يتم إنشاء حسابات ولا توجد بيانات على خوادم سحابية؛ يمكن للمستخدم حذف كافة بياناته فوراً عبر حذف بيانات التطبيق أو إلغاء تثبيته من جهازه).

### ب. تفصيل الفئات والبيانات / Data Types Breakdown
- **Location (الموقع الجغرافي):** `Not collected / No` (لا يتم الوصول إلى الموقع).
- **Personal info (المعلومات الشخصية):** `Not collected / No` (لا اسم، لا بريد إلكتروني، لا رقم هاتف، لا معتقدات، لا هوية).
- **Financial info (المعلومات المالية):** `Not collected / No`.
- **Health and fitness (الصحة واللياقة):** `Not collected / No`.
- **Messages (الرسائل):** `Not collected / No`.
- **Photos and videos (الصور والفيديوهات):** `Not collected / No`.  
  *(التطبيق يتيح حفظ بطاقة الآية محلياً إلى المعرض بطلب صريح من المستخدم، ولا يرفع أي صور).*
- **Audio files (الملفات الصوتية):** `Not collected / No`.  
  *(التطبيق يقوم بتشغيل وتحميل التلاوات من جهة واحدة دون تسجيل أو رفع أي صوت).*
- **Files and docs (الملفات والمستندات):** `Not collected / No`.
- **Calendar & Contacts (التقويم وجهات الاتصال):** `Not collected / No`.
- **App activity & Web browsing (نشاط التطبيق والتصفح):** `Not collected / No`.
- **App info and performance (معلومات التطبيق والأداء):** `Not collected / No` (لا توجد أدوات Crashlytics أو مراقبة لأطراف ثالثة).
- **Device or other IDs (معرّفات الأجهزة):** `Not collected / No`.

---

## 3. الأذونات التقنية ومبرراتها / Permissions & Justifications

### Android (`AndroidManifest.xml`)
| الإذن / Permission | الاستخدام الفعلي والمبرر |
| :--- | :--- |
| `android.permission.INTERNET` | تدفق وتحميل ملفات تلاوة السور القرآنية من خوادم mp3quran، وتنزيل كتب التفاسير. |
| `android.permission.FOREGROUND_SERVICE` | استمرار تشغيل تلاوة القرآن الكريم في الخلفية عند قفل الشاشة أو استخدام تطبيق آخر. |
| `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK` | مخصص للتحكم بالوسائط الصوتية في الخلفية طبقاً لمتطلبات Android 14+. |
| `android.permission.POST_NOTIFICATIONS` | إظهار إشعار مشغل الصوت في شريط الإشعارات، وإرسال التذكير اليومي بورد الختمة (اختياري حسب رغبة المستخدم). |
| `android.permission.RECEIVE_BOOT_COMPLETED` | إعادة جدولة منبه التذكير اليومي بالختمة محلياً بعد إعادة تشغيل الهاتف. |

### iOS (`Info.plist`)
| المفتاح / Key | الاستخدام الفعلي والمبرر |
| :--- | :--- |
| `UIBackgroundModes: audio` | استمرار الاستماع للتلاوة العطرة في الخلفية. |
| `NSPhotoLibraryAddUsageDescription` | حفظ بطاقات الآيات المصممة في ألبوم الصور عند اختيار المستخدم "حفظ الصورة". |

---

## 4. نص سياسة الخصوصية (باللغة العربية)

### سياسة الخصوصية لتطبيق "آيـات"
نحن في تطبيق **"آيـات"** نلتزم التزاماً كاملاً بحماية خصوصية مستخدمينا. تم تطوير هذا التطبيق ليكون قارئاً للقرآن الكريم دون أي تتبع أو جمع لمعلومات شخصية.

#### 1. جمع البيانات واستخدامها
- **البيانات الشخصية:** لا يقوم تطبيق "آيـات" بجمع أي معلومات تعريفية شخصية مثل الاسم أو البريد الإلكتروني أو رقم الهاتف أو الموقع الجغرافي.
- **البيانات المحلية:** كافة البيانات التي يُدخلها المستخدم، بما يشمل: الفواصل المرجعية، الآيات المميزة بنجمة، الملاحظات المكتوبة، وإعدادات وبرامج الختمة، تُخزن فقط وبشكل كامل على ذاكرة جهاز المستخدم. لا نملك أي خوادم تخزن هذه البيانات ولا نستطيع الاطلاع عليها.
- **حذف البيانات:** يمكن للمستخدم حذف كافة بياناته في أي وقت ببساطة عن طريق مسح بيانات التطبيق من إعدادات جهازه أو إلغاء تثبيت التطبيق.

#### 2. الاتصال بالإنترنت والمحتوى الخارجي
- يستخدم التطبيق الاتصال بالإنترنت فقط لجلب ملفات التلاوات الصوتية للسور من خوادم mp3quran وتنزيل كتب التفسير والترجمات المعتمدة.
- جميع الاتصالات تتم عبر بروتوكولات آمنة ومشفرة (HTTPS).

#### 3. أذونات الجهاز
- **الإشعارات:** تُستخدم حصراً لعرض شريط التحكم بالتلاوة الجارية وإرسال التنبيه بورد الختمة اليومي في الموعد الذي يحدده المستخدم.
- **التشغيل في الخلفية:** يُستخدم لضمان استمرار الاستماع للقرآن الكريم عند قفل الشاشة.
- **معرض الصور:** يُطلب الإذن فقط عند رغبة المستخدم في حفظ صورة بطاقة الآية في مكتبة الصور.

#### 4. الإعلانات والجهات الخارجية
- التطبيق **خالٍ تماماً من الإعلانات**.
- لا يتم استخدام أي حزم برمجية لأطراف ثالثة تهدف إلى جمع البيانات أو تتبع سلوك المستخدم.

#### 5. التواصل معنا
إذا كان لديك أي استفسار حول سياسة الخصوصية، يسعدنا تواصلك معنا عبر وسائل التواصل المتاحة في صفحة "عن التطبيق".

---

## 5. Privacy Policy (English Version)

### Privacy Policy for "Ayaat" App
At **Ayaat**, we are fully committed to protecting your privacy. This application is developed to be a dedicated Quran reader without tracking, analytics, or collection of personal data.

#### 1. Information Collection and Use
- **Personal Information:** Ayaat does not collect, store, or share any personally identifiable information (such as name, email address, phone number, or physical location).
- **Local Data:** All user-generated content—including reading bookmarks, starred verses, personal notes, and Khatma schedules—is stored solely and locally on your device. We do not operate remote servers to harvest or access your data.
- **Data Deletion:** You have full control over your data. You can delete all locally stored data at any time by clearing the application storage in your device settings or by uninstalling the application.

#### 2. Network Connectivity & External Content
- Network access is utilized exclusively to stream and download Quranic recitations from mp3quran servers and download authentic Tafsir/Translation texts.
- All network requests are encrypted and transmitted via secure HTTPS connections.

#### 3. Device Permissions
- **Notifications:** Used strictly to display audio playback controls in the notification area and deliver optional daily Khatma reading reminders scheduled by the user.
- **Foreground Media Playback:** Enables continuous audio playback when the application is running in the background or the screen is locked.
- **Photo Library Access:** Requested only when the user explicitly chooses to save an exported Quranic verse card to their photo library.

#### 4. Advertisements & Third-Party Services
- The app is **completely ad-free**.
- No third-party tracking, advertising, or profiling SDKs are included.

#### 5. Contact Us
If you have any questions or suggestions regarding our Privacy Policy, please contact us through the channels listed in the "About" section of the app.
