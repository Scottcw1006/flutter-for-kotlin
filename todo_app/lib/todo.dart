/// 一筆待辦事項。不可變（immutable），要修改就用 [copyWith] 產生新的物件，
/// 等同 Kotlin `data class` 搭配 `copy()` 的寫法。
class Todo {
  const Todo({required this.id, required this.title, this.done = false});

  final int id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(id: id, title: title ?? this.title, done: done ?? this.done);
}
