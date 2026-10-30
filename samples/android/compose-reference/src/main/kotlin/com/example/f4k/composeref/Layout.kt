package com.example.f4k.composeref

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// 第 3 章「版面配置與 constraints」左欄的 Kotlin 程式碼，與 site/lib/demos/layout_demos.dart 對應

private val Teal = Color(0xFF80CBC4)

// [snippet:layout-constraints]
@Composable
fun ConstraintsDemo() {
    var parent by remember { mutableIntStateOf(0) }
    // 想要 100 × 100 的方塊
    val box: @Composable (Modifier) -> Unit = { modifier ->
        Box(modifier.size(100.dp).background(Teal))
    }
    Column(Modifier.fillMaxSize()) {
        SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth().padding(8.dp)) {
            listOf("直接放", "Center", "SizedBox").forEachIndexed { i, label ->
                SegmentedButton(
                    selected = parent == i,
                    onClick = { parent = i },
                    shape = SegmentedButtonDefaults.itemShape(i, 3),
                ) { Text(label) }
            }
        }
        val area = Modifier.weight(1f).fillMaxWidth()
        when (parent) {
            // fillMaxSize 先把 constraints 變緊，後面的 size(100.dp) 就沒有作用
            0 -> box(area.fillMaxSize())
            // Box 給子元件鬆的 constraints，100.dp 生效
            1 -> Box(area, contentAlignment = Alignment.Center) { box(Modifier) }
            // Compose 的 Box 預設不把最小尺寸傳下去，要 propagateMinConstraints 才會變緊
            else -> Box(area, contentAlignment = Alignment.Center) {
                Box(Modifier.size(200.dp, 60.dp), propagateMinConstraints = true) { box(Modifier) }
            }
        }
    }
}
// [/snippet]

// [snippet:layout-flex]
@Composable
fun FlexDemo() {
    var flex by remember { mutableFloatStateOf(1f) }
    Column(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("藍色 weight: ${flex.toInt()}，綠色 weight: 1")
        Slider(value = flex, onValueChange = { flex = it }, valueRange = 1f..4f, steps = 2)
        Row(Modifier.height(64.dp)) {
            Box(Modifier.weight(flex).fillMaxHeight().background(Color(0xFF2196F3)), Alignment.Center) {
                Text("weight", color = Color.White)
            }
            Box(Modifier.weight(1f).fillMaxHeight().background(Color(0xFF4CAF50)), Alignment.Center) {
                Text("weight", color = Color.White)
            }
            Box(
                Modifier.weight(1f, fill = false).fillMaxHeight().background(Color(0xFFFF9800)).padding(8.dp),
                Alignment.Center,
            ) {
                Text("fill = false", color = Color.White)
            }
        }
    }
}
// [/snippet]

// [snippet:layout-stack]
@Composable
fun StackDemo() {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Box {
            Box(
                Modifier.size(96.dp).clip(CircleShape).background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center,
            ) {
                Text("K", fontSize = 40.sp)
            }
            Text(
                "99+",
                color = Color.White,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .offset(4.dp, 4.dp)
                    .background(Color.Red, RoundedCornerShape(12.dp))
                    .border(2.dp, Color.White, RoundedCornerShape(12.dp))
                    .padding(horizontal = 8.dp, vertical = 2.dp),
            )
        }
    }
}
// [/snippet]

// [snippet:layout-responsive]
@Composable
fun ResponsiveDemo() {
    var width by remember { mutableFloatStateOf(300f) }
    val labels = listOf("收件匣", "已排程", "已完成")
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Slider(value = width, onValueChange = { width = it }, valueRange = 120f..300f)
        Text("容器寬度 ${width.toInt()}")
        BoxWithConstraints(Modifier.width(width.dp)) {
            if (maxWidth < 220.dp) {
                Column { labels.forEach { InfoTile(it, Modifier.fillMaxWidth()) } }
            } else {
                Row { labels.forEach { InfoTile(it, Modifier.weight(1f)) } }
            }
        }
    }
}

@Composable
fun InfoTile(label: String, modifier: Modifier = Modifier) {
    Card(modifier.padding(4.dp)) {
        Text(label, Modifier.fillMaxWidth().padding(16.dp), textAlign = TextAlign.Center)
    }
}
// [/snippet]
