package com.example.f4k.composeref

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout

// 第 2 章「非同步」左欄的 Kotlin 代碼，與 site/lib/demos/dart_async_demos.dart 一一對應

// [snippet:async-future]
suspend fun fetchUser(id: Int): String {
    delay(300)
    return "User#$id"
}

suspend fun futures() = coroutineScope {
    println("開始")
    val user = fetchUser(1)
    println("取得 $user")

    val users = listOf(2, 3, 4).map { id -> async { fetchUser(id) } }.awaitAll()
    println("並行取得 $users")

    launch { println("稍後取得 ${fetchUser(5)}") }
    println("futures() 的區塊結束，但 coroutineScope 會等 launch 完成")
}
// [/snippet]

// [snippet:async-errors]
suspend fun mayFail(ok: Boolean): String {
    delay(200)
    if (!ok) throw IllegalStateException("伺服器錯誤")
    println("mayFail($ok) 跑完了")
    return "成功"
}

suspend fun errors() {
    try {
        println(mayFail(true))
        println(mayFail(false))
    } catch (e: IllegalStateException) {
        println("捕捉到：${e.message}")
    }

    try {
        withTimeout(100) { mayFail(true) }
    } catch (e: TimeoutCancellationException) {
        println("逾時了，mayFail 已被取消")
    }
}
// [/snippet]

// [snippet:async-stream]
fun countdown(from: Int): Flow<Int> = flow {
    for (i in from downTo 1) {
        emit(i)
        delay(400)
    }
}

suspend fun streams() {
    countdown(5)
        .filter { it % 2 == 1 }
        .map { "倒數 $it" }
        .collect { println(it) }
    println("完成")
}
// [/snippet]

// [snippet:async-ui]
@Composable
fun CountdownDemo() {
    var round by remember { mutableIntStateOf(0) }
    val flow = remember(round) { countdown(5) }
    val value by flow.collectAsState(initial = null)

    Column(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(value?.toString() ?: "準備…", style = MaterialTheme.typography.displayMedium)
        Button(onClick = { round++ }) { Text("重新開始") }
    }
}
// [/snippet]

// [snippet:async-isolate]
fun fib(n: Int): Int = if (n < 2) n else fib(n - 1) + fib(n - 2)

suspend fun heavyWork() {
    val start = System.currentTimeMillis()
    val result = withContext(Dispatchers.Default) { fib(30) }
    println("fib(30) = $result，耗時 ${System.currentTimeMillis() - start} ms")
}
// [/snippet]
