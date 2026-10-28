package com.example.f4k.composeref

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionLayout
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import kotlinx.serialization.Serializable

// 第 4 章「導航」左欄的 Kotlin 代碼，與 site/lib/demos/nav_demos.dart 對應

// [snippet:nav-push]
@Serializable
object PushHome

@Serializable
object ColorPicker

@Composable
fun PushDemo() {
    val navController = rememberNavController()
    NavHost(navController, startDestination = PushHome) {
        composable<PushHome> { entry ->
            // 回傳結果要透過上一個畫面的 SavedStateHandle
            val picked by entry.savedStateHandle
                .getStateFlow("color", "尚未選擇")
                .collectAsStateWithLifecycle()
            Column(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text("選擇的顏色：$picked")
                Button(onClick = { navController.navigate(ColorPicker) }) { Text("選擇顏色") }
            }
        }
        composable<ColorPicker> {
            LazyColumn {
                items(listOf("紅色", "綠色", "藍色")) { color ->
                    ListItem(
                        headlineContent = { Text(color) },
                        modifier = Modifier.clickable {
                            navController.previousBackStackEntry?.savedStateHandle?.set("color", color)
                            navController.popBackStack()
                        },
                    )
                }
            }
        }
    }
}
// [/snippet]

// [snippet:nav-tabs]
@Composable
fun TabsDemo() {
    var index by rememberSaveable { mutableIntStateOf(0) }
    val tabs = listOf("首頁" to Icons.Default.Home, "搜尋" to Icons.Default.Search, "設定" to Icons.Default.Settings)
    // 保留每個分頁的 rememberSaveable 狀態，切回來時計數還在
    val stateHolder = rememberSaveableStateHolder()
    Scaffold(
        bottomBar = {
            NavigationBar {
                tabs.forEachIndexed { i, (label, icon) ->
                    NavigationBarItem(
                        selected = index == i,
                        onClick = { index = i },
                        icon = { Icon(icon, contentDescription = null) },
                        label = { Text(label) },
                    )
                }
            }
        },
    ) { padding ->
        Box(Modifier.padding(padding)) {
            stateHolder.SaveableStateProvider(index) { TabCounter(tabs[index].first) }
        }
    }
}

@Composable
fun TabCounter(label: String) {
    var count by rememberSaveable { mutableIntStateOf(0) }
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("$label：點了 $count 次")
        Button(onClick = { count++ }) { Text("+1") }
    }
}
// [/snippet]

// [snippet:nav-hero]
val heroColors = listOf(Color.Red, Color.Green, Color.Blue, Color(0xFFFF9800))

@OptIn(ExperimentalSharedTransitionApi::class)
@Composable
fun HeroDemo() {
    var selected by remember { mutableStateOf<Int?>(null) }
    SharedTransitionLayout {
        AnimatedContent(targetState = selected) { target ->
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                if (target == null) {
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        heroColors.forEachIndexed { i, color ->
                            Box(
                                Modifier
                                    .sharedElement(rememberSharedContentState("color-$i"), this@AnimatedContent)
                                    .size(56.dp)
                                    .background(color, CircleShape)
                                    .clickable { selected = i },
                            )
                        }
                    }
                } else {
                    Box(
                        Modifier
                            .sharedElement(rememberSharedContentState("color-$target"), this@AnimatedContent)
                            .size(192.dp)
                            .background(heroColors[target], CircleShape)
                            .clickable { selected = null },
                    )
                }
            }
        }
    }
}
// [/snippet]
