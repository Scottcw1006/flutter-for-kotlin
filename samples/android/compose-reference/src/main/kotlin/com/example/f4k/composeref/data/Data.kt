package com.example.f4k.composeref.data

import android.content.Context
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import retrofit2.http.GET

// 第 4 章「網路與資料儲存」左欄的 Kotlin 代碼，與 site/lib/demos/data_demos.dart 對應

// [snippet:data-json]
@Serializable
data class User(
    val id: Int,
    val name: String,
    val email: String,
    val address: Address? = null,
)

@Serializable
data class Address(val city: String)

// kotlinx.serialization 預設遇到未知欄位會丟例外，要明確忽略
val json = Json { ignoreUnknownKeys = true }

const val RAW = """{"id": 1, "name": "Leanne Graham", "email": "leanne@example.com",
    "phone": "1-770-736-8031", "address": {"city": "Gwenborough"}}"""

fun jsonDemo() {
    val user = json.decodeFromString<User>(RAW)
    println(user)
    println(user.address?.city)

    val renamed = user.copy(name = "Leanne")
    println(renamed == user)
    println(json.encodeToString(renamed))
}
// [/snippet]

// [snippet:data-http]
interface UserApi {
    @GET("users")
    suspend fun fetchUsers(): List<User>
}

val userApi: UserApi = Retrofit.Builder()
    .baseUrl("https://jsonplaceholder.typicode.com/")
    .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
    .build()
    .create(UserApi::class.java)

sealed interface UsersUiState {
    data object Loading : UsersUiState
    data class Success(val users: List<User>) : UsersUiState
    data class Error(val message: String) : UsersUiState
}

class UserListViewModel(private val api: UserApi = userApi) : ViewModel() {
    private val _uiState = MutableStateFlow<UsersUiState>(UsersUiState.Loading)
    val uiState: StateFlow<UsersUiState> = _uiState.asStateFlow()

    init { load() }

    fun load() {
        viewModelScope.launch {
            _uiState.value = UsersUiState.Loading
            _uiState.value = try {
                UsersUiState.Success(api.fetchUsers())
            } catch (e: Exception) {
                UsersUiState.Error(e.message ?: "未知錯誤")
            }
        }
    }
}

@Composable
fun UserListDemo(viewModel: UserListViewModel = androidx.lifecycle.viewmodel.compose.viewModel()) {
    when (val state = viewModel.uiState.collectAsStateWithLifecycle().value) {
        UsersUiState.Loading -> Box(Modifier.fillMaxSize(), Alignment.Center) { CircularProgressIndicator() }
        is UsersUiState.Error -> Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("載入失敗：${state.message}")
            Button(onClick = viewModel::load) { Text("重試") }
        }
        is UsersUiState.Success -> LazyColumn {
            items(state.users, key = { it.id }) { user ->
                ListItem(
                    leadingContent = { Text("${user.id}") },
                    headlineContent = { Text(user.name) },
                    supportingContent = { Text(user.email) },
                )
            }
        }
    }
}
// [/snippet]

// [snippet:data-prefs]
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")
private val DARK_MODE = booleanPreferencesKey("dark_mode")

class SettingsViewModel(private val dataStore: DataStore<Preferences>) : ViewModel() {
    val darkMode: StateFlow<Boolean> = dataStore.data
        .map { it[DARK_MODE] ?: false }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

    fun toggle() {
        viewModelScope.launch {
            dataStore.edit { it[DARK_MODE] = !(it[DARK_MODE] ?: false) }
        }
    }
}

@Composable
fun SettingsDemo(viewModel: SettingsViewModel) {
    val dark by viewModel.darkMode.collectAsStateWithLifecycle()
    MaterialTheme(colorScheme = if (dark) darkColorScheme() else lightColorScheme()) {
        Surface(Modifier.fillMaxSize()) {
            ListItem(
                headlineContent = { Text("深色模式") },
                supportingContent = { Text("重新開啟 App 後設定仍會保留") },
                trailingContent = { Switch(checked = dark, onCheckedChange = { viewModel.toggle() }) },
            )
        }
    }
}
// [/snippet]
