plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 👈 dòng này ok
}

android {
    namespace = "com.example.note_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.note_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import Firebase BoM (đồng bộ version giữa các thư viện Firebase)
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // Dưới đây là các thư viện Firebase bạn muốn dùng:
    implementation("com.google.firebase:firebase-analytics")   // thống kê (tùy chọn)
    implementation("com.google.firebase:firebase-auth")        // đăng nhập / đăng ký
    implementation("com.google.firebase:firebase-firestore")   // database lưu task
}
