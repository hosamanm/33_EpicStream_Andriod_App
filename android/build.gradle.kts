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

// Fix for AGP 8.0+ "Namespace not specified" errors in older plugins
subprojects {
    afterEvaluate {
        val project = this
        if (extensions.findByName("android") != null) {
            val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension

            // 1. Set namespace if missing
            if (android.namespace == null || android.namespace == "unspecified") {
                val manifestFile = file("${projectDir}/src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    try {
                        val content = manifestFile.readText()
                        val match = Regex("package=\"([^\"]*)\"").find(content)
                        if (match != null) {
                            android.namespace = match.groups[1]?.value
                        }
                    } catch (e: Exception) {
                        // Ignore errors reading manifest
                    }
                }

                // Final fallback for other plugins
                if (android.namespace == null || android.namespace == "unspecified") {
                    val projectName = name.replace("-", "_")
                    android.namespace = "com.manjunath.epicstream.$projectName"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
