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
// Legacy plugins (sentry_flutter, package_info_plus) still declare
// kotlinOptions { languageVersion = "1.6" }, which newer Kotlin (KGP) rejects.
// Force a supported language version on those modules only.
subprojects {
    if (name in listOf("sentry_flutter", "package_info_plus")) {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0)
            }
        }
    }
}
// Some plugins (jni_flutter/jni-0.14.1 etc.) don't pin an NDK and AGP's default
// picks up a broken local install — force a known-good NDK on every library module.
// Also force compileSdk so plugin modules (e.g. :jni at android-31) satisfy the
// AAR metadata checks of their androidx dependencies (requires 34+).
// Applied in afterEvaluate so it wins over module-declared values.
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.api.dsl.LibraryExtension> {
                ndkVersion = "28.2.13676358"
                compileSdk = 36
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
