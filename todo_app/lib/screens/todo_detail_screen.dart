import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/todo.dart';
import '../todo_list_notifier.dart';

// [snippet:todo-detail]
/// 外層：等資料載入完成，找到這一筆之後才建立表單
class TodoDetailScreen extends ConsumerWidget {
  const TodoDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 用 select 只挑出自己那一筆，其他項目變動時不會重建
    final todo = ref.watch(
      todoListProvider.select(
        (todos) => todos.whenData((list) => list.where((t) => t.id == id).firstOrNull),
      ),
    );
    return switch (todo) {
      AsyncData(value: final todo?) => TodoEditForm(todo: todo),
      AsyncData() => _message('找不到這筆待辦'),
      AsyncError(:final error) => _message('讀取失敗：$error'),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }

  Widget _message(String text) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text(text)));
}

/// 內層：拿到資料後才建立 controller，初始值一定是正確的標題
class TodoEditForm extends ConsumerStatefulWidget {
  const TodoEditForm({super.key, required this.todo});

  final Todo todo;

  @override
  ConsumerState<TodoEditForm> createState() => _TodoEditFormState();
}

class _TodoEditFormState extends ConsumerState<TodoEditForm> {
  late final _title = TextEditingController(text: widget.todo.title);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // 切換完成狀態時，外層會帶著新的 todo 重建這個 widget；
            // controller 是 State 的一部分，使用者正在輸入的標題不會被蓋掉
            SwitchListTile(
              title: const Text('已完成'),
              value: widget.todo.done,
              onChanged: (_) => notifier.toggle(widget.todo),
            ),
            FilledButton(
              onPressed: () async {
                await notifier.rename(widget.todo, _title.text);
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
