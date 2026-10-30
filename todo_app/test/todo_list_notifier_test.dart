import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/in_memory_todo_repository.dart';
import 'package:todo_app/data/todo_repository.dart';
import 'package:todo_app/todo_list_notifier.dart';

// [snippet:test-notifier]
void main() {
  // 每個測試建立自己的 ProviderContainer，不需要任何 widget
  ProviderContainer createContainer() {
    final container = ProviderContainer.test(
      overrides: [todoRepositoryProvider.overrideWithValue(InMemoryTodoRepository())],
    );
    // 沒有人監聽的 provider 會暫停，測試時要先訂閱，相當於 Turbine 的 test { } 開始收集
    container.listen(todoListProvider, (_, _) {});
    return container;
  }

  test('新增待辦後，剩餘數量會增加', () async {
    final container = createContainer();
    // 等 Stream 的第一筆資料，相當於 Turbine 的 awaitItem()
    await container.read(todoListProvider.future);
    expect(container.read(remainingCountProvider), 2);

    await container.read(todoListProvider.notifier).add('寫測試');
    await container.pump(); // 等 Stream 把新的清單送進 Notifier

    expect(container.read(remainingCountProvider), 3);
    expect(container.read(todoListProvider).value!.last.title, '寫測試');
  });

  test('空白標題不會新增', () async {
    final container = createContainer();
    await container.read(todoListProvider.future);

    await container.read(todoListProvider.notifier).add('   ');
    await container.pump();

    expect(container.read(todoListProvider).value, hasLength(3));
  });
}
// [/snippet]
