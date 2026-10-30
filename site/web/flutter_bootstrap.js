{{flutter_js}}
{{flutter_build_config}}

// 把頁面上每個手機框裡的 [data-demo] 節點（由 site.js 產生）掛成一個獨立的 FlutterView。
// 只挑 .device 裡的節點：純程式碼範例的外框也帶有 data-demo="none"，不能掛 view。
// Dart 端透過 initialData.demoId 決定要顯示哪個 demo，見 lib/main.dart。
// MaterialApp 會把自己的 title 寫進 document.title，所以先記下原本的標題交給 Dart 端
const pageTitle = document.title;

_flutter.loader.load({
  // GitHub Pages 無法設定 COOP/COEP header，skwasm 會以單執行緒執行，demo 規模下沒有差別
  config: { suppressMultithreadingWarning: true },
  onEntrypointLoaded: async (engineInitializer) => {
    const engine = await engineInitializer.initializeEngine({ multiViewEnabled: true });
    const app = await engine.runApp();
    // 依高度由小到大加入：Flutter 3.47 的 multi-view 中，所有 view 共用的繪圖表面
    // 會沿用最後加入的 view 的尺寸，比它高的 view 下半部會被裁掉
    const hosts = [...document.querySelectorAll(".device [data-demo]")]
      .sort((a, b) => a.offsetHeight - b.offsetHeight);
    hosts.forEach((el) => {
      app.addView({ hostElement: el, initialData: { demoId: el.dataset.demo, pageTitle } });
      el.dataset.ready = "true";
    });
  },
});
