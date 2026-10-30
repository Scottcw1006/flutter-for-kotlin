package com.example.f4k.composeref

// 第 2 章「語法對照」左欄的 Kotlin 程式碼，與 site/lib/demos/dart_syntax_demos.dart 一一對應

// [snippet:syntax-variables]
const val APP_NAME = "Todo" // 編譯期常數

fun variables() {
    val name = "Kotlin" // 不可重新指定
    var count = 0 // 可重新指定
    count += 1
    val price: Double = 9.5 // 型別寫在名稱後面
    val list = mutableListOf(1, 2, 3) // 要可修改得明確選 mutableListOf
    list.add(4)

    println("$APP_NAME: Hello, $name! count=$count")
    println("價格 ${price * 2}，共 ${list.size} 項")
    println("型別：${name::class.simpleName}")
}
// [/snippet]

// [snippet:syntax-functions]
fun greet(name: String, greeting: String = "Hello", excited: Boolean = false): String {
    val mark = if (excited) "!" else "."
    return "$greeting, $name$mark"
}

fun square(x: Int) = x * x

fun String.shout() = uppercase() + "!"

fun functions() {
    println(greet("Kotlin"))
    println(greet("Dart", excited = true))
    println(square(4))
    println("hi".shout())

    fun add(a: Int, b: Int) = a + b // 區域函式
    println(add(1, 2))
    println(listOf(1, 2, 3).map { it * 2 })
}
// [/snippet]

// [snippet:syntax-null]
class User(val name: String, val email: String?)

fun lookupNickname(name: String): String? = if (name == "Amy") "Ami" else null

lateinit var token: String

fun nullSafety() {
    val user = User("Amy", null)
    val length = user.email?.length // Int?
    val email = user.email ?: "（未提供）"
    println("length=$length, email=$email")

    val nickname = lookupNickname(user.name)
    if (nickname != null) println(nickname.length) // smart cast
    println(nickname!!.uppercase())

    // 同一個模組內的 val 屬性可以直接 smart cast
    if (user.email != null) println(user.email.length)

    token = "abc123"
    println("token=$token")
}
// [/snippet]

// [snippet:syntax-classes]
data class Point(val x: Int, val y: Int)

fun minMax(values: List<Int>): Pair<Int, Int> = values.min() to values.max()

fun classes() {
    val p = Point(1, 2)
    val q = p.copy(y = 5)
    println(p)
    println(p == Point(1, 2))
    println(q)

    val (min, max) = minMax(listOf(3, 1, 4)) // 解構
    println("min=$min, max=$max")
}
// [/snippet]

// [snippet:syntax-sealed]
sealed interface LoadState {
    data object Loading : LoadState
    data class Success(val items: List<String>) : LoadState
    data class Error(val message: String) : LoadState
}

fun describe(state: LoadState): String = when (state) {
    LoadState.Loading -> "載入中…"
    is LoadState.Success -> if (state.items.isEmpty()) "沒有資料" else "共 ${state.items.size} 筆"
    is LoadState.Error -> "錯誤：${state.message}"
}

fun sealedClasses() {
    val states = listOf(
        LoadState.Loading,
        LoadState.Success(listOf("a", "b")),
        LoadState.Success(emptyList()),
        LoadState.Error("逾時"),
    )
    for (state in states) {
        println(describe(state))
    }
}
// [/snippet]

// [snippet:syntax-collections]
fun collections() {
    val todos = listOf("買牛奶", "寫程式", "運動", "讀書")
    val showDone = todos.size > 3
    val menu = buildList {
        add("首頁")
        if (showDone) add("已完成")
        add("設定")
    }

    println(todos.filter { it.length == 2 }.map { "[$it]" })
    println(todos.withIndex().associate { (i, t) -> i to t })
    println(menu)
    println(todos.fold(0) { sum, t -> sum + t.length })
    println((todos + "睡覺").size)

    // 要惰性求值得明確轉成 Sequence
    val lazy = todos.asSequence().map {
        println("map $it")
        it
    }
    println("還沒執行 map")
    println(lazy.first())
}
// [/snippet]
