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
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// فرض compileSdk على مكتبات الـ plugins القديمة (زي flutter_displaymode)
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            extensions.findByName("android")?.let {
                extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                    val current = compileSdkVersion
                        ?.removePrefix("android-")
                        ?.toIntOrNull() ?: 0
                    if (current < 36) {
                        compileSdkVersion(36)
                    }
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
