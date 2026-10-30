package com.example.f4k.composeref

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import coil3.compose.SubcomposeAsyncImage

// 第 3 章「圖片、資源與多語系」的 Compose 對照，與 site/lib/demos/asset_demos.dart 對應

// [snippet:images]
private const val IMAGE_URL =
    "https://raw.githubusercontent.com/Scottcw1006/flutter-for-kotlin/main/site/web/img/flavor-launcher.png"

@Composable
fun ImagesDemo() {
    var broken by remember { mutableStateOf(false) }
    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("打包在 App 裡的圖片")
        // res/drawable-mdpi、-xhdpi、-xxhdpi 各放一張，系統依螢幕密度選用
        Image(painterResource(R.drawable.app_icon), contentDescription = null, Modifier.size(48.dp))
        Text(if (broken) "網路圖片（故意用錯誤的網址）" else "網路圖片")
        // Coil 負責下載、快取與解碼
        SubcomposeAsyncImage(
            model = if (broken) "$IMAGE_URL-not-found" else IMAGE_URL,
            contentDescription = null,
            contentScale = ContentScale.Fit,
            alignment = Alignment.CenterStart,
            loading = { CircularProgressIndicator() },
            error = { Text("載入失敗") },
            modifier = Modifier.fillMaxWidth().height(110.dp),
        )
        OutlinedButton(onClick = { broken = !broken }) { Text(if (broken) "改回正確網址" else "改用錯誤網址") }
    }
}
// [/snippet]

// [snippet:i18n-usage]
@Composable
fun CartSummary(count: Int) {
    Column {
        Text(stringResource(R.string.cart_title), style = MaterialTheme.typography.titleLarge)
        Text(stringResource(R.string.greeting, "Kotlin 開發者"))
        // 中文的 plurals 沒有「0」這個類別，要自己判斷
        Text(
            if (count == 0) stringResource(R.string.cart_empty)
            else pluralStringResource(R.plurals.items_in_cart, count, count),
        )
    }
}
// [/snippet]

