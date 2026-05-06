allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    // Only override the build directory if the subproject is on the same drive as the root project.
    // This prevents errors when plugins are located on a different drive (e.g., in the Pub cache).
    if (project.projectDir.absoluteFile.toPath().root == rootProject.projectDir.absoluteFile.toPath().root) {
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

// Force compileSdk on all plugin subprojects to 35 so androidx deps resolve correctly.
// This must be declared BEFORE evaluationDependsOn(":app") to avoid "already evaluated" errors.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            project.extensions.findByName("android")?.let { ext ->
                val androidExt = ext as com.android.build.gradle.BaseExtension
                val currentSdk = androidExt.compileSdkVersion?.removePrefix("android-")?.toIntOrNull() ?: 0
                if (currentSdk < 35) {
                    androidExt.compileSdkVersion(35)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
