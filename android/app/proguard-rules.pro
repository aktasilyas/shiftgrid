# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Play Billing (in_app_purchase)
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Play Core (Flutter deferred components / split install) — may be absent
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
