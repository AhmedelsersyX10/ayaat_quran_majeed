# دليل بناء حزم الإصدار ونشر التطبيق — تطبيق آيـات
# Release Build & Deployment Guide — Ayaat App

**اسم التطبيق / App Name:** آيـات (Ayaat Quran Majeed)  
**معرّف الحزمة / Package ID:** `com.quran.ayaatquranmajeed`  
**المنصات المدعومة / Target Platforms:** Android (Google Play) & iOS (App Store)  

---

## 1. المتطلبات الأولية للبيئة / Environment Prerequisites

قبل البدء في بناء حزمة الإنتاج، تأكد من توفر الآتي:
- **Flutter SDK:** الإصدار الحالي المثبت المتوافق مع `sdk: ">=3.11.0 <4.0.0"`.
- **JDK:** Java 17 (مطلوب بواسطة إعدادات `build.gradle.kts`).
- **نظافة المستودع وسلامة الفحوصات:**
  ```bash
  flutter clean # فقط إذا تم تحديث إعدادات native كبرى
  flutter pub get
  flutter analyze
  flutter test
  ```
  يجب أن تمر جميع التحليلات والاختبارات بنجاح بنسبة 100%.

---

## 2. إعداد مفتاح التوقيع الرقمي (Android Signing Keystore)

### أ. إنشاء مفتاح توقيع جديد (إن لم يكن متوفراً مسبقاً)
إذا لم يكن لديك مفتاح توقيع مسبق للتطبيق، قم بتوليد مفتاح أمان عالي عبر أداة `keytool`:
```bash
keytool -genkey -v \
        -keystore android/app/upload-keystore.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias upload
```
*سيُطلب منك إدخال كلمة مرور آمنة وبيانات المطور (الاسم، المؤسسة، الدولة).*

> [!CAUTION]
> **تحذير أمني حرج:**
> 1. احتفظ بنسخة احتياطية مشفرة وخارجية من ملف `upload-keystore.jks` وكلمات المرور الخاصة به. فقدان هذا المفتاح قد يمنعك من تحديث التطبيق على المتجر نهائياً!
> 2. **يُحظر تماماً رفع أو تضمين ملفات `*.jks` أو `*.keystore` أو `key.properties` في مستودع Git.**

### ب. تكوين ملف `key.properties`
1. انسخ ملف القالب المرفق:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. افتح ملف `android/key.properties` واملأ بيانات المفتاح الحقيقية:
   ```properties
   keyAlias=upload
   keyPassword=YOUR_ACTUAL_KEY_PASSWORD
   storeFile=upload-keystore.jks
   storePassword=YOUR_ACTUAL_STORE_PASSWORD
   ```
   *(ملاحظة: إذا وضعت ملف `upload-keystore.jks` داخل مجلد `android/app/`، فإن المسار النسبي `upload-keystore.jks` مدعوم وتلقائي).*

---

## 3. إدارة الإصدارات (Versioning in `pubspec.yaml`)

يتم تحديد رقم الإصدار في `pubspec.yaml` بالصيغة:
```yaml
version: 1.0.0+2
```
- **قبل علامة `+` (Version Name):** إصدار التطبيق الظاهر للمستخدمين في المتجر (مثلاً `1.0.0`).
- **بعد علامة `+` (Version Code):** رقم تصاعدي صحيح خاص بالمتجر (مثلاً `2`).  
  **قاعدة المتجر:** كل رفع جديد لمتجر Google Play يتطلب زيادة هذا الرقم بقيمة 1 على الأقل (مثلاً `1.0.0+3`).

---

## 4. بناء حزمة Android App Bundle (AAB) المخصصة للنشر

Google Play يفرض رفع التطبيقات بصيغة **Android App Bundle (.aab)** بدلاً من APK.

