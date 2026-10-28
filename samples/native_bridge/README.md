# native_bridge

第 6 章「Platform channel 與 Pigeon」與「嵌入原生 View」的範例 App：

- `MethodChannel`：讀取電量（`lib/src/battery.dart` ↔ `BatteryChannels.kt`）
- `EventChannel`：充電狀態（同上）
- Pigeon：裝置資訊與 SHA-256（`pigeons/messages.dart` → `lib/src/messages.g.dart`、`Messages.g.kt`）
- Platform view：嵌入 Compose 元件（`lib/src/native_view.dart` ↔ `ComposeCounterView.kt`）

```bash
flutter run                                       # 需要 Android 模擬器或裝置
dart run pigeon --input pigeons/messages.dart     # 修改 Pigeon 介面後重新產生
```
