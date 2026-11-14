import java.util.Base64

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Valores de --dart-define / --dart-define-from-file (env/*.json): Flutter
// los pasa a Gradle en base64 en la propiedad "dart-defines"
val dartDefines: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.mapNotNull {
            val pair = String(Base64.getDecoder().decode(it))
            val i = pair.indexOf('=')
            if (i > 0) pair.substring(0, i) to pair.substring(i + 1) else null
        }
        ?.toMap()
        ?: emptyMap()

android {
    namespace = "com.hakifit.haki_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Lo pide flutter_local_notifications (notificaciones programadas)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hakifit.haki_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Snap Kit (Creative Kit) lee el Client ID del manifest
        manifestPlaceholders["snapClientId"] = dartDefines["SNAP_CLIENT_ID"] ?: ""
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Reglas para que R8 no rompa el SDK de Snap (Retrofit)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // FileProvider para compartir stickers a Snapchat (MainActivity)
    implementation("androidx.core:core-ktx:1.13.1")
    // Snap Kit Creative Kit oficial (Maven Central): sticker a la cámara de
    // Snapchat. Antes el intent iba a mano y Snapchat respondía "Something
    // went wrong" (le faltaban KIT_VERSION y otros datos que pone el SDK)
    implementation("com.snap.creativekit:creativekit:3.0.0")
}
