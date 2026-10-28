// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// [snippet:async-future]
Future<String> fetchUser(int id) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return 'User#$id';
}

Future<void> futures() async {
  print('開始');
  final user = await fetchUser(1);
  print('取得 $user');

  final users = await Future.wait([2, 3, 4].map(fetchUser));
  print('並行取得 $users');

  // 沒有 await：Future 已經開始跑了，只是不等它，像 launch { }
  fetchUser(5).then((u) => print('稍後取得 $u'));
  print('futures() 結束');
}
// [/snippet]

// [snippet:async-errors]
Future<String> mayFail(bool ok) async {
  await Future.delayed(const Duration(milliseconds: 200));
  if (!ok) throw StateError('伺服器錯誤');
  print('mayFail($ok) 跑完了');
  return '成功';
}

Future<void> errors() async {
  try {
    print(await mayFail(true));
    print(await mayFail(false));
  } on StateError catch (e) {
    print('捕捉到：${e.message}');
  }

  try {
    await mayFail(true).timeout(const Duration(milliseconds: 100));
  } on TimeoutException {
    print('逾時了，不再等待結果');
  }
}
// [/snippet]

// [snippet:async-stream]
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 1; i--) {
    yield i;
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

Future<void> streams() async {
  final texts = countdown(5).where((i) => i.isOdd).map((i) => '倒數 $i');
  await for (final text in texts) {
    print(text);
  }
  print('完成');
}
// [/snippet]

// [snippet:async-ui]
class CountdownDemo extends StatefulWidget {
  const CountdownDemo({super.key});

  @override
  State<CountdownDemo> createState() => _CountdownDemoState();
}

class _CountdownDemoState extends State<CountdownDemo> {
  // 不要在 build() 裡建立 Stream，否則每次重建都會重新開始
  var _stream = countdown(5);

  @override
  Widget build(BuildContext context) {
    return SizedBox( // .fillMaxWidth()
      width: double.infinity,
      child: Padding( // .padding(16.dp)
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<int>(
              stream: _stream,
              builder: (context, snapshot) {
                final text = switch (snapshot) {
                  AsyncSnapshot(connectionState: ConnectionState.done) => '發射！',
                  AsyncSnapshot(:final data?) => '$data',
                  _ => '準備…',
                };
                return Text(text, style: Theme.of(context).textTheme.displayMedium);
              },
            ),
            FilledButton(
              onPressed: () => setState(() => _stream = countdown(5)),
              child: const Text('重新開始'),
            ),
          ],
        ),
      ),
    );
  }
}
// [/snippet]

// [snippet:async-isolate]
int fib(int n) => n < 2 ? n : fib(n - 1) + fib(n - 2);

Future<void> heavyWork() async {
  final watch = Stopwatch()..start();
  final result = await compute(fib, 30); // 在另一個 isolate 執行
  print('fib(30) = $result，耗時 ${watch.elapsedMilliseconds} ms');
}
// [/snippet]
