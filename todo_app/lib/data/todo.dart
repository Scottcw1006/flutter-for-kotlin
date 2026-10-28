import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

// [snippet:todo-model]
/// 一筆待辦事項。freezed 會產生 copyWith、==、hashCode、toString，
/// json_serializable 產生 fromJson / toJson，效果等同 Kotlin 的
/// `@Serializable data class`。
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required int id,
    required String title,
    @Default(false) bool done,
  }) = _Todo;

  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);
}
// [/snippet]

/// 第一次開啟 App（或網站 demo）時的預設資料
const sampleTodos = [
  Todo(id: 0, title: '讀完第 4 章'),
  Todo(id: 1, title: '把 ViewModel 改寫成 Notifier'),
  Todo(id: 2, title: '安裝 Flutter SDK', done: true),
];
