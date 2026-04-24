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
    }
}

subprojects {
    tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
        val jvmTarget = if (project.name == "ar_flutter_plugin") "1.8" else "17"
        sourceCompatibility = jvmTarget
        targetCompatibility = jvmTarget
    }

    tasks.configureEach {
        if (!name.contains("Kotlin", ignoreCase = true)) return@configureEach

        runCatching {
            val kotlinOptions = javaClass.getMethod("getKotlinOptions").invoke(this)
            val jvmTarget = if (project.name == "ar_flutter_plugin") "1.8" else "17"
            kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                .invoke(kotlinOptions, jvmTarget)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
