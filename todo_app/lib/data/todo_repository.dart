import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo.dart';

// [snippet:todo-repository]
abstract interface class TodoRepository {
  Stream<List<Todo>> watchAll();
  Future<void> add(String title);
  Future<void> setDone(int id, bool done);
  Future<void> rename(int id, String title);
  Future<void> delete(int id);
}

/// 實際的實作由 App 進入點透過 ProviderScope 的 overrides 提供：
/// App 用 drift，測試和網站 demo 用記憶體版本。
/// 相當於 Hilt 在不同的 module 綁定不同的實作。
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => throw UnimplementedError('請在 ProviderScope 的 overrides 提供 TodoRepository'),
);
// [/snippet]
