package com.example.f4k.composeref

import androidx.compose.foundation.clickable
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material3.Checkbox
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextDecoration

data class Todo(val id: Int, val title: String, val done: Boolean = false)

// [snippet:todo-tile]
@Composable
fun TodoItem(todo: Todo, onToggle: () -> Unit, onDelete: () -> Unit) {
    ListItem(
        modifier = Modifier.clickable(onClick = onToggle),
        leadingContent = {
            Checkbox(checked = todo.done, onCheckedChange = { onToggle() })
        },
        headlineContent = {
            Text(
                todo.title,
                style = if (todo.done) {
                    MaterialTheme.typography.bodyLarge.copy(
                        textDecoration = TextDecoration.LineThrough,
                        color = MaterialTheme.colorScheme.outline,
                    )
                } else {
                    MaterialTheme.typography.bodyLarge
                },
            )
        },
        trailingContent = {
            IconButton(onClick = onDelete) {
                Icon(Icons.Outlined.Delete, contentDescription = "刪除")
            }
        },
    )
}
// [/snippet]

// [snippet:todo-list]
@Composable
fun TodoList(
    todos: List<Todo>,
    onToggle: (Todo) -> Unit,
    onDelete: (Todo) -> Unit,
    modifier: Modifier = Modifier,
) {
    LazyColumn(modifier) {
        items(todos, key = { it.id }) { todo ->
            TodoItem(
                todo = todo,
                onToggle = { onToggle(todo) },
                onDelete = { onDelete(todo) },
            )
        }
    }
}
// [/snippet]
