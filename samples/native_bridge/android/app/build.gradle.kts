// [snippet:platform-view-gradle]
plugins {
    id("com.android.application")
    // ① Compose 編譯器 plugin（版本在 settings.gradle.kts，要和 Kotlin 版本相同）
    id("org.jetbrains.kotlin.plugin.compose")
    // Flutter Gradle plugin 必須放在 Android 與 Kotlin plugin 之後
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.f4k.native_bridge"
    // ② Compose BOM 2026.09 需要 compileSdk 37，不能用範本的 flutter.compileSdkVersion
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    // ③ 開啟 Compose
    buildFeatures { compose = true }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.f4k.native_bridge"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 範例專案沒有上架，release 版沿用 debug 金鑰（正式簽章見第 8 章）
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Pigeon 產生的 suspend fun 需要 coroutines（Flutter 已間接帶入，這裡明確指定版本）
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
    implementation("androidx.core:core-ktx:1.17.0")
    // ④ Compose 函式庫
    implementation(platform("androidx.compose:compose-bom:2026.09.00"))
    implementation("androidx.compose.material3:material3")
}
// [/snippet]
