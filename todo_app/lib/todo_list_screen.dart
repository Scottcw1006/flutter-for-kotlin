import 'package:flutter/material.dart';

import 'todo.dart';
import 'widgets/todo_tile.dart';

/// 待辦清單主畫面。目前狀態放在 State 物件裡（對應 Compose 的 remember），
/// 第 4 章會把它搬到狀態管理層（對應 ViewModel）。
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _input = TextEditingController();
  var _nextId = 3;
  var _todos = const [
    Todo(id: 0, title: '讀完第 3 章'),
    Todo(id: 1, title: '把 Modifier 改寫成 Widget'),
    Todo(id: 2, title: '安裝 Flutter SDK', done: true),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final title = _input.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _todos = [..._todos, Todo(id: _nextId++, title: title)];
      _input.clear();
    });
  }

  void _toggle(Todo todo) => setState(() {
        _todos = [
          for (final t in _todos) t.id == todo.id ? t.copyWith(done: !t.done) : t,
        ];
      });

  void _delete(Todo todo) =>
      setState(() => _todos = _todos.where((t) => t.id != todo.id).toList());

  @override
  Widget build(BuildContext context) {
    final remaining = _todos.where((t) => !t.done).length;
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
          Expanded(
            child: ListView(
              children: [
                for (final todo in _todos)
                  TodoTile(
                    key: ValueKey(todo.id),
                    todo: todo,
                    onToggle: () => _toggle(todo),
                    onDelete: () => _delete(todo),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
