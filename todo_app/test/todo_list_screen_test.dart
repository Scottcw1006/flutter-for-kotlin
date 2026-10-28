import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('新增、勾選、刪除待辦', (tester) async {
    await tester.pumpWidget(const TodoApp());
    expect(find.text('待辦清單（剩 2 項）'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '寫測試');
    await tester.tap(find.byTooltip('新增'));
    await tester.pump();
    expect(find.text('寫測試'), findsOneWidget);
    expect(find.text('待辦清單（剩 3 項）'), findsOneWidget);

    await tester.tap(find.text('寫測試'));
    await tester.pump();
    expect(find.text('待辦清單（剩 2 項）'), findsOneWidget);

    await tester.tap(find.byTooltip('刪除').last);
    await tester.pump();
    expect(find.text('寫測試'), findsNothing);
  });
}
