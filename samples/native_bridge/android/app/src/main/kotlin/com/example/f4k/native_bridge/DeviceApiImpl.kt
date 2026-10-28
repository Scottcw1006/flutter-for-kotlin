package com.example.f4k.native_bridge

import android.os.Build
import java.security.MessageDigest
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

// [snippet:pigeon-api]
// 實作 Pigeon 產生的 interface；方法簽章寫錯會直接編譯失敗
class DeviceApiImpl : DeviceApi {
    override fun getDeviceInfo(): DeviceInfo = DeviceInfo(
        manufacturer = Build.MANUFACTURER,
        model = Build.MODEL,
        sdkInt = Build.VERSION.SDK_INT.toLong(), // Dart 的 int 對應 Kotlin 的 Long
    )

    // @async 方法產生成 suspend fun，可以直接切到背景執行緒
    override suspend fun sha256(text: String): String = withContext(Dispatchers.Default) {
        MessageDigest.getInstance("SHA-256")
            .digest(text.toByteArray())
            .joinToString("") { "%02x".format(it) }
    }
}
// [/snippet]
