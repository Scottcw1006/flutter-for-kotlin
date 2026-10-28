import Flutter
import Observation
import SwiftUI

// 對應 samples/add_to_app/android_host：既有的 iOS App 嵌入 Flutter 模組

// [snippet:a2a-engine]
@Observable
final class HostState {
    var remaining: Int?
}

class HostAppDelegate: UIResponder, UIApplicationDelegate {
    // 預先啟動的引擎，相當於放進 FlutterEngineCache 的那一個
    let flutterEngine = FlutterEngine(name: "todo_engine")
    let state = HostState()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        flutterEngine.run() // 執行 Dart 的 main()
        // 模組用到 plugin 時還要加上：GeneratedPluginRegistrant.register(with: flutterEngine)

        let channel = FlutterMethodChannel(name: "f4k/host", binaryMessenger: flutterEngine.binaryMessenger)
        channel.setMethodCallHandler { [state] call, result in
            switch call.method {
            case "remainingChanged":
                state.remaining = call.arguments as? Int
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        return true
    }
}
// [/snippet]

// [snippet:a2a-open]
// 把 FlutterViewController 包成 SwiftUI view，相當於 Compose 的 AndroidView
struct FlutterScreen: UIViewControllerRepresentable {
    let engine: FlutterEngine

    func makeUIViewController(context: Context) -> FlutterViewController {
        FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }

    func updateUIViewController(_ controller: FlutterViewController, context: Context) {}
}

struct HostScreen: View {
    let engine: FlutterEngine
    let state: HostState
    @State private var showFlutter = false

    var body: some View {
        VStack(spacing: 16) {
            Text("這是原生的 SwiftUI 畫面").font(.title2)
            Text("Flutter 回報的剩餘待辦：\(state.remaining.map(String.init) ?? "—")")
            Button("開啟 Flutter 待辦清單") { showFlutter = true }
                .buttonStyle(.borderedProminent)
        }
        // 以 sheet 顯示，往下滑就能關閉；引擎與 Dart 狀態會保留
        .sheet(isPresented: $showFlutter) {
            FlutterScreen(engine: engine)
        }
    }
}
// [/snippet]
