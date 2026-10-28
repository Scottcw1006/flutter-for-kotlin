package com.example.f4k.native_bridge

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

// 用 FlutterFragmentActivity（ComponentActivity 的子類別）而不是 FlutterActivity：
// 嵌入的 ComposeView 需要從 view tree 找到 LifecycleOwner 與 SavedStateRegistryOwner
// [snippet:channel-register]
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 1. MethodChannel：名稱字串必須與 Dart 端完全相同
        MethodChannel(messenger, "f4k/battery")
            .setMethodCallHandler(BatteryMethodHandler(applicationContext))

        // 2. EventChannel：原生端持續推送事件
        EventChannel(messenger, "f4k/charging")
            .setStreamHandler(ChargingStreamHandler(applicationContext))

        // 3. Pigeon：產生的 setUp 會幫你註冊所有 channel
        DeviceApi.setUp(messenger, DeviceApiImpl())

        // 4. Platform view：註冊工廠，Dart 端用 viewType 字串建立
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "f4k/compose-counter",
            ComposeCounterFactory(NativeEvents(messenger)),
        )
    }
}
// [/snippet]
