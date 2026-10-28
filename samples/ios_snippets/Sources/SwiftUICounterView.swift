import Flutter
import SwiftUI

// [snippet:platform-view]
// 工廠：Dart 端每建立一個 UiKitView，就呼叫一次 create
final class SwiftUICounterFactory: NSObject, FlutterPlatformViewFactory {
    private let events: NativeEvents

    init(events: NativeEvents) {
        self.events = events
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let title = (args as? [String: Any])?["title"] as? String ?? ""
        return SwiftUICounterView(title: title, events: events)
    }

    // 要收到 creationParams 必須指定 codec，否則 args 一律是 nil
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

// UIHostingController 把 SwiftUI 包成 UIKit 的 view，角色就像 Android 的 ComposeView
final class SwiftUICounterView: NSObject, FlutterPlatformView {
    private let host: UIHostingController<CounterCard>

    init(title: String, events: NativeEvents) {
        host = UIHostingController(rootView: CounterCard(title: title) { count in
            // 透過 Pigeon 的 FlutterApi 通知 Dart 端
            Task { try? await events.onNativeButtonClicked(count: Int64(count)) }
        })
        super.init()
    }

    func view() -> UIView { host.view }
}

struct CounterCard: View {
    let title: String
    let onClick: (Int) -> Void
    @State private var count = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Button("SwiftUI 按鈕：\(count)") {
                count += 1
                onClick(count)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.purple.opacity(0.15))
    }
}
// [/snippet]
