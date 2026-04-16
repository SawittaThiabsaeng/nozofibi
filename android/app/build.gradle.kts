import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
        val keystorePropertiesFile = rootProject.file("key.properties")
        val keystoreProperties = Properties()
        if (keystorePropertiesFile.exists()) {
            keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
        }

        signingConfigs {
            create("release") {
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                val envStorePassword = System.getenv("NOZOFIBI_STORE_PASSWORD")
                val envKeyPassword = System.getenv("NOZOFIBI_KEY_PASSWORD")
                val envKeyAlias = System.getenv("NOZOFIBI_KEY_ALIAS")
                if (!storeFilePath.isNullOrEmpty()) {
                    storeFile = file(storeFilePath)
                    storePassword = envStorePassword ?: keystoreProperties.getProperty("storePassword")
                    keyAlias = envKeyAlias ?: keystoreProperties.getProperty("keyAlias")
                    keyPassword = envKeyPassword ?: keystoreProperties.getProperty("keyPassword")
                }
            }
        }

    namespace = "com.nozofibi.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nozofibi.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

val isReleaseTask = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}
if (isReleaseTask && !rootProject.file("key.properties").exists()) {
    throw GradleException(
        "Missing android/key.properties for release signing. Copy android/key.properties.example and fill real values."
    )
}

if (isReleaseTask) {
    val missingEnvSecrets =
        System.getenv("NOZOFIBI_STORE_PASSWORD").isNullOrBlank() ||
        System.getenv("NOZOFIBI_KEY_PASSWORD").isNullOrBlank()
    if (missingEnvSecrets) {
        throw GradleException(
            "Missing NOZOFIBI_STORE_PASSWORD / NOZOFIBI_KEY_PASSWORD environment variables for release signing. Load secrets first."
        )
    }
}

if (isReleaseTask) {
    val keyProps = Properties().apply {
        rootProject.file("key.properties").inputStream().use { load(it) }
    }
    val releaseStoreFile = keyProps.getProperty("storeFile") ?: ""
    val releaseAlias = keyProps.getProperty("keyAlias") ?: ""
    if (
        releaseStoreFile.contains("debug.keystore", ignoreCase = true) ||
        releaseAlias.equals("androiddebugkey", ignoreCase = true)
    ) {
        throw GradleException(
            "Release build is using debug keystore. Configure a real upload/release keystore in android/key.properties before Play Store upload."
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
