import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:todo_app/todo_list_screen.dart';

import 'demos/dart_async_demos.dart';
import 'demos/dart_syntax_demos.dart';
import 'demos/runner.dart';
import 'demos/ui_basics_demos.dart';

// 網頁上 data-demo="<id>" 對應到的 Widget
final Map<String, WidgetBuilder> demos = {
  'syntax-variables': (_) => const RunnerDemo(run: variables),
  'syntax-functions': (_) => const RunnerDemo(run: functions),
  'syntax-null': (_) => const RunnerDemo(run: nullSafety),
  'syntax-classes': (_) => const RunnerDemo(run: classes),
  'syntax-sealed': (_) => const RunnerDemo(run: sealedClasses),
  'syntax-collections': (_) => const RunnerDemo(run: collections),
  'async-future': (_) => const RunnerDemo(run: futures),
  'async-errors': (_) => const RunnerDemo(run: errors),
  'async-stream': (_) => const RunnerDemo(run: streams),
  'async-ui': (_) => const CountdownDemo(),
  'async-isolate': (_) => const RunnerDemo(run: heavyWork),
  'ui-first-widget': (_) => const GreetingDemo(),
  'ui-column-row': (_) => const ContactsDemo(),
  'ui-modifier': (_) => const ModifierDemo(),
  'ui-state': (_) => const Counter(),
  'todo-tile': (_) => const TodoListScreen(),
};

/// flutter_bootstrap.js 呼叫 `app.addView({ hostElement, initialData })` 時傳入的資料
extension type DemoViewData._(JSObject _) implements JSObject {
  external String get demoId;

  /// 頁面原本的標題。MaterialApp 會把 title 寫進 document.title，所以要傳回原值
  external String get pageTitle;
}

// 每個 demo 是頁面上一個獨立的 FlutterView（multi-view embedding），
// 所以不用 runApp，而是用 runWidget 搭配 ViewCollection 管理所有 view。
void main() => runWidget(const MultiViewApp());

class MultiViewApp extends StatefulWidget {
  const MultiViewApp({super.key});

  @override
  State<MultiViewApp> createState() => _MultiViewAppState();
}

class _MultiViewAppState extends State<MultiViewApp> with WidgetsBindingObserver {
  Map<int, Widget> _views = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateViews();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 頁面新增或移除 view 時會觸發
  @override
  void didChangeMetrics() => _updateViews();

  void _updateViews() {
    final views = <int, Widget>{};
    for (final view in WidgetsBinding.instance.platformDispatcher.views) {
      views[view.viewId] = _views[view.viewId] ??
          View(
            view: view,
            child: DemoHost(data: _dataOf(view.viewId)),
          );
    }
    setState(() => _views = views);
  }

  DemoViewData _dataOf(int viewId) => ui_web.views.getInitialData(viewId) as DemoViewData;

  @override
  Widget build(BuildContext context) => ViewCollection(views: _views.values.toList());
}

class DemoHost extends StatelessWidget {
  const DemoHost({super.key, required this.data});

  final DemoViewData data;

  @override
  Widget build(BuildContext context) {
    final builder = demos[data.demoId];
    return MaterialApp(
      title: data.pageTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: builder != null
          ? Scaffold(body: Builder(builder: builder))
          : Center(child: Text('Unknown demo: ${data.demoId}')),
    );
  }
}
