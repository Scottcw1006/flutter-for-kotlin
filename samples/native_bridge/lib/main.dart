import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/battery.dart';
import 'src/messages.g.dart';
import 'src/native_view.dart';

void main() => runApp(const NativeBridgeApp());

class NativeBridgeApp extends StatelessWidget {
  const NativeBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native bridge',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: const Text('與 Android 串接')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _Section('MethodChannel', BatteryLevel()),
            _Section('EventChannel', ChargingIndicator()),
            _Section('Pigeon', DeviceInfoCard()),
            _Section('Platform view', ComposeCounter()),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.child);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            child,
          ],
        ),
      ),
    );
  }
}

class BatteryLevel extends StatefulWidget {
  const BatteryLevel({super.key});

  @override
  State<BatteryLevel> createState() => _BatteryLevelState();
}

class _BatteryLevelState extends State<BatteryLevel> {
  final _service = BatteryService();
  String _text = '尚未讀取';

  Future<void> _read() async {
    try {
      final level = await _service.getBatteryLevel();
      setState(() => _text = '電量 $level%');
    } on PlatformException catch (e) {
      // Kotlin 端的 result.error(...) 會變成 PlatformException
      setState(() => _text = '錯誤：${e.code} ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        FilledButton(onPressed: _read, child: const Text('讀取電量')),
        Text(_text),
      ],
    );
  }
}

class ChargingIndicator extends StatelessWidget {
  const ChargingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ChargingService().isCharging,
      builder: (context, snapshot) => Text(switch (snapshot.data) {
        null => '等待原生端事件…',
        true => '充電中',
        false => '未充電',
      }),
    );
  }
}

// [snippet:pigeon-api]
class DeviceInfoCard extends StatefulWidget {
  const DeviceInfoCard({super.key});

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
  // Pigeon 產生的類別，用起來就像一般的 Dart 物件
  final _api = DeviceApi();
  late final Future<DeviceInfo> _info = _api.getDeviceInfo();
  String? _hash;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        FutureBuilder(
          future: _info,
          builder: (context, snapshot) => Text(switch (snapshot) {
            // 欄位有型別，不需要轉型，也不會拼錯 key
            AsyncSnapshot(data: final info?) =>
              '${info.manufacturer} ${info.model}，API ${info.sdkInt}',
            AsyncSnapshot(error: final e?) => '錯誤：$e',
            _ => '讀取中…',
          }),
        ),
        OutlinedButton(
          onPressed: () async {
            final hash = await _api.sha256('Flutter for Kotlin');
            setState(() => _hash = hash);
          },
          child: const Text('在 Kotlin 端計算 SHA-256'),
        ),
        if (_hash != null) Text(_hash!, style: const TextStyle(fontFamily: 'monospace')),
      ],
    );
  }
}
// [/snippet]
