# Flutter ProGuard/R8 rules

# Keep Google ML Kit classes
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# Keep all ML Kit classes to prevent stripping
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep text recognition options
-keep class com.google.mlkit.vision.text.** { *; }

# Keep entity extraction
-keep class com.google.mlkit.nl.** { *; }

# Keep smart reply
-keep class com.google.mlkit.smartreply.** { *; }

# Keep language identification
-keep class com.google.mlkit.languagedetection.** { *; }

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
