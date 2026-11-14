# Snap Kit (Creative Kit + Core Kit) usa Retrofit con interfaces genéricas:
# sin estas reglas R8 borra las firmas y la app release se cae al abrir
# ("Call return type must be parameterized as Call<Foo>"), 2026-11-14.
-keepattributes Signature, InnerClasses, EnclosingMethod, Exceptions, *Annotation*
-keep class com.snap.** { *; }
-keep interface com.snap.** { *; }
-dontwarn com.snap.**

# Retrofit / OkHttp / Wire / Gson (dependencias de Snap Core Kit)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-keep class com.squareup.wire.** { *; }
-dontwarn retrofit2.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn com.squareup.wire.**
