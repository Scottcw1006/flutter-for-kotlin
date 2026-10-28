import 'package:flutter/services.dart';

// [snippet:channel-method]
class BatteryService {
  // 名稱字串必須與 Kotlin 端完全相同，打錯字只會在執行時才發現
  static const _channel = MethodChannel('f4k/battery');

  Future<int> getBatteryLevel() async {
    // 回傳型別是 dynamic，要自己轉型；Kotlin 端回傳 null 時也要處理
    final level = await _channel.invokeMethod<int>('getBatteryLevel');
    return level ?? -1;
  }

  // 參數只能是 StandardMessageCodec 支援的型別：null、bool、num、String、
  // Uint8List 等 typed data、List、Map
  Future<void> setLowPowerThreshold(int percent) =>
      _channel.invokeMethod('setLowPowerThreshold', {'percent': percent});
}
// [/snippet]

// [snippet:channel-event]
class ChargingService {
  static const _channel = EventChannel('f4k/charging');

  // 第一個 listener 訂閱時，Kotlin 端的 onListen 才會被呼叫；
  // 全部取消訂閱時呼叫 onCancel
  Stream<bool> get isCharging =>
      _channel.receiveBroadcastStream().map((event) => event as bool);
}
// [/snippet]
