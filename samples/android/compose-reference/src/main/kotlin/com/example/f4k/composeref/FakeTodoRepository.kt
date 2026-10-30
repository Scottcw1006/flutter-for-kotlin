package com.example.f4k.composeref

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update

/** 存在記憶體裡的假 Repository，給單元測試與 UI 測試共用（相當於 Dart 端的 InMemoryTodoRepository） */
class FakeTodoRepository(
    initial: List<Todo> = listOf(
        Todo(0, "讀完第 4 章"),
        Todo(1, "把 ViewModel 改寫成 Notifier"),
        Todo(2, "安裝 Flutter SDK", done = true),
    ),
) : TodoRepository {
    private val todos = MutableStateFlow(initial)
    private var nextId = initial.size

    override fun watchAll(): Flow<List<Todo>> = todos
    override suspend fun add(title: String) = todos.update { it + Todo(nextId++, title) }
    override suspend fun setDone(id: Int, done: Boolean) =
        todos.update { list -> list.map { if (it.id == id) it.copy(done = done) else it } }
    override suspend fun rename(id: Int, title: String) =
        todos.update { list -> list.map { if (it.id == id) it.copy(title = title) else it } }
    override suspend fun delete(id: Int) = todos.update { list -> list.filterNot { it.id == id } }
}
