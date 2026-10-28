package com.example.f4k.composeref

import android.app.Application
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import androidx.room.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable

// 第 4 章待辦 App 架構的 Kotlin 對照，與 todo_app/lib 的 Repository、Notifier、drift、go_router 對應

// [snippet:todo-repository]
interface TodoRepository {
    fun watchAll(): Flow<List<Todo>>
    suspend fun add(title: String)
    suspend fun setDone(id: Int, done: Boolean)
    suspend fun rename(id: Int, title: String)
    suspend fun delete(id: Int)
}
// [/snippet]

// [snippet:todo-notifier]
class TodoViewModel(private val repository: TodoRepository) : ViewModel() {
    // 狀態來自 Repository 的 Flow，資料庫一變就自動更新
    val todos: StateFlow<List<Todo>> = repository.watchAll()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    // 衍生狀態：還剩幾項沒完成
    val remainingCount: StateFlow<Int> = todos
        .map { list -> list.count { !it.done } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), 0)

    fun add(title: String) {
        val trimmed = title.trim()
        if (trimmed.isEmpty()) return
        viewModelScope.launch { repository.add(trimmed) }
    }

    fun toggle(todo: Todo) = viewModelScope.launch { repository.setDone(todo.id, !todo.done) }

    fun rename(todo: Todo, title: String) = viewModelScope.launch { repository.rename(todo.id, title.trim()) }

    fun delete(todo: Todo) = viewModelScope.launch { repository.delete(todo.id) }
}
// [/snippet]

// [snippet:todo-drift-db]
@Entity(tableName = "todo_items")
data class TodoEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val title: String,
    val done: Boolean = false,
)

@Dao
interface TodoDao {
    @Query("SELECT * FROM todo_items")
    fun watchAll(): Flow<List<TodoEntity>>

    @Insert
    suspend fun insert(todo: TodoEntity)

    @Query("UPDATE todo_items SET done = :done WHERE id = :id")
    suspend fun setDone(id: Int, done: Boolean)

    @Query("UPDATE todo_items SET title = :title WHERE id = :id")
    suspend fun rename(id: Int, title: String)

    @Query("DELETE FROM todo_items WHERE id = :id")
    suspend fun delete(id: Int)
}

@Database(entities = [TodoEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun todoDao(): TodoDao
}
// [/snippet]

// [snippet:todo-drift-repo]
class RoomTodoRepository(private val dao: TodoDao) : TodoRepository {
    override fun watchAll(): Flow<List<Todo>> = dao.watchAll().map { rows ->
        rows.map { Todo(id = it.id, title = it.title, done = it.done) }
    }

    override suspend fun add(title: String) = dao.insert(TodoEntity(title = title))

    override suspend fun setDone(id: Int, done: Boolean) = dao.setDone(id, done)

    override suspend fun rename(id: Int, title: String) = dao.rename(id, title)

    override suspend fun delete(id: Int) = dao.delete(id)
}
// [/snippet]

// [snippet:todo-main]
// 不用 Hilt 時的手動依賴注入：在 Application 建立 Repository，再交給 ViewModel factory
class TodoApplication : Application() {
    val repository: TodoRepository by lazy {
        val db = Room.databaseBuilder(this, AppDatabase::class.java, "todo").build()
        RoomTodoRepository(db.todoDao())
    }
}

fun todoViewModelFactory(app: TodoApplication): ViewModelProvider.Factory = viewModelFactory {
    initializer { TodoViewModel(app.repository) }
}
// [/snippet]

// [snippet:todo-router]
@Serializable
object TodoListRoute

@Serializable
data class TodoDetailRoute(val id: Int)

@Composable
fun TodoNavHost(viewModel: TodoViewModel) {
    val navController = rememberNavController()
    NavHost(navController, startDestination = TodoListRoute) {
        composable<TodoListRoute> {
            TodoListScreen(viewModel, onOpen = { todo -> navController.navigate(TodoDetailRoute(todo.id)) })
        }
        composable<TodoDetailRoute> { entry ->
            val route = entry.toRoute<TodoDetailRoute>()
            TodoDetailScreen(route.id, viewModel, onSaved = { navController.popBackStack() })
        }
    }
}
// [/snippet]

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TodoListScreen(viewModel: TodoViewModel, onOpen: (Todo) -> Unit) {
    val todos by viewModel.todos.collectAsStateWithLifecycle()
    val remaining by viewModel.remainingCount.collectAsStateWithLifecycle()
    Scaffold(topBar = { TopAppBar(title = { Text("待辦清單（剩 $remaining 項）") }) }) { padding ->
        TodoList(
            todos = todos,
            onToggle = viewModel::toggle,
            onOpen = onOpen,
            onDelete = viewModel::delete,
            modifier = Modifier.padding(padding),
        )
    }
}

@Composable
fun TodoDetailScreen(id: Int, viewModel: TodoViewModel, onSaved: () -> Unit) {
    val todo = viewModel.todos.collectAsStateWithLifecycle().value.firstOrNull { it.id == id } ?: return
    var title by remember(todo.id) { mutableStateOf(todo.title) }
    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        TextField(value = title, onValueChange = { title = it }, label = { Text("標題") })
        Button(onClick = { viewModel.rename(todo, title); onSaved() }) { Text("儲存") }
    }
}
