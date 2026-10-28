// [snippet:a2a-settings]
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    // include_flutter.groovy 會替 Flutter 模組加上自己的 repository，所以不能用 FAIL_ON_PROJECT_REPOS
    repositoriesMode = RepositoriesMode.PREFER_SETTINGS
    repositories {
        google()
        mavenCentral()
        // Flutter engine 的 AAR 放在這裡
        maven("https://storage.googleapis.com/download.flutter.io")
    }
}

rootProject.name = "android_host"
include(":app")

// 以原始碼方式引入 Flutter 模組：會新增 :flutter 這個 Gradle 專案
// .android/ 是 `flutter pub get` 產生的，不進版本控制
apply(from = File(settingsDir.parentFile, "todo_module/.android/include_flutter.groovy"))
// [/snippet]
