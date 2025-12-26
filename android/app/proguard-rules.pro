# Flutter and Dart rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Google Maps API
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Prevent removing R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}
