package com.example.f4k.composeref

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

// 第 3 章「列表」左欄的 Kotlin 代碼，與 site/lib/demos/list_demos.dart 對應

// [snippet:lists-builder]
@Composable
fun ContactListDemo() {
    LazyColumn {
        items(1000) { index ->
            ListItem(
                leadingContent = { Text("${'A' + index % 26}") },
                headlineContent = { Text("聯絡人 #$index") },
                supportingContent = { Text("捲到這裡才建立") },
            )
            HorizontalDivider()
        }
    }
}
// [/snippet]

// [snippet:lists-grid]
val palette = listOf(
    Color(0xFFFFCDD2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFFFF9C4),
)

@Composable
fun GridDemo() {
    val categories = listOf("全部", "工作", "生活", "學習", "運動", "旅行")
    Column {
        LazyRow(
            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(categories) { AssistChip(onClick = {}, label = { Text(it) }) }
        }
        LazyVerticalGrid(
            columns = GridCells.Fixed(3),
            contentPadding = PaddingValues(12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(30) { i ->
                Box(
                    Modifier.aspectRatio(1f).background(palette[i % palette.size], RoundedCornerShape(12.dp)),
                    contentAlignment = Alignment.Center,
                ) { Text("$i") }
            }
        }
    }
}
// [/snippet]

// [snippet:lists-keys]
val fruits = listOf("蘋果", "香蕉", "櫻桃", "葡萄")

@Composable
fun KeysDemo() {
    var items by remember { mutableStateOf(fruits) }
    var useKeys by remember { mutableStateOf(false) }
    Column {
        Row(Modifier.padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            Switch(checked = useKeys, onCheckedChange = { useKeys = it; items = fruits })
            Text("加上 key")
            Spacer(Modifier.weight(1f))
            TextButton(onClick = { items = items.drop(1) }, enabled = items.isNotEmpty()) {
                Text("刪除第一項")
            }
        }
        LazyColumn {
            items(items, key = if (useKeys) { fruit: String -> fruit } else null) { fruit ->
                FruitRow(name = fruit, initiallyChecked = fruit == "蘋果")
            }
        }
    }
}

@Composable
fun FruitRow(name: String, initiallyChecked: Boolean) {
    var checked by remember { mutableStateOf(initiallyChecked) }
    ListItem(
        headlineContent = { Text(name) },
        trailingContent = { Checkbox(checked = checked, onCheckedChange = { checked = it }) },
    )
}
// [/snippet]
