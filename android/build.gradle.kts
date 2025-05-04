// Don't remove this - it's needed to resolve dependencies from Google's Maven repository
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Removed the problematic line causing resource shrinking issues
// subprojects { project.evaluationDependsOn(":app") }

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
