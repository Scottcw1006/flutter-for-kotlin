package com.example.f4k.host

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val app = application as HostApplication
        setContent {
            MaterialTheme {
                val remaining by app.remaining.collectAsStateWithLifecycle()
                HostScreen(remaining)
            }
        }
    }
}

// [snippet:a2a-open]
@Composable
fun HostScreen(remaining: Int?) {
    val context = LocalContext.current
    Scaffold { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text("這是原生的 Compose 畫面", style = MaterialTheme.typography.titleLarge)
            Text("Flutter 回報的剩餘待辦：${remaining ?: "—"}")
            Button(onClick = {
                // 使用預先啟動、放在快取裡的引擎開啟 Flutter 畫面
                context.startActivity(
                    FlutterActivity
                        .withCachedEngine(HostApplication.ENGINE_ID)
                        .build(context),
                )
            }) { Text("開啟 Flutter 待辦清單") }
        }
    }
}
// [/snippet]
