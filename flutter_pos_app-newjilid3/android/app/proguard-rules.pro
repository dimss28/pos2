# Flutter & Dart core — embedding entry points.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# print_bluetooth_thermal — native bindings.
-keep class com.example.print_bluetooth_thermal.** { *; }
-keep class com.bemobile.print_bluetooth_thermal.** { *; }

# mobile_scanner — uses Google ML Kit Barcode under the hood.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }

# qr_flutter + zxing transitive.
-keep class com.google.zxing.** { *; }

# Keep Suspend/coroutine metadata for plugin channels.
-keepclassmembers,allowobfuscation class * {
    @kotlin.coroutines.jvm.internal.DebugMetadata <fields>;
}

# pdf package needs the printing service classes.
-keep class * extends androidx.print.PrintHelper { *; }

# Used by image_picker on older devices.
-keep class androidx.exifinterface.** { *; }

# Permission_handler.
-keep class com.baseflow.permissionhandler.** { *; }

# General: Don't strip annotation classes — Flutter plugins use them.
-keepattributes Signature, *Annotation*, InnerClasses, EnclosingMethod

# Silence missing-class warnings that come from optional desugar paths.
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# Play Core Split-Install API — referenced by Flutter's PlayStore deferred-
# component path. We don't use deferred components, so silence R8 here.
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
