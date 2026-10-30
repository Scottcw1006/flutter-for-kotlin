import 'dart:async';

import 'todo.dart';
import 'todo_repository.dart';

/// 存在記憶體裡的 TodoRepository，給測試和網站 demo 使用（瀏覽器裡沒有 SQLite）
class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository([List<Todo> initial = sampleTodos])
      : _todos = [...initial],
        _nextId = initial.length;

  List<Todo> _todos;
  int _nextId;
  final _changes = StreamController<List<Todo>>.broadcast();

  void _emit(List<Todo> todos) {
    _todos = todos;
    _changes.add(todos);
  }

  @override
  Stream<List<Todo>> watchAll() {
    // 先開始監聽變更，再送出目前的清單；
    // 反過來寫的話，兩者之間發生的修改會被漏掉
    final controller = StreamController<List<Todo>>();
    final subscription = _changes.stream.listen(controller.add);
    controller
      ..onCancel = subscription.cancel
      ..add(_todos);
    return controller.stream;
  }

  @override
  Future<void> add(String title) async =>
      _emit([..._todos, Todo(id: _nextId++, title: title)]);

  @override
  Future<void> setDone(int id, bool done) async =>
      _emit([for (final t in _todos) t.id == id ? t.copyWith(done: done) : t]);

  @override
  Future<void> rename(int id, String title) async =>
      _emit([for (final t in _todos) t.id == id ? t.copyWith(title: title) : t]);

  @override
  Future<void> delete(int id) async =>
      _emit(_todos.where((t) => t.id != id).toList());
}
