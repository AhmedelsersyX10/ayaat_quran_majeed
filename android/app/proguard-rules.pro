# ==============================================================================
# ProGuard / R8 Rules for Ayaat Quran Majeed
# ==============================================================================

# Flutter Engine & Framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve annotations, signatures, inner classes, and exceptions
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Exceptions

# Audio Playback: just_audio & audio_service & audio_session
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audiosession.** { *; }

# Notifications: flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gallery Saver: image_gallery_saver_plus
-keep class com.example.image_gallery_saver_plus.** { *; }
-keep class io.github.crow_misia.libgenericprofile.** { *; }

# Native platform plugins (path_provider, shared_preferences)
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# AndroidX Media & Core Notifications
-keep class androidx.media.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Suppress warnings for optional Play Core deferred components
-dontwarn com.google.android.play.core.**
-dontwarn javax.annotation.**
