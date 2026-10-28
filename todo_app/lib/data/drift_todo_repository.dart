import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'todo.dart';
import 'todo_repository.dart';

part 'drift_todo_repository.g.dart';

// [snippet:todo-drift-db]
@DataClassName('TodoRow')
class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'todo'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          for (final todo in sampleTodos) {
            await into(todoItems).insert(
              TodoItemsCompanion.insert(title: todo.title, done: Value(todo.done)),
            );
          }
        },
      );
}
// [/snippet]

// [snippet:todo-drift-repo]
class DriftTodoRepository implements TodoRepository {
  DriftTodoRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Todo>> watchAll() => _db.select(_db.todoItems).watch().map(
        (rows) => [
          for (final row in rows) Todo(id: row.id, title: row.title, done: row.done),
        ],
      );

  @override
  Future<void> add(String title) =>
      _db.into(_db.todoItems).insert(TodoItemsCompanion.insert(title: title));

  @override
  Future<void> setDone(int id, bool done) =>
      (_db.update(_db.todoItems)..where((t) => t.id.equals(id)))
          .write(TodoItemsCompanion(done: Value(done)));

  @override
  Future<void> rename(int id, String title) =>
      (_db.update(_db.todoItems)..where((t) => t.id.equals(id)))
          .write(TodoItemsCompanion(title: Value(title)));

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.todoItems)..where((t) => t.id.equals(id))).go();
}
// [/snippet]
