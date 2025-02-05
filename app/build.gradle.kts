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
    compileSdk = 35

    defaultConfig {
        applicationId = "com.newagedevs.url_shortener"
        minSdk = 24
        targetSdk = 35
        versionCode = 17
        versionName = "2.0.9"

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
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }

    room {
        schemaDirectory("$projectDir/schemas")
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.activity)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.filament.android)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)

    // Navigation
    implementation("androidx.navigation:navigation-fragment-ktx:2.7.7")
    implementation("androidx.navigation:navigation-ui-ktx:2.7.7")

    // Hilt
    implementation("com.google.dagger:hilt-android:2.48")
    ksp("com.google.dagger:hilt-compiler:2.48")

    // Retrofit (for network calls)
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.retrofit2:converter-scalars:2.11.0")

    // jsoup
    implementation("org.jsoup:jsoup:1.18.1")

    // Room (for local database storage)
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    // QR Code Generator (e.g., ZXing)
    implementation("com.google.zxing:core:3.5.1")
    implementation("com.journeyapps:zxing-android-embedded:4.3.0")

    // Hilt Dagger (Use with Hilt)
    implementation("com.google.dagger:dagger:2.48")
    ksp("com.google.dagger:dagger-compiler:2.48")

    // Coroutine
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // QR Code kotlin
    implementation("io.github.g0dkar:qrcode-kotlin:4.1.1")

    // Glide
    implementation("com.github.bumptech.glide:glide:5.0.0-rc01")
    ksp("com.github.bumptech.glide:compiler:5.0.0-rc01")

    // Justified textview
    implementation("com.codesgood:justifiedtextview:1.1.0")

    // AndroidX
    implementation("androidx.lifecycle:lifecycle-process:2.8.7")

    // Applovin
    implementation("com.google.android.gms:play-services-base:18.5.0")
    implementation("com.applovin:applovin-sdk:+")
    implementation("com.applovin.mediation:chartboost-adapter:+")
    implementation("com.google.android.gms:play-services-base:+")
    implementation("com.applovin.mediation:inmobi-adapter:+")
    implementation("com.squareup.picasso:picasso:+")
    implementation("androidx.recyclerview:recyclerview:+")
    implementation("com.applovin.mediation:ironsource-adapter:+")
    implementation("com.applovin.mediation:vungle-adapter:+")
    implementation("com.applovin.mediation:facebook-adapter:+")
    implementation("com.applovin.mediation:mintegral-adapter:+")
    implementation("com.applovin.mediation:unityads-adapter:+")
    implementation("com.applovin.mediation:yandex-adapter:+")

    // Google IAP
    implementation("com.github.akshaaatt:Google-IAP:1.7.0")

}

