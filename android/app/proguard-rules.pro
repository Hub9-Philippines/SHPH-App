# Flutter Stripe SDK - keep rules
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Stripe Android SDK
-dontwarn com.stripe.android.pushProvisioning.**

# Protect your local data models from being obfuscated (essential for JSON parsing)
-keep class com.hub9.serbisyohubph.models.** { *; }
-keep class com.hub9.serbisyohubph.data.** { *; }

# If you use Retrofit or network API interfaces, keep them intact
-keep interface com.hub9.serbisyohubph.api.** { *; }
