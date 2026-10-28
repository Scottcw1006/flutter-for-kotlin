package com.example.f4k.composeref

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Call
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

// [snippet:ui-first-widget]
@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Column(modifier) {
        Text("Hello, $name!", style = MaterialTheme.typography.headlineSmall)
        Text("歡迎來到 Flutter", color = MaterialTheme.colorScheme.primary)
    }
}

@Composable
fun GreetingDemo() {
    Greeting(name = "Kotlin", modifier = Modifier.padding(16.dp))
}
// [/snippet]

// [snippet:ui-column-row]
@Composable
fun ContactRow(name: String, phone: String) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Icon(Icons.Default.AccountCircle, contentDescription = null, Modifier.size(48.dp))
        Column(Modifier.weight(1f)) {
            Text(name, style = MaterialTheme.typography.titleMedium)
            Text(phone, style = MaterialTheme.typography.bodyMedium)
        }
        Icon(Icons.Default.Call, contentDescription = "撥打")
    }
}

@Composable
fun ContactsDemo() {
    Column {
        ContactRow("王小明", "0912-345-678")
        ContactRow("一個名字非常非常長的聯絡人", "0987-654-321")
    }
}
// [/snippet]

// [snippet:ui-modifier]
@Composable
fun ModifierDemo() {
    Column {
        Text(
            "點我看水波紋",
            modifier = Modifier
                .padding(16.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFFB2DFDB))
                .clickable { }
                .padding(horizontal = 24.dp, vertical = 12.dp),
        )
        Text(
            "外距在色塊外，內距在色塊內",
            modifier = Modifier
                .padding(horizontal = 16.dp)
                .background(Color(0xFFFFE0B2), RoundedCornerShape(12.dp))
                .padding(24.dp),
        )
    }
}
// [/snippet]

// [snippet:ui-state]
@Composable
fun Counter() {
    var count by remember { mutableIntStateOf(0) }
    Column(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("$count", style = MaterialTheme.typography.displayMedium)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedButton(onClick = { count-- }) { Text("−1") }
            Button(onClick = { count++ }) { Text("+1") }
        }
    }
}
// [/snippet]
