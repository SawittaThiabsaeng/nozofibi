# Keep Flutter and plugin reflection metadata where needed.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Firebase classes commonly referenced via reflection.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
