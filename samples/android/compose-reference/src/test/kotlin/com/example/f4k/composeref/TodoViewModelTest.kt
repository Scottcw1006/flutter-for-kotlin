package com.example.f4k.composeref

import app.cash.turbine.test
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

// [snippet:test-notifier]
@OptIn(ExperimentalCoroutinesApi::class)
class TodoViewModelTest {
    // viewModelScope 用的是 Dispatchers.Main，測試時要換掉
    @Before fun setUp() = Dispatchers.setMain(UnconfinedTestDispatcher())
    @After fun tearDown() = Dispatchers.resetMain()

    @Test
    fun `新增待辦後，剩餘數量會增加`() = runTest {
        val viewModel = TodoViewModel(FakeTodoRepository())
        viewModel.remainingCount.test {
            // stateIn 的初始值是 0，等 Repository 的第一筆資料
            assertEquals(2, awaitItem().takeIf { it != 0 } ?: awaitItem())
            viewModel.add("寫測試")
            assertEquals(3, awaitItem())
        }
    }

    @Test
    fun `空白標題不會新增`() = runTest {
        val viewModel = TodoViewModel(FakeTodoRepository())
        viewModel.todos.test {
            val before = awaitItem().takeIf { it.isNotEmpty() } ?: awaitItem()
            viewModel.add("   ")
            expectNoEvents()
            assertEquals(3, before.size)
        }
    }
}
// [/snippet]
