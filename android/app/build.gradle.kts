plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.newagedevs.url_shortener"
    compileSdk = flutter.compileSdkVersion
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

// ---------------------------------------------------------------------------
// Workaround: Flutter's code-generator incorrectly includes integration_test
// (a dev_dependency) in GeneratedPluginRegistrant.java. The class only exists
// in the debug/test classpath, so release builds fail. This task strips the
// offending lines automatically before every release compile.
// Tracked upstream: https://github.com/flutter/flutter/issues/94556
// ---------------------------------------------------------------------------
tasks.register("stripIntegrationTestPlugin") {
    doLast {
        val registrant = file(
            "src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
        )
        if (registrant.exists()) {
            val original = registrant.readText()
            val patched = original
                .replace(
                    Regex(
                        """[ \t]*try \{\s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG,[^\n]*integration_test[^\n]*\);\s*\}\n?"""
                    ),
                    ""
                )
            if (patched != original) {
                registrant.writeText(patched)
                println("stripIntegrationTestPlugin: removed IntegrationTestPlugin from GeneratedPluginRegistrant.java")
            }
        }
    }
}

// Wire the strip task to run before release Java compilation
afterEvaluate {
    tasks.matching { it.name == "compileReleaseJavaWithJavac" }.configureEach {
        dependsOn("stripIntegrationTestPlugin")
    }
}
