import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/todo.dart';
import 'data/todo_repository.dart';

// [snippet:todo-notifier]
final todoListProvider =
    StreamNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

class TodoListNotifier extends StreamNotifier<List<Todo>> {
  TodoRepository get _repository => ref.read(todoRepositoryProvider);

  // 狀態來自 Repository 的 Stream，資料庫一變就自動更新
  @override
  Stream<List<Todo>> build() => ref.watch(todoRepositoryProvider).watchAll();

  Future<void> add(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _repository.add(trimmed);
  }

  Future<void> toggle(Todo todo) => _repository.setDone(todo.id, !todo.done);

  Future<void> rename(Todo todo, String title) =>
      _repository.rename(todo.id, title.trim());

  Future<void> delete(Todo todo) => _repository.delete(todo.id);
}

/// 衍生狀態：還剩幾項沒完成，相當於在 ViewModel 裡用 map 轉出來的 StateFlow
final remainingCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoListProvider).value ?? const [];
  return todos.where((t) => !t.done).length;
});
// [/snippet]
