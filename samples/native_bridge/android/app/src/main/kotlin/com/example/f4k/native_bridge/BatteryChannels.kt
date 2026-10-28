package com.example.f4k.native_bridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// [snippet:channel-method]
class BatteryMethodHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    // 在 Android 主執行緒被呼叫；耗時工作要自己切到背景執行緒
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBatteryLevel" -> {
                val manager = context.getSystemService(BatteryManager::class.java)
                val level = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                if (level >= 0) {
                    result.success(level) // Int 會變成 Dart 的 int
                } else {
                    result.error("UNAVAILABLE", "無法取得電量", null)
                }
            }
            // 參數用 call.argument<T>("key") 讀取，型別要自己對好
            "setLowPowerThreshold" -> {
                val percent = call.argument<Int>("percent")
                if (percent == null) {
                    result.error("BAD_ARGS", "缺少 percent", null)
                } else {
                    result.success(null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
// [/snippet]

// [snippet:channel-event]
class ChargingStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    private var receiver: BroadcastReceiver? = null

    // Dart 端開始 listen 時呼叫，相當於 callbackFlow 的區塊開始執行
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
                events.success(
                    status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL,
                )
            }
        }
        ContextCompat.registerReceiver(
            context,
            receiver,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED),
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
    }

    // Dart 端取消訂閱時呼叫，相當於 awaitClose { }
    override fun onCancel(arguments: Any?) {
        receiver?.let(context::unregisterReceiver)
        receiver = null
    }
}
// [/snippet]
