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
        versionCode = 19
        versionName = "2.1.1"

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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

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
    implementation("androidx.navigation:navigation-fragment-ktx:2.9.5")
    implementation("androidx.navigation:navigation-ui-ktx:2.9.5")

    // Hilt
    implementation("com.google.dagger:hilt-android:2.57.2")
    ksp("com.google.dagger:hilt-compiler:2.57.2")

    // Retrofit (for network calls)
    implementation("com.squareup.okhttp3:okhttp:5.1.0")
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:3.0.0")
    implementation("com.squareup.retrofit2:converter-scalars:2.11.0")

    // jsoup
    implementation("org.jsoup:jsoup:1.21.2")

    // Room (for local database storage)
    implementation("androidx.room:room-runtime:2.8.1")
    implementation("androidx.room:room-ktx:2.8.1")
    ksp("androidx.room:room-compiler:2.8.1")

    // QR Code Generator (e.g., ZXing)
    implementation("com.google.zxing:core:3.5.3")
    implementation("com.journeyapps:zxing-android-embedded:4.3.0")

    // Hilt Dagger (Use with Hilt)
    implementation("com.google.dagger:dagger:2.57.2")
    ksp("com.google.dagger:dagger-compiler:2.57.2")

    // Coroutine
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")

    // QR Code kotlin
    implementation("io.github.g0dkar:qrcode-kotlin:4.5.0")

    // Glide
    implementation("com.github.bumptech.glide:glide:5.0.5")
    ksp("com.github.bumptech.glide:compiler:5.0.5")

    // Justified textview
    implementation("com.codesgood:justifiedtextview:2.0.1")

    // AndroidX
    implementation("androidx.lifecycle:lifecycle-process:2.9.4")

    // Applovin
    implementation("com.google.android.gms:play-services-base:18.9.0")
    implementation("com.applovin:applovin-sdk:13.4.0")
    implementation("com.applovin.mediation:chartboost-adapter:9.10.0.0")
    implementation("com.google.android.gms:play-services-base:18.9.0")
    implementation("com.applovin.mediation:inmobi-adapter:10.8.8.0")
    implementation("com.squareup.picasso:picasso:2.71828")
    implementation("androidx.recyclerview:recyclerview:1.4.0")
    implementation("com.applovin.mediation:ironsource-adapter:9.0.0.0.0")
    implementation("com.applovin.mediation:vungle-adapter:7.6.0.0")
    implementation("com.applovin.mediation:facebook-adapter:6.20.0.0")
    implementation("com.applovin.mediation:mintegral-adapter:16.9.91.0")
    implementation("com.applovin.mediation:unityads-adapter:4.16.1.0")

    // Google IAP
    implementation("com.github.akshaaatt:Google-IAP:1.7.0")

}

