plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "org.eicsanjose.iqamah.iqamah"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

signingConfigs {
        getByName("debug") {
            keyAlias = "eic-iqamah"
            keyPassword = "EGmasjid2486"
            storeFile = file("/Users/mislam/flutter/iqamah/iqamah-keystore.jks")
            storePassword = "EGmasjid2486"
        }
        create("release") {
            keyAlias = "eic-iqamah"
            keyPassword = "EGmasjid2486"
            storeFile = file("/Users/mislam/flutter/iqamah/iqamah-keystore.jks")
            storePassword = "EGmasjid2486"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.eicsanjose.iqamah.iqamah"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdkVersion(34)
        ndkVersion = "27.0.12077973"
        
    }


    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
