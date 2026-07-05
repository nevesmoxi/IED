# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep Gson/JSON-adjacent reflection-safe rules (defensive; app uses dart:convert only)
-keepattributes Signature
-keepattributes *Annotation*

# Suppress warnings for common Play Core split-install classes referenced by
# the Flutter engine's deferred-components support, even when unused here.
-dontwarn com.google.android.play.core.**
