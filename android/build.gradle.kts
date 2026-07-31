import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Relocate build directory outputs outside the android folder for Flutter compliance
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Assign subproject build directories
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Specific configurations for individual Flutter plugins
    if (name == "file_picker") {
        pluginManager.apply("org.jetbrains.kotlin.android")

        tasks.withType<KotlinJvmCompile>().configureEach {
            compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
        }

        // Work around Windows file-lock issues in AGP lint cache during release builds.
        tasks.matching { it.name == "lintVitalAnalyzeRelease" }.configureEach {
            enabled = false
        }
    }

    if (name == "google_api_headers") {
        // Force both Java and Kotlin to use JVM 11 to prevent target mismatches
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "11"
            targetCompatibility = "11"
        }

        tasks.withType<KotlinJvmCompile>().configureEach {
            compilerOptions.jvmTarget.set(JvmTarget.JVM_11)
        }

        // Fallback for Android Gradle Plugin's internal compiler tasks
        afterEvaluate {
            if (project.plugins.hasPlugin("com.android.library")) {
                val android = project.extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
                android?.apply {
                    compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_11
                        targetCompatibility = JavaVersion.VERSION_11
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
