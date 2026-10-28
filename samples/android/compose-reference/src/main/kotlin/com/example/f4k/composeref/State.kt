package com.example.f4k.composeref

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

// 第 4 章「ViewModel 與狀態管理」左欄的 Kotlin 代碼，與 site/lib/demos/state_demos.dart 對應

// [snippet:state-viewmodel]
class CounterViewModel : ViewModel() {
    private val _count = MutableStateFlow(0) // 初始狀態
    val count: StateFlow<Int> = _count.asStateFlow()

    fun increment() = _count.update { it + 1 }
    fun reset() { _count.value = 0 }
}

@Composable
fun CounterScreen(viewModel: CounterViewModel = viewModel()) {
    val count by viewModel.count.collectAsStateWithLifecycle()
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // 狀態由畫面往下傳，事件往上交給 ViewModel
        CounterLabel(count)
        CounterButtons(onReset = viewModel::reset, onIncrement = viewModel::increment)
    }
}

@Composable
fun CounterLabel(count: Int) {
    Text("$count", style = MaterialTheme.typography.displayMedium)
}

@Composable
fun CounterButtons(onReset: () -> Unit, onIncrement: () -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        OutlinedButton(onClick = onReset) { Text("歸零") }
        Button(onClick = onIncrement) { Text("+1") }
    }
}
// [/snippet]

// [snippet:state-derived]
val cities = listOf("台北", "新北", "桃園", "台中", "台南", "高雄", "基隆", "新竹", "嘉義", "花蓮", "台東", "宜蘭")

class CitySearchViewModel : ViewModel() {
    private val query = MutableStateFlow("")

    // 衍生狀態：query 變了就重新計算
    val results: StateFlow<List<String>> = query
        .map { q -> cities.filter { it.contains(q) } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), cities)

    fun onQueryChange(q: String) {
        query.value = q
    }
}

@Composable
fun CitySearch(viewModel: CitySearchViewModel = viewModel()) {
    var text by rememberSaveable { mutableStateOf("") }
    val results by viewModel.results.collectAsStateWithLifecycle()
    Column {
        TextField(
            value = text,
            onValueChange = { text = it; viewModel.onQueryChange(it) },
            placeholder = { Text("搜尋城市，例如「台」") },
            modifier = Modifier.fillMaxWidth().padding(12.dp),
        )
        LazyColumn {
            items(results) { city -> ListItem(headlineContent = { Text(city) }) }
        }
    }
}
// [/snippet]

// [snippet:state-async]
sealed interface WeatherUiState {
    data object Loading : WeatherUiState
    data class Success(val text: String) : WeatherUiState
    data class Error(val message: String) : WeatherUiState
}

class WeatherViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<WeatherUiState>(WeatherUiState.Loading)
    val uiState: StateFlow<WeatherUiState> = _uiState.asStateFlow()

    private val _simulateError = MutableStateFlow(false)
    val simulateError: StateFlow<Boolean> = _simulateError.asStateFlow()

    private var loadJob: Job? = null

    init { refresh() }

    fun toggleSimulateError() {
        _simulateError.update { !it }
        refresh()
    }

    fun refresh() {
        loadJob?.cancel() // 取消還在跑的舊請求，避免舊結果蓋掉新結果
        loadJob = viewModelScope.launch {
            _uiState.value = WeatherUiState.Loading
            delay(1_000)
            _uiState.value = if (_simulateError.value) {
                WeatherUiState.Error("連線逾時")
            } else {
                WeatherUiState.Success("台北 23°C，多雲")
            }
        }
    }
}

@Composable
fun WeatherCard(viewModel: WeatherViewModel = viewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    val simulateError by viewModel.simulateError.collectAsStateWithLifecycle()
    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        ListItem(
            headlineContent = { Text("模擬連線失敗") },
            trailingContent = {
                Switch(checked = simulateError, onCheckedChange = { viewModel.toggleSimulateError() })
            },
        )
        Box(Modifier.fillMaxWidth().height(64.dp), contentAlignment = Alignment.Center) {
            when (val s = state) {
                WeatherUiState.Loading -> CircularProgressIndicator()
                is WeatherUiState.Success -> Text(s.text, style = MaterialTheme.typography.titleLarge)
                is WeatherUiState.Error -> Text("錯誤：${s.message}", color = MaterialTheme.colorScheme.error)
            }
        }
        Button(onClick = viewModel::refresh, modifier = Modifier.fillMaxWidth()) { Text("重新整理") }
    }
}
// [/snippet]
