import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/in_memory_todo_repository.dart';
import 'package:todo_app/data/todo_repository.dart';
import 'package:todo_app/main.dart';

Widget app() => ProviderScope(
      overrides: [todoRepositoryProvider.overrideWithValue(InMemoryTodoRepository())],
      child: const TodoApp(),
    );

void main() {
  testWidgets('新增、勾選、刪除待辦', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('待辦清單（剩 2 項）'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '寫測試');
    await tester.tap(find.byTooltip('新增'));
    await tester.pumpAndSettle();
    expect(find.text('寫測試'), findsOneWidget);
    expect(find.text('待辦清單（剩 3 項）'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    expect(find.text('待辦清單（剩 2 項）'), findsOneWidget);

    await tester.tap(find.byTooltip('刪除').last);
    await tester.pumpAndSettle();
    expect(find.text('寫測試'), findsNothing);
  });

  testWidgets('進入詳細頁修改標題', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('讀完第 4 章'));
    await tester.pumpAndSettle();
    expect(find.text('編輯待辦'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '讀完第 4 章與第 5 章');
    await tester.tap(find.text('儲存'));
    await tester.pumpAndSettle();

    expect(find.text('編輯待辦'), findsNothing);
    expect(find.text('讀完第 4 章與第 5 章'), findsOneWidget);
  });
}
