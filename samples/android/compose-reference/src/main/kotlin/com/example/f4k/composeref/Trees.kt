package com.example.f4k.composeref

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// 第 5 章 Compose 對照程式碼，與 site/lib/demos/tree_demos.dart、key_demos.dart 對應

// [snippet:tree-rebuild]
@Composable
fun RebuildDemo() {
    var ticks by remember { mutableIntStateOf(0) }
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Button(onClick = { ticks++ }) { Text("重組父層（$ticks）") }
        ChildProbe(ticks)
    }
}

@Composable
fun ChildProbe(ticks: Int) {
    // remember 的物件在重組之間保留，角色就像 Flutter 的 State
    val holder = remember { Any() }
    Card {
        Text(
            "參數 ticks = $ticks（每次重組都是新值）\nremember 的物件 #${System.identityHashCode(holder) % 10000}（一直是同一個）",
            Modifier.padding(16.dp),
        )
    }
}
// [/snippet]

// [snippet:tree-context]
val LocalAccent = staticCompositionLocalOf { Color(0xFF009688) }

@Composable
fun ContextDemo() {
    CompositionLocalProvider(LocalAccent provides Color(0xFF673AB7)) {
        Column(Modifier.padding(16.dp)) {
            // 讀取發生在 Provider 的 lambda 裡，拿到的一定是剛提供的紫色
            Swatch("在 CompositionLocalProvider 裡讀取", LocalAccent.current)
        }
    }
}

@Composable
fun Swatch(label: String, color: Color) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        Box(Modifier.size(40.dp).background(color, RoundedCornerShape(8.dp)))
        Text(label)
    }
}
// [/snippet]

// [snippet:tree-inherited]
val LocalTextScale = compositionLocalOf { 1f }

@Composable
fun InheritedDemo() {
    var scale by remember { mutableFloatStateOf(1f) }
    CompositionLocalProvider(LocalTextScale provides scale) {
        Column(Modifier.padding(16.dp)) {
            Slider(value = scale, onValueChange = { scale = it }, valueRange = 0.8f..2f)
            Card {
                Box(Modifier.padding(16.dp)) { ScaledLabel("不用一層層傳參數") }
            }
        }
    }
}

@Composable
fun ScaledLabel(text: String) {
    Text(text, fontSize = 14.sp * LocalTextScale.current)
}
// [/snippet]

// [snippet:tree-lifecycle]
@Composable
fun LifecycleProbe(label: Int, onEvent: (String) -> Unit) {
    DisposableEffect(Unit) {
        onEvent("進入組合（≈ initState）")
        onDispose { onEvent("離開組合（≈ dispose）") }
    }
    LaunchedEffect(label) { onEvent("label = $label（≈ didUpdateWidget）") }
    SideEffect { onEvent("重組完成（≈ build）") }
    Card { Text("子元件，參數 label = $label", Modifier.padding(12.dp)) }
}
// [/snippet]

// [snippet:keys-swap]
@Composable
fun SwapDemo() {
    var tiles by remember { mutableStateOf(listOf("A", "B")) }
    var useKeys by remember { mutableStateOf(false) }
    Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Switch(checked = useKeys, onCheckedChange = { useKeys = it; tiles = listOf("A", "B") })
            Text("加上 key")
            Spacer(Modifier.weight(1f))
            Button(onClick = { tiles = tiles.reversed() }) { Text("交換") }
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterHorizontally),
        ) {
            for (label in tiles) {
                if (useKeys) key(label) { ColorTile(label) } else ColorTile(label)
            }
        }
    }
}

@Composable
fun ColorTile(label: String) {
    // 顏色存在 remember 裡，只在第一次組合時決定：A 紅色、B 藍色
    val color = remember { if (label == "A") Color.Red else Color.Blue }
    Box(Modifier.size(96.dp).background(color, RoundedCornerShape(16.dp)), contentAlignment = Alignment.Center) {
        Text(label, color = Color.White, fontSize = 32.sp)
    }
}
// [/snippet]

// [snippet:const-skip]
@Composable
fun ConstDemo() {
    var ticks by remember { mutableIntStateOf(0) }
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Button(onClick = { ticks++ }) { Text("重組父層（$ticks）") }
        // 參數和上次相等：Compose 直接跳過這個函式
        RecomposeCounter("參數沒變的子元件")
        // 參數每次都不同：一定會重組
        RecomposeCounter("參數有變的子元件", token = ticks)
    }
}

@Composable
fun RecomposeCounter(label: String, token: Int = 0) {
    val count = remember { intArrayOf(0) }
    count[0]++ // 只是為了示範；實務上不要在組合過程中修改狀態
    Text("$label：重組了 ${count[0]} 次")
}
// [/snippet]
