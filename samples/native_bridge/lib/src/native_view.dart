import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'messages.g.dart';

// [snippet:platform-view]
class ComposeCounter extends StatefulWidget {
  const ComposeCounter({super.key});

  @override
  State<ComposeCounter> createState() => _ComposeCounterState();
}

// 實作 Pigeon 產生的 NativeEvents，接收 Compose 按鈕的點擊
class _ComposeCounterState extends State<ComposeCounter> implements NativeEvents {
  var _clicks = 0;

  @override
  void initState() {
    super.initState();
    NativeEvents.setUp(this);
  }

  @override
  void dispose() {
    NativeEvents.setUp(null);
    super.dispose();
  }

  @override
  void onNativeButtonClicked(int count) => setState(() => _clicks = count);

  @override
  Widget build(BuildContext context) {
    final nativeView = switch (defaultTargetPlatform) {
      // viewType 對應原生端 registerViewFactory 的名稱
      TargetPlatform.android => const AndroidView(
        viewType: 'f4k/native-counter',
        creationParams: {'title': '這是原生的 Compose UI'},
        creationParamsCodec: StandardMessageCodec(),
      ),
      // iOS 端用 UiKitView，原生端是 SwiftUI（第 7 章）
      TargetPlatform.iOS => const UiKitView(
        viewType: 'f4k/native-counter',
        creationParams: {'title': '這是原生的 SwiftUI'},
        creationParamsCodec: StandardMessageCodec(),
      ),
      _ => const Center(child: Text('這個平台不支援')),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // 原生 View 和一般 widget 一樣受 constraints 限制，這裡給固定高度
        SizedBox(height: 140, child: nativeView),
        Text('Flutter 收到的點擊次數：$_clicks'),
      ],
    );
  }
}
// [/snippet]
