import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config.dart';
import 'data/drift_todo_repository.dart';
import 'data/todo_repository.dart';
import 'router.dart';

// [snippet:todo-main]
void main() {
  runApp(
    ProviderScope(
      // 在這裡決定 Repository 的實作，相當於 Hilt 的 @Module
      observers: [if (AppConfig.enableLogging) LoggingObserver()],
      overrides: [
        todoRepositoryProvider.overrideWithValue(DriftTodoRepository(AppDatabase())),
      ],
      child: const TodoApp(),
    ),
  );
}
// [/snippet]

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      title: '待辦清單',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      routerConfig: _router,
    );
    // [snippet:flavor-banner]
    // dev 版在左上角加上標記，一眼就能分辨裝的是哪個版本
    if (!AppConfig.isDev) return app;
    return Banner(
      message: 'DEV',
      location: BannerLocation.topStart,
      textDirection: TextDirection.ltr,
      layoutDirection: TextDirection.ltr,
      child: app,
    );
    // [/snippet]
  }
}
