# Flutter for Kotlin 開發者

給會 Kotlin、寫過 Jetpack Compose 的 Android 工程師的 Flutter 教學網站。每一節都包含**說明、Compose 與 Flutter 程式碼並排對照、Flutter 實際畫面**；畫面是同一段 Dart 程式碼編譯成 WebAssembly 後，以 Flutter Web 的 multi-view embedding 掛載在頁面上直接執行。

## 專案結構

```
site/                         # 教學網站（Flutter Web 專案）
├── lib/main.dart             # demo id → Widget 對照表；以 multi-view 掛到頁面上
├── lib/demos/*.dart          # 各章的 Flutter demo
├── tool/extract_snippets.dart# 從原始碼擷取程式碼片段到 web/snippets/
└── web/
    ├── *.html                # 各章節頁面（說明文字寫在這裡）
    ├── flutter_bootstrap.js  # 啟動 Flutter engine，替每個 [data-demo] 新增 view
    ├── css/site.css
    └── js/site.js            # 側欄目錄、範例區塊、程式碼片段載入
todo_app/                     # 實作主線：待辦清單 App（Riverpod、drift、go_router）
samples/android/              # Android 原生端範例（Gradle 專案）
└── compose-reference/        # 網頁上「Compose（Kotlin）」欄位的程式碼，CI 會編譯
samples/native_bridge/        # 第 6 章：MethodChannel、EventChannel、Pigeon、platform view
samples/add_to_app/           # 第 6 章：Android 宿主 App（android_host）＋ Flutter 模組（todo_module）
samples/ios_snippets/         # 第 7 章：Swift 版的原生串接程式碼（不是 Xcode 專案，用 typecheck.sh 做型別檢查）
samples/release/              # 第 8 章：上傳 Google Play 的 GitHub Actions 範例（不會被執行）
site/web/img/                 # 原生範例在模擬器上的截圖（無法在網頁上執行的 demo）
```

網頁上顯示的程式碼都由 `extract_snippets.dart` 從 `site/lib`、`todo_app`、`samples/` 擷取（支援 `.dart`、`.kt`、`.kts`、`.swift`，以及用 `# [snippet:id]` 標記的 `.yaml`／`.yml`、用 `<!-- [snippet:id] -->` 標記的 `.xml`），程式碼與畫面不會不同步。

## 第 6 章的原生範例

`samples/native_bridge` 與 `samples/add_to_app` 需要 Android 模擬器才能執行，網頁上改用截圖呈現：

```bash
cd samples/native_bridge && flutter run

cd samples/add_to_app/todo_module && flutter pub get
cd ../android_host && ./gradlew :app:installDebug
```

修改 Pigeon 介面（`samples/native_bridge/pigeons/messages.dart`）之後，執行 `dart run pigeon --input pigeons/messages.dart` 重新產生程式碼（包含 `samples/ios_snippets` 的 Swift 版），產生的檔案一併 commit。

第 7 章的 Swift 程式碼沒有 Xcode 專案，用 Flutter SDK 內附的 `Flutter.xcframework` 做型別檢查（需要 macOS 與 Xcode）：

```bash
flutter precache --ios
samples/ios_snippets/typecheck.sh
```

## 待辦 App 的 flavor

`todo_app` 有 dev 與 prod 兩個 flavor（第 8 章），未指定時使用 dev（`pubspec.yaml` 的 `default-flavor`）。環境設定放在 `todo_app/config/*.json`：

```bash
cd todo_app
flutter run --flavor dev --dart-define-from-file=config/dev.json
flutter build appbundle --flavor prod --dart-define-from-file=config/prod.json
```

上架用的簽章金鑰放在 `todo_app/android/key.properties`（不進版本控制）；沒有這個檔案時 release 版改用 debug 金鑰簽章。

## 本機執行

需要 Flutter SDK（`brew install --cask flutter`）。

```bash
cd site
dart run tool/extract_snippets.dart
flutter build web --wasm
python3 -m http.server 8123 -d build/web
```

