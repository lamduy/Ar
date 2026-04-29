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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    configurations.configureEach {
        exclude(group = "com.android.support")
    }
}

subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withPlugin
        val isArPlugin2Project = project.name.contains("ar_flutter_plugin_2") ||
            project.path.contains("ar_flutter_plugin_2")
        val isLegacyArPluginProject = (project.name.contains("ar_flutter_plugin") ||
            project.path.contains("ar_flutter_plugin")) && !isArPlugin2Project

        val currentNamespace = runCatching {
            androidExt.javaClass.getMethod("getNamespace").invoke(androidExt) as? String
        }.getOrNull()

        if (!currentNamespace.isNullOrBlank()) return@withPlugin

        val manifestFile = file("src/main/AndroidManifest.xml")
        val manifestNamespace = if (manifestFile.exists()) {
            Regex("""package="([^"]+)"""")
                .find(manifestFile.readText())
                ?.groupValues
                ?.get(1)
        } else {
            null
        }

        val fallbackNamespace = manifestNamespace
            ?: "com.autofix.${project.name.replace("-", "_")}"

        runCatching {
            androidExt.javaClass
                .getMethod("setNamespace", String::class.java)
                .invoke(androidExt, fallbackNamespace)
        }

        // ar_flutter_plugin_2 must align to Java 17 (its Java task is 17).
        // Legacy AR plugin variants stay on Java 8.
        runCatching {
            val compileOptions = androidExt.javaClass.getMethod("getCompileOptions").invoke(androidExt)
            val javaVersionClass = Class.forName("org.gradle.api.JavaVersion")
            val version = if (isArPlugin2Project) {
                javaVersionClass.getField("VERSION_17").get(null)
            } else if (isLegacyArPluginProject) {
                javaVersionClass.getField("VERSION_1_8").get(null)
            } else {
                javaVersionClass.getField("VERSION_17").get(null)
            }
            compileOptions.javaClass.getMethod("setSourceCompatibility", javaVersionClass)
                .invoke(compileOptions, version)
            compileOptions.javaClass.getMethod("setTargetCompatibility", javaVersionClass)
                .invoke(compileOptions, version)
        }
    }
}

subprojects {
    tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
        val isArPlugin2Project = project.name.contains("ar_flutter_plugin_2") ||
            project.path.contains("ar_flutter_plugin_2")
        val isLegacyArPluginProject = (project.name.contains("ar_flutter_plugin") ||
            project.path.contains("ar_flutter_plugin")) && !isArPlugin2Project
        val jvmTarget = if (isArPlugin2Project) "17" else if (isLegacyArPluginProject) "1.8" else "17"
        sourceCompatibility = jvmTarget
        targetCompatibility = jvmTarget
    }

    tasks.configureEach {
        if (!name.contains("Kotlin", ignoreCase = true)) return@configureEach

        runCatching {
            val kotlinOptions = javaClass.getMethod("getKotlinOptions").invoke(this)
            val isArPlugin2Project = project.name.contains("ar_flutter_plugin_2") ||
                project.path.contains("ar_flutter_plugin_2")
            val isLegacyArPluginProject = (project.name.contains("ar_flutter_plugin") ||
                project.path.contains("ar_flutter_plugin")) && !isArPlugin2Project
            val jvmTarget = if (isArPlugin2Project) "17" else if (isLegacyArPluginProject) "1.8" else "17"
            kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                .invoke(kotlinOptions, jvmTarget)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
