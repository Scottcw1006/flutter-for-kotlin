package com.example.f4k.native_bridge

import android.content.Context
import android.view.View
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.launch

// [snippet:platform-view]
// 工廠：Dart 端每建立一個 AndroidView，就呼叫一次 create
class ComposeCounterFactory(private val events: NativeEvents) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // creationParams 經過 StandardMessageCodec，Dart 的 Map 會變成 Kotlin 的 Map
        val title = (args as? Map<*, *>)?.get("title") as? String ?: ""
        return ComposeCounterView(context, title, events)
    }
}

class ComposeCounterView(
    context: Context,
    title: String,
    events: NativeEvents,
) : PlatformView {
    private val view = ComposeView(context).apply {
        setContent {
            MaterialTheme {
                Surface(color = MaterialTheme.colorScheme.secondaryContainer) {
                    var count by rememberSaveable { mutableIntStateOf(0) }
                    val scope = rememberCoroutineScope()
                    Column(
                        modifier = Modifier.fillMaxSize().padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        Text(title, style = MaterialTheme.typography.titleMedium)
                        Button(onClick = {
                            count++
                            // 透過 Pigeon 的 FlutterApi 通知 Dart 端
                            scope.launch { events.onNativeButtonClicked(count.toLong()) }
                        }) { Text("Compose 按鈕：$count") }
                    }
                }
            }
        }
    }

    override fun getView(): View = view

    override fun dispose() {
        view.disposeComposition()
    }
}
// [/snippet]