開啟 <http://localhost:8123>。

編譯 Compose 對照程式碼需要 JDK 21 與 Android SDK（可直接用 Android Studio 內建的 JBR）：

```bash
cd samples/android
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew :compose-reference:compileDebugKotlin
```

## 新增一個小節

1. 在 `site/lib/demos/` 寫 Flutter demo，用標記包起來：

   ```dart
   // [snippet:my-demo]
   class MyDemo extends StatelessWidget { ... }
   // [/snippet]
   ```

2. 在 `samples/android/compose-reference` 寫對應的 Compose 程式碼，用同樣的標記（同一個 id，副檔名不同即可）。
3. 在 `site/lib/main.dart` 的 `demos` 對照表加上 `'my-demo': (_) => const MyDemo()`。
4. 在章節 HTML 中加入：

   ```html
   <div class="example" data-id="my-demo" data-kotlin="my-demo" data-height="260" data-hint="試試看：……"></div>
   ```

   - `data-kotlin` 省略時只顯示 Flutter 程式碼
   - `data-left` / `data-right` 指定其他檔名的 snippet（例如 `build-gradle.kts`、`pubspec.yaml`），搭配 `data-left-label` / `data-right-label` 改欄位標題，`data-left-class` / `data-right-class`（`kotlin`、`dart`）改標題的顏色標記
   - `data-demo="none"` 時只顯示程式碼、不放實際畫面（例如原生端程式碼）

   語言範例可以用 `RunnerDemo`（`site/lib/demos/runner.dart`）當實際呈現：它會執行一個 Dart 函式，把 `print()` 的輸出顯示成 console。

5. 新增章節頁面時，在 `site/web/js/site.js` 的 `CHAPTERS` 加上連結。

## 測試

```bash
cd todo_app && flutter test          # Notifier 單元測試與 widget 測試
cd samples/android && ./gradlew :compose-reference:testDebugUnitTest   # 對照用的 ViewModel 測試
```

Compose UI 測試（`compose-reference/src/androidTest`）需要模擬器：`./gradlew :compose-reference:connectedDebugAndroidTest`；CI 只編譯它。

## 多語系 demo

`site/lib/l10n/*.arb` 由 `flutter gen-l10n` 產生 `app_localizations*.dart`（`pubspec.yaml` 設了 `generate: true`，建置時會自動重新產生）。產生的檔案一併 commit。

## 程式碼產生

`todo_app` 與 `site` 都用到 freezed、json_serializable（`todo_app` 另外用 drift），產生的 `*.freezed.dart`、`*.g.dart` 會一併 commit，clone 下來就能直接建置。修改了這些類別之後要重新產生：

```bash
dart run build_runner build   # 或 dart run build_runner watch
```

`site/build.yaml` 限制程式碼產生只處理 `lib/`，避免它去解析 `web/snippets/` 裡擷取出來的程式碼片段。

## 中文字型子集

Flutter Web 遇到中文字時會在執行期自動下載備用字型，但這條路徑量出來的文字寬度不準（例如 chip 只顯示一個字）。所以網站把 demo 實際用到的中文字從 Noto Sans TC 切成子集（`site/fonts/`，約 95 KB × 2 個字重），再透過 `fontFamilyFallback` 明確指定。

在 demo 程式碼裡加了新的中文字之後，要重新產生子集（需要 `pip install fonttools`，原始字型從 [Google Fonts](https://github.com/google/fonts/tree/main/ofl/notosanstc) 下載）：

```bash
cd site
python3 tool/subset_cjk_font.py "NotoSansTC[wght].ttf"
```

CI 會執行 `python3 tool/subset_cjk_font.py --check`，有字沒被涵蓋時建置會失敗。

## 部署

push 到 `main` 時，GitHub Actions（`.github/workflows/deploy-pages.yml`）會編譯 Compose 對照程式碼、第 6～8 章的原生範例與待辦 App 的 release 版、跑 `todo_app` 測試、建置網站並部署到 GitHub Pages。
