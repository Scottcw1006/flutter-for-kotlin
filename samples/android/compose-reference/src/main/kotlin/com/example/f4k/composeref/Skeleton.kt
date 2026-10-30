package com.example.f4k.composeref

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

// 第 3 章「App 骨架與主題」的 Compose 對照，與 site/lib/demos/skeleton_demos.dart 對應

// [snippet:app-skeleton]
class SkeletonActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent { SkeletonApp() }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SkeletonApp() {
    // null 代表跟隨系統設定
    var darkOverride by rememberSaveable { mutableStateOf<Boolean?>(null) }
    val dark = darkOverride ?: isSystemInDarkTheme()
    // Compose 沒有內建「從一個種子色產生整套配色」，通常用 Material Theme Builder 產生
    val colors = if (dark) darkColorScheme(primary = Color(0xFF80CBC4)) else lightColorScheme(primary = Color(0xFF00796B))

    MaterialTheme(colorScheme = colors) {
        val snackbar = remember { SnackbarHostState() }
        val scope = rememberCoroutineScope()
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("App 骨架") },
                    actions = {
                        TextButton(onClick = { darkOverride = !dark }) { Text(if (dark) "淺色" else "深色") }
                    },
                )
            },
            floatingActionButton = {
                FloatingActionButton(onClick = { scope.launch { snackbar.showSnackbar("按下了 FAB") } }) {
                    Icon(Icons.Filled.Add, contentDescription = "新增")
                }
            },
            snackbarHost = { SnackbarHost(snackbar) },
        ) { padding ->
            Column(Modifier.padding(padding).padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("標題文字", style = MaterialTheme.typography.titleLarge)
                Text("primary 色的文字", color = MaterialTheme.colorScheme.primary)
                Button(onClick = {}) { Text("FilledButton") }
            }
        }
    }
}
// [/snippet]
