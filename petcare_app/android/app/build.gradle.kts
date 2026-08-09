import java.util.Properties
import java.io.FileInputStream 

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val khoaKy = Properties()
val tepKhoaKy = rootProject.file("key.properties")
if (tepKhoaKy.exists()) {
    FileInputStream(tepKhoaKy).use { khoaKy.load(it) }
}

android {
    namespace = "com.petcare.smart_pet_care_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications dùng java.time nên bắt buộc bật
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.petcare.smart_pet_care_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 31
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue(
            "string",
            "facebook_app_id",
            project.findProperty("FACEBOOK_APP_ID") as String? ?: "CHUA_CO_FACEBOOK_APP_ID"
        )
        resValue(
            "string",
            "facebook_client_token",
            project.findProperty("FACEBOOK_CLIENT_TOKEN") as String? ?: "CHUA_CO_FACEBOOK_CLIENT_TOKEN"
        )
    }

    signingConfigs {
        if (tepKhoaKy.exists()) {
            create("release") {
                keyAlias = khoaKy["keyAlias"] as String
                keyPassword = khoaKy["keyPassword"] as String
                storeFile = file(khoaKy["storeFile"] as String)
                storePassword = khoaKy["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Không có key.properties thì APK ký khoá debug, chỉ cài được trên máy dev
            signingConfig = if (tepKhoaKy.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
