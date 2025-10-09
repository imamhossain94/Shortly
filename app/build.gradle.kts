plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.jetbrains.kotlin.android)
    id("com.google.devtools.ksp")
    id("com.google.dagger.hilt.android")
    id("androidx.room")
    id("kotlin-parcelize")
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
}

android {
    namespace = "com.newagedevs.url_shortener"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.newagedevs.url_shortener"
        minSdk = 24
        //noinspection EditedTargetSdkVersion
        targetSdk = 36
        versionCode = 24
        versionName = "2.1.6"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    buildFeatures {
        buildConfig = true
    }
    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }

    room {
        schemaDirectory("$projectDir/schemas")
    }
}

dependencies {
    coreLibraryDesugaring(libs.desugar.jdk.libs)

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.activity)
    implementation(libs.androidx.constraintlayout)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)

    // Navigation
    implementation(libs.androidx.navigation.fragment.ktx)
    implementation(libs.androidx.navigation.ui.ktx)

    // Hilt
    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)

    // Retrofit (for network calls)
    implementation(libs.okhttp)
    implementation(libs.retrofit)
    implementation(libs.converter.gson)
    implementation(libs.converter.scalars)

    // jsoup
    implementation(libs.jsoup)

    // Room (for local database storage)
    implementation(libs.androidx.room.runtime)
    implementation(libs.androidx.room.ktx)
    ksp(libs.androidx.room.compiler)

    // QR Code Generator (e.g., ZXing)
    implementation(libs.core)
    implementation(libs.zxing.android.embedded)

    // Hilt Dagger (Use with Hilt)
    implementation(libs.dagger)
    ksp(libs.dagger.compiler)

    // Coroutine
    implementation(libs.kotlinx.coroutines.core)
    implementation(libs.kotlinx.coroutines.android)

    // QR Code kotlin
    implementation(libs.qrcode.kotlin)

    // Glide
    implementation(libs.glide)
    ksp(libs.compiler)

    // Justified textview
    implementation(libs.justifiedtextview)

    // AndroidX
    implementation(libs.androidx.lifecycle.process)

    // Applovin
    implementation(libs.play.services.base)
    implementation(libs.applovin.sdk)
    implementation(libs.chartboost.adapter)
    implementation(libs.play.services.base)
    implementation(libs.inmobi.adapter)
    implementation(libs.picasso)
    implementation(libs.androidx.recyclerview)
    implementation(libs.ironsource.adapter)
    implementation(libs.vungle.adapter)
    implementation(libs.facebook.adapter)
    implementation(libs.mintegral.adapter)
    implementation(libs.unityads.adapter)

    // Google IAP
    implementation(libs.google.iap)

}

