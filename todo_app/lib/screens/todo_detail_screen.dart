import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../todo_list_notifier.dart';

// [snippet:todo-detail]
class TodoDetailScreen extends ConsumerStatefulWidget {
  const TodoDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends ConsumerState<TodoDetailScreen> {
  late final _title = TextEditingController(
    text: ref.read(todoListProvider).value?.where((t) => t.id == widget.id).firstOrNull?.title,
  );

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todo = ref.watch(
      todoListProvider.select(
        (todos) => todos.value?.where((t) => t.id == widget.id).firstOrNull,
      ),
    );
    if (todo == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('找不到這筆待辦')));
    }
    final notifier = ref.read(todoListProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('編輯待辦')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: '標題'),
            ),
            SwitchListTile(
              title: const Text('已完成'),
              value: todo.done,
              onChanged: (_) => notifier.toggle(todo),
            ),
            FilledButton(
              onPressed: () async {
                await notifier.rename(todo, _title.text);
                if (context.mounted) context.pop();
              },
              child: const Text('儲存'),
            ),
          ],
        ),
      ),
    );
  }
}
// [/snippet]
