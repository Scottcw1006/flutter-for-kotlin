package com.example.f4k.host

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

// [snippet:a2a-engine]
class HostApplication : Application() {
    // Flutter 端回報的剩餘待辦數，原生畫面用 StateFlow 觀察
    private val _remaining = MutableStateFlow<Int?>(null)
    val remaining: StateFlow<Int?> = _remaining.asStateFlow()

    override fun onCreate() {
        super.onCreate()
        // 預先啟動 FlutterEngine 並執行 Dart 的 main()。
        // 開啟 Flutter 畫面時不必再等待引擎初始化，也能讓 Dart 狀態在畫面關閉後繼續存在
        val engine = FlutterEngine(this)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())

        MethodChannel(engine.dartExecutor.binaryMessenger, "f4k/host")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "remainingChanged" -> {
                        _remaining.value = call.arguments as Int
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
    }

    companion object {
        const val ENGINE_ID = "todo_engine"
    }
}
// [/snippet]
