import 'package:flutter/material.dart';

import '../todo.dart';

// [snippet:todo-tile]
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onToggle,
      leading: Checkbox(value: todo.done, onChanged: (_) => onToggle()),
      title: Text(
        todo.title,
        style: todo.done
            ? theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.outline,
              )
            : theme.textTheme.bodyLarge,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: '刪除',
        onPressed: onDelete,
      ),
    );
  }
}
// [/snippet]
