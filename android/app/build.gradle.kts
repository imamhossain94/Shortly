import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key secrets, kept out of version control. See key.properties.example.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}

/** A value is usable only if it is present and not blank. */
fun keystoreValue(name: String): String? =
    keystoreProperties.getProperty(name)?.takeIf { it.isNotBlank() }

// All four are required. A partly-filled key.properties falls back to the debug
// key rather than signing with half a config — the warning below says so, since
// a debug-signed release would otherwise only be caught at Play upload.
val releaseSigningValues = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    .associateWith { keystoreValue(it) }
val hasReleaseSigning = releaseSigningValues.values.all { it != null }

if (!hasReleaseSigning) {
    val missing = releaseSigningValues.filterValues { it == null }.keys
    logger.warn(
        "Release signing disabled: android/key.properties is " +
            (if (keystorePropertiesFile.exists()) "missing values $missing" else "absent") +
            ". Release builds will use the debug key and Play will reject them."
    )
}

android {
    namespace = "com.newagedevs.url_shortener"
    // Ahead of flutter.compileSdkVersion (36): receive_sharing_intent 1.9.0
    // publishes AAR metadata requiring API 37 to compile against. Only the
    // compile SDK moves — targetSdk stays where Flutter puts it, so runtime
    // behaviour is unchanged.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.newagedevs.url_shortener"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseSigningValues.getValue("storeFile")!!)
                storePassword = releaseSigningValues.getValue("storePassword")
                keyAlias = releaseSigningValues.getValue("keyAlias")
                keyPassword = releaseSigningValues.getValue("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // The upload key when key.properties is filled in; the debug key
            // otherwise, so `flutter run --release` still works without it.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigning) "release" else "debug"
            )
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-splashscreen:1.2.0")
    // AppLovin mediation adapters
    implementation("com.applovin.mediation:inmobi-adapter:+")
    implementation("com.squareup.picasso:picasso:2.8")
    implementation("androidx.recyclerview:recyclerview:1.1.0")
    implementation("com.applovin.mediation:vungle-adapter:+")
    implementation("com.applovin.mediation:facebook-adapter:+")
}
