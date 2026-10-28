// Pigeon 的介面定義檔：只寫型別與方法簽章，
// 執行 `dart run pigeon --input pigeons/messages.dart` 會產生 Dart 與 Kotlin 兩邊的代碼。
// 產生的 *.g.dart、*.g.kt 會一起 commit，不需要每次 build 都重新產生。
// [snippet:pigeon-def]
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/example/f4k/native_bridge/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.f4k.native_bridge'),
    dartPackageName: 'native_bridge',
  ),
)
/// 資料類別：兩邊都會產生對應的 class，欄位型別由 Pigeon 檢查
class DeviceInfo {
  DeviceInfo({required this.manufacturer, required this.model, required this.sdkInt});

  String manufacturer;
  String model;
  int sdkInt;
}

/// Flutter 呼叫原生（Kotlin 端實作）
@HostApi()
abstract class DeviceApi {
  DeviceInfo getDeviceInfo();

  /// @async：Kotlin 端拿到 callback，可以在背景執行完再回傳
  @async
  String sha256(String text);
}

/// 原生呼叫 Flutter（Dart 端實作）
@FlutterApi()
abstract class NativeEvents {
  void onNativeButtonClicked(int count);
}
// [/snippet]
