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

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
