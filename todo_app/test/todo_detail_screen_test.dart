import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/todo.dart';
import 'package:todo_app/data/todo_repository.dart';
import 'package:todo_app/router.dart';

// [snippet:test-deeplink]
/// 由測試決定什麼時候送出資料，用來模擬「資料還在載入」
class SlowTodoRepository implements TodoRepository {
  final _todos = StreamController<List<Todo>>();

  void load(List<Todo> todos) => _todos.add(todos);

  @override
  Stream<List<Todo>> watchAll() => _todos.stream;

  // 這個測試用不到的方法
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  testWidgets('直接開啟編輯頁：先顯示載入中，資料到了再填入標題', (tester) async {
    final repository = SlowTodoRepository();
    // 模擬從 deep link 直接進入 /todo/1
    final router = createRouter()..go('/todo/1');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('找不到這筆待辦'), findsNothing);

    repository.load(sampleTodos);
    await tester.pumpAndSettle();

    // 標題欄填入的是 id 1 的標題，而不是空的
    expect(find.widgetWithText(TextField, '把 ViewModel 改寫成 Notifier'), findsOneWidget);
  });
}
// [/snippet]
