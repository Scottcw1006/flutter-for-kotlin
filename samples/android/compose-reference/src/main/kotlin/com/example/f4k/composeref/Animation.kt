package com.example.f4k.composeref

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

// 第 3 章「動畫」左欄的 Kotlin 程式碼，與 site/lib/demos/animation_demos.dart 對應

// [snippet:anim-implicit]
@Composable
fun ImplicitDemo() {
    var expanded by remember { mutableStateOf(false) }
    val spec = tween<Dp>(400, easing = FastOutSlowInEasing)
    val width by animateDpAsState(if (expanded) 200.dp else 100.dp, spec)
    val height by animateDpAsState(if (expanded) 120.dp else 100.dp, spec)
    val radius by animateDpAsState(if (expanded) 32.dp else 12.dp, spec)
    val color by animateColorAsState(if (expanded) Color(0xFF009688) else Color(0xFFFF9800), tween(400))

    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Box(
            Modifier
                .size(width, height)
                .clip(RoundedCornerShape(radius))
                .background(color)
                .clickable { expanded = !expanded },
            contentAlignment = Alignment.Center,
        ) {
            Text(if (expanded) "點我縮小" else "點我", color = Color.White)
        }
    }
}
// [/snippet]

// [snippet:anim-switcher]
@Composable
fun SwitcherDemo() {
    var count by remember { mutableIntStateOf(0) }
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        AnimatedContent(
            targetState = count,
            transitionSpec = { scaleIn() togetherWith scaleOut() },
        ) { value ->
            Text("$value", style = MaterialTheme.typography.displayMedium)
        }
        Button(onClick = { count++ }) { Text("+1") }
    }
}
// [/snippet]

// [snippet:anim-size]
@Composable
fun ExpandDemo() {
    var expanded by remember { mutableStateOf(false) }
    Card(Modifier.padding(16.dp).clickable { expanded = !expanded }) {
        Column(Modifier.padding(16.dp).animateContentSize()) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "什麼是 constraints？",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.weight(1f),
                )
                Icon(
                    if (expanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                    contentDescription = null,
                )
            }
            if (expanded) {
                Text(
                    "父層告訴子元件可以多大，子元件在範圍內決定自己的大小，再由父層決定擺放的位置。",
                    Modifier.padding(top = 8.dp),
                )
            }
        }
    }
}
// [/snippet]

// [snippet:anim-explicit]
@Composable
fun SpinnerDemo() {
    val rotation = remember { Animatable(0f) }
    var running by remember { mutableStateOf(true) }
    // running 改變時，舊的 LaunchedEffect 會被取消，動畫跟著停下
    LaunchedEffect(running) {
        while (running) {
            rotation.animateTo(rotation.value + 360f, tween(1500, easing = LinearEasing))
        }
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(24.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            Modifier
                .size(80.dp)
                .graphicsLayer { rotationZ = rotation.value }
                .background(Color(0xFF3F51B5), RoundedCornerShape(16.dp)),
        )
        Button(onClick = { running = !running }) { Text(if (running) "暫停" else "繼續") }
    }
}
// [/snippet]
