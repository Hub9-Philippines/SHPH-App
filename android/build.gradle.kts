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
    
    // FIX 1: Enforce Java compilation steps to use Java 17 bytecode targets
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    // FIX 2: Align Kotlin compilation steps to Java 17 targets
    tasks.withType<KotlinJvmCompile>().configureEach {
        compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
        // CRITICAL FIX: Bypass the rigid target mismatch validation error rule for plugins
        jvmTargetValidationMode.set(org.jetbrains.kotlin.gradle.dsl.jvm.JvmTargetValidationMode.WARNING)
    }

    // FIX 3: Target subproject Android library extensions to prevent internal target mismatches
    plugins.withId("com.android.library") {
        val libraryExtension = project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        libraryExtension?.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }

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
                sourceCompatibility = "17"
                targetCompatibility = "17"
            }

            tasks.withType<KotlinJvmCompile>().configureEach {
                compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
            }

            plugins.withId("com.android.library") {
                val android = project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
                android?.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(relocatedBuildDir)
}
