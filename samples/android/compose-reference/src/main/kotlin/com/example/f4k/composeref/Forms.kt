package com.example.f4k.composeref

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp

// 第 3 章「文字輸入與表單」的 Compose 對照，與 site/lib/demos/form_demos.dart 對應

// [snippet:form-controller]
@Composable
fun TextInputDemo() {
    // 文字存在你自己的 state 裡（state hoisting），TextField 只負責顯示與回報
    var text by rememberSaveable { mutableStateOf("") }
    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        OutlinedTextField(
            value = text,
            onValueChange = { text = it },
            label = { Text("輸入一些文字") },
            modifier = Modifier.fillMaxWidth(),
        )
        Text("${text.length} 個字")
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedButton(onClick = { text = text.uppercase() }) { Text("轉大寫") }
            OutlinedButton(onClick = { text = "" }) { Text("清除") }
        }
    }
}
// [/snippet]

// [snippet:form-validate]
@Composable
fun SignUpForm() {
    var name by rememberSaveable { mutableStateOf("") }
    var email by rememberSaveable { mutableStateOf("") }
    var submitted by remember { mutableStateOf(false) }
    val emailFocus = remember { FocusRequester() }

    // 驗證規則自己寫，錯誤訊息透過 isError / supportingText 顯示
    val nameError = if (submitted && name.isBlank()) "請輸入名稱" else null
    val emailError = if (submitted && !email.contains("@")) "Email 格式不正確" else null

    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("名稱") },
            isError = nameError != null,
            supportingText = { nameError?.let { Text(it) } },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
            keyboardActions = KeyboardActions(onNext = { emailFocus.requestFocus() }),
            modifier = Modifier.fillMaxWidth(),
        )
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            isError = emailError != null,
            supportingText = { emailError?.let { Text(it) } },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email, imeAction = ImeAction.Done),
            modifier = Modifier.fillMaxWidth().focusRequester(emailFocus),
        )
        Button(onClick = { submitted = true }) { Text("送出") }
    }
}
// [/snippet]
