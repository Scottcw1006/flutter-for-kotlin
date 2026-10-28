import Flutter
import UIKit

// 對應 samples/native_bridge 的 MainActivity.kt。
// 實際的 App 會在這個類別加上 @main；這裡只做型別檢查，所以省略。
// [snippet:channel-register]
@objc class NativeBridgeAppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    // 引擎建立後呼叫一次，相當於 Android 的 configureFlutterEngine
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        let registrar = engineBridge.applicationRegistrar
        let messenger = registrar.messenger()

        // 1. MethodChannel：名稱與 Dart 端、Android 端都相同
        let battery = FlutterMethodChannel(name: "f4k/battery", binaryMessenger: messenger)
        let handler = BatteryMethodHandler()
        battery.setMethodCallHandler(handler.handle)

        // 2. Pigeon：產生的 DeviceApiSetup 幫你註冊所有 channel
        DeviceApiSetup.setUp(binaryMessenger: messenger, api: DeviceApiImpl())

        // 3. Platform view：Dart 端用 UiKitView 建立
        registrar.register(
            SwiftUICounterFactory(events: NativeEvents(binaryMessenger: messenger)),
            withId: "f4k/native-counter"
        )
    }
}
// [/snippet]

// [snippet:channel-method]
final class BatteryMethodHandler {
    // 在主執行緒被呼叫；result 是一個 closure，必須呼叫剛好一次
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getBatteryLevel":
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel // 0.0～1.0，模擬器上是 -1
            if level < 0 {
                result(FlutterError(code: "UNAVAILABLE", message: "無法取得電量", details: nil))
            } else {
                result(Int(level * 100))
            }
        case "setLowPowerThreshold":
            // 參數是 Dart 傳來的 Map，轉型要自己處理
            guard let args = call.arguments as? [String: Any], args["percent"] is Int else {
                result(FlutterError(code: "BAD_ARGS", message: "缺少 percent", details: nil))
                return
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
// [/snippet]
