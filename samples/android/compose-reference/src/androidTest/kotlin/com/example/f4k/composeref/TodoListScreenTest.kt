package com.example.f4k.composeref

import androidx.compose.ui.test.isToggleable
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onFirst
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Rule
import org.junit.Test

// [snippet:test-widget]
class TodoListScreenTest {
    @get:Rule val composeTestRule = createComposeRule()

    @Test
    fun 勾選待辦後剩餘數量減少() {
        composeTestRule.setContent {
            TodoListScreen(viewModel = TodoViewModel(FakeTodoRepository()), onOpen = {})
        }
        composeTestRule.onNodeWithText("待辦清單（剩 2 項）").assertExists()

        composeTestRule.onAllNodes(isToggleable()).onFirst().performClick()

        // 測試規則會自動等 UI 閒置，不需要手動 pump
        composeTestRule.onNodeWithText("待辦清單（剩 1 項）").assertExists()
    }
}
// [/snippet]
