import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/data/drift_todo_repository.dart';
import 'package:todo_app/data/todo_repository.dart';
import 'package:todo_app/main.dart' show TodoApp;
import 'package:todo_app/todo_list_notifier.dart';

// Flutter 模組的進入點：Android 宿主啟動 FlutterEngine 時執行這個 main()。
// 待辦清單的畫面直接沿用 todo_app 套件，這裡只多包一層與宿主溝通的 HostBridge。
// [snippet:a2a-module-main]
void main() {
  runApp(
    ProviderScope(
      overrides: [
        todoRepositoryProvider.overrideWithValue(DriftTodoRepository(AppDatabase())),
      ],
      child: const HostBridge(child: TodoApp()),
    ),
  );
}

/// 把「剩餘待辦數」回報給 Android 宿主，讓原生畫面也能顯示
class HostBridge extends ConsumerStatefulWidget {
  const HostBridge({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HostBridge> createState() => _HostBridgeState();
}

class _HostBridgeState extends ConsumerState<HostBridge> {
  static const _channel = MethodChannel('f4k/host');

  @override
  void initState() {
    super.initState();
    // listenManual 會隨 State 自動取消訂閱；fireImmediately 讓宿主一開始就拿到目前的值
    ref.listenManual(remainingCountProvider, (_, count) {
      _channel.invokeMethod('remainingChanged', count);
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
// [/snippet]
