rootProject.name = "f4k-android-samples"

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

// 網頁上「Compose 對照」欄位的程式碼都來自這個模組，CI 會編譯它，確保程式碼可用
include(":compose-reference")
