pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://jitpack.io/") }
        maven { url = uri("https://cboost.jfrog.io/artifactory/chartboost-ads/") }
        maven { url = uri("https://android-sdk.is.com") }
        maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
        maven { url = uri("https://s3.amazonaws.com/smaato-sdk-releases/") }
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://jitpack.io/") }
        maven { url = uri("https://cboost.jfrog.io/artifactory/chartboost-ads/") }
        maven { url = uri("https://android-sdk.is.com") }
        maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
        maven { url = uri("https://s3.amazonaws.com/smaato-sdk-releases/") }
    }
}

rootProject.name = "Shortly"
include(":app")
 