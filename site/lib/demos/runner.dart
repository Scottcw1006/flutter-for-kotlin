import 'dart:async';

import 'package:flutter/material.dart';

/// 迷你 console：執行一段會呼叫 print() 的 Dart 程式碼，把輸出逐行顯示在畫面上。
/// 用 Zone 攔截 print，所以 demo 程式碼可以照平常的寫法直接呼叫 print()。
class RunnerDemo extends StatefulWidget {
  const RunnerDemo({super.key, required this.run});

  final FutureOr<void> Function() run;

  @override
  State<RunnerDemo> createState() => _RunnerDemoState();
}

class _RunnerDemoState extends State<RunnerDemo> {
  final _lines = <String>[];
  var _running = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _log(String line) {
    if (mounted) setState(() => _lines.add(line));
  }

  Future<void> _run() async {
    setState(() {
      _lines.clear();
      _running = true;
    });
    try {
      await runZoned(
        () async => await widget.run(),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => _log(line),
        ),
      );
    } catch (e) {
      _log('未捕捉的例外：$e');
    }
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Text('輸出', style: theme.textTheme.titleSmall),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _running ? null : _run,
                icon: const Icon(Icons.play_arrow),
                label: Text(_running ? '執行中…' : '再執行一次'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: const Color(0xFF1B1F26),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final line in _lines)
                  Text(
                    line,
                    style: const TextStyle(color: Color(0xFFE3E8EF), fontSize: 13, height: 1.5),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
