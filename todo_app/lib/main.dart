import 'package:flutter/material.dart';

import 'todo_list_screen.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '待辦清單',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const TodoListScreen(),
    );
  }
}
