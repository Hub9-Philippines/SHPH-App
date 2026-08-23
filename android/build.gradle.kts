import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Relocate build directory outputs cleanly outside the android folder
val relocatedBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(relocatedBuildDir)

subprojects {
    // Dynamically isolate each subproject's build directory
    project.layout.buildDirectory.value(relocatedBuildDir.dir(project.name))
    
    // Decoupled subproject configuration using plugin and lifecycle hooks
    when (name) {
        "file_picker" -> {
            pluginManager.apply("org.jetbrains.kotlin.android")

            tasks.withType<KotlinJvmCompile>().configureEach {
                compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
            }

            // Prevents Windows file-locking issues during release builds
            tasks.configureEach {
                if (name == "lintVitalAnalyzeRelease") {
                    enabled = false
                }
            }
        }

        "google_api_headers" -> {
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = "11"
                targetCompatibility = "11"
            }

            tasks.withType<KotlinJvmCompile>().configureEach {
                compilerOptions.jvmTarget.set(JvmTarget.JVM_11)
            }

            // Safe Android extension targeting without using 'afterEvaluate'
            plugins.withId("com.android.library") {
                val android = project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                android?.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(relocatedBuildDir)
}
