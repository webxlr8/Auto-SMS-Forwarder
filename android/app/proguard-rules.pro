# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep the Flutter background service plugin
-keep class com.ekokotov.background_service.** { *; }

# For native Android SharedPreferences
-keep class androidx.core.app.** { *; }
-keep class androidx.preference.Preference** { *; }

# Keep the permission handler plugin
-keep class com.baseflow.permissionhandler.** { *; }

# Keep service model classes
-keep class com.example.sms_forward_app.models.** { *; }
-keep class com.example.sms_forward_app.services.** { *; }