### أمر البناء الرسمي مع التشويش الأمني (Obfuscation):
```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

### فوائد هذا الأمر:
1. `--release`: تطبيق تحسينات الأداء، تفعيل ProGuard/R8، وحذف أكواد التطوير والتشخيص.
2. `--obfuscate`: تشويش أكواد Dart البرمجية لحماية الملكية الفكرية وصعوبة الهندسة العكسية.
3. `--split-debug-info`: استخراج رموز تتبع الأخطاء وتفريغها في مجلد منفصل (`build/app/outputs/symbols`) لتقليل حجم الحزمة، واستخدامها في فك تشفير تقارير الأخطاء (Crash Reports) في Google Play Console.

### مسار ملف الحزمة النهائي:
```text
build/app/outputs/bundle/release/app-release.aab
```

### التحقق من توقيع الحزمة قبل الرفع:
يمكنك التأكد من توقيع ملف الـ AAB بمفتاحك عبر:
```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```
أو عبر بناء APK للتجربة على جهاز حقيقي:
```bash
flutter build apk --release
```

---

## 5. بناء تطبيق iOS (App Store IPA)

إذا كنت تبني لمنصة iOS عبر جهاز macOS:
1. تحقق من بيانات التعريف في `ios/Runner.xcodeproj` و `ios/Runner/Info.plist`:
   - `Bundle Identifier`: `com.quran.ayaatquranmajeed`
   - `Display Name`: `آيـات`
2. تشغيل أمر بناء حزمة التوزيع:
   ```bash
   flutter build ipa --release \
     --obfuscate \
     --split-debug-info=build/ios/outputs/symbols
   ```
3. استخدام أداة Xcode Organizer أو Transporter لرفع الحزمة إلى App Store Connect.

---

## 6. قائمة فحص ما قبل الرفع على Google Play Console (Pre-Flight Checklist)

| البند | الحالة / المطلوب |
| :--- | :--- |
| **معرّف الحزمة (Package Name)** | `com.quran.ayaatquranmajeed` مطابق تماماً للبيانات المسجلة. |
| **اسم التطبيق (App Name)** | `آيـات` |
| **وصف التطبيق** | تجهيز وصف مختصر ووصف كامل باللغة العربية يوضح مميزات القارئ القرآني والختمة. |
| **الأيقونة والرسومات** | أيقونة عالية الدقة 512×512، صورة مميزة (Feature Graphic) 1024×500، ولقطات شاشة (Screenshots). |
| **استبيان تصنيف المحتوى (Content Rating)** | تصنيف ملائم لجميع الأعمار (Everyone / PEGI 3 / All Ages)، قارئ قرآني خالي من أي محتوى عنف أو مواد غير لائقة. |
| **الجمهور المستهدف (Target Audience)** | متاح لجميع الأعمار (عام). |
| **استبيان أمان البيانات (Data Safety)** | مطابقة الإجابات الواردة في وثيقة: `docs/privacy/DATA_SAFETY_AND_PRIVACY.md` (صفر بيانات مجموعة، صفر مشاركة، تشفير أثناء النقل). |
| **سياسة الخصوصية (Privacy Policy URL)** | رفع نص السياسة الموثق في `docs/privacy/DATA_SAFETY_AND_PRIVACY.md` على رابط عام وتدوينه في خانة Privacy Policy بالمتجر. |
| **رفع ملف الرموز (Debug Symbols)** | رفع ملف الرموز الموجود في `build/app/outputs/symbols` إلى وحدة تحكم Play للمساعدة في تتبع الانهيارات المشوشة. |

---

## 7. استكشاف الأخطاء الشائعة وحلها (Troubleshooting)

1. **خطأ: `key.properties file not found` أثناء بناء الإصدار:**
   - تأكد من وجود ملف `android/key.properties` محلياً وصحة مسار `storeFile`.
   - في غياب هذا الملف، سيتم التوقيع تلقائياً بمفتاح التصحيح (Debug Key) لأغراض الاختبار، لكن متجر Play لن يقبل هذا المفتاح للنشر.

2. **خطأ: `versionCode already used` في Google Play:**
   - حدث رقم الإصدار في `pubspec.yaml` (مثلاً قم بزيادة `+2` إلى `+3`).

3. **حجم الحزمة كبير:**
   - استخدام صيغة `.aab` بدلاً من `.apk` يقلل الحجم للمستخدم النهائي بنسبة تتجاوز 40%؛ لأن متجر Play يقوم بتجزئة الحزم حسب لغة ومعمارية جهاز المستخدم (Dynamic Delivery).
