import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../todo_list_notifier.dart';
import '../widgets/todo_tile.dart';

// [snippet:todo-screen]
/// 待辦清單主畫面。狀態都在 TodoListNotifier 裡，這裡只負責顯示和轉送事件，
/// 就像 Composable 從 ViewModel collect 狀態、把點擊交給 ViewModel 處理。
class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    ref.read(todoListProvider.notifier).add(_input.text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoListProvider);
    final remaining = ref.watch(remainingCountProvider);
    final notifier = ref.read(todoListProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text('待辦清單（剩 $remaining 項）')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(hintText: '新增待辦…'),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), tooltip: '新增', onPressed: _add),
              ],
            ),
          ),
          // [snippet:todo-list]
          Expanded(
            child: switch (todos) {
              AsyncData(value: final items) => ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final todo = items[index];
                    return TodoTile(
                      key: ValueKey(todo.id),
                      todo: todo,
                      onToggle: () => notifier.toggle(todo),
                      onOpen: () => context.push('/todo/${todo.id}'),
                      onDelete: () => notifier.delete(todo),
                    );
                  },
                ),
              AsyncError(:final error) => Center(child: Text('載入失敗：$error')),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
          // [/snippet]
        ],
      ),
    );
  }
}
// [/snippet]
