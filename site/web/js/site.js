// 章節目錄：新增章節時只要改這裡，側欄與上下頁會自動更新。
// 沒有 href 的項目會顯示為「即將推出」。
const CHAPTERS = [
  {
    group: "入門",
    items: [{ href: "index.html", title: "開始之前" }],
  },
  {
    group: "1 · 架構總覽",
    items: [{ href: "architecture.html", title: "Flutter 在 Android 上怎麼運作" }],
  },
  {
    group: "2 · Dart 給 Kotlin 開發者",
    items: [
      { href: "dart-syntax.html", title: "語法對照" },
      { href: "dart-async.html", title: "非同步：Future 與 Stream" },
    ],
  },
  {
    group: "3 · UI 對照",
    items: [
      { href: "ui-basics.html", title: "從 Composable 到 Widget" },
      { href: "ui-layout.html", title: "版面配置與 constraints" },
      { href: "ui-lists.html", title: "列表" },
      { href: "ui-animation.html", title: "動畫" },
    ],
  },
  {
    group: "4 · 邏輯與架構對照",
    items: [
      { href: "state-management.html", title: "ViewModel 與狀態管理" },
      { href: "data.html", title: "網路與資料儲存" },
      { href: "navigation.html", title: "導航" },
    ],
  },
  {
    group: "5 · Flutter 獨有概念",
    items: [
      { href: "trees.html", title: "三棵樹與 BuildContext" },
      { href: "keys-const.html", title: "Key 與 const" },
    ],
  },
  {
    group: "6 · 與 Android 串接",
    items: [
      { href: "platform-channels.html", title: "Platform channel 與 Pigeon" },
      { href: "add-to-app.html", title: "Add-to-app" },
      { href: "platform-views.html", title: "嵌入原生 View" },
    ],
  },
  {
    group: "7 · iOS 相關知識",
    items: [{ href: "ios.html", title: "給 Android 開發者的 iOS 知識" }],
  },
  {
    group: "8 · 打包與發佈",
    items: [
      { href: "flavors.html", title: "Flavors 與建置設定" },
      { href: "publishing.html", title: "上架 Google Play 與 App Store" },
    ],
  },
];

const currentPage = location.pathname.split("/").pop() || "index.html";

function renderSidebar() {
  const nav = document.getElementById("sidebar");
  if (!nav) return;
  nav.innerHTML = CHAPTERS.map((g) => `
    <div class="group">
      <p class="group-title">${g.group}</p>
      ${g.items.map((it) => !it.href
        ? `<span class="soon">${it.title}<span class="badge">即將推出</span></span>`
        : `<a href="${it.href}" class="${it.href === currentPage ? "active" : ""}">${it.title}</a>`
      ).join("")}
    </div>`).join("");
}

function renderPager() {
  const pager = document.querySelector(".pager");
  if (!pager) return;
  const pages = CHAPTERS.flatMap((g) => g.items).filter((it) => it.href);
  const i = pages.findIndex((p) => p.href === currentPage);
  const prev = pages[i - 1];
  const next = pages[i + 1];
  pager.innerHTML =
    (prev ? `<a class="prev" href="${prev.href}"><small>上一章</small>${prev.title}</a>` : "<span></span>") +
    (next ? `<a class="next" href="${next.href}"><small>下一章</small>${next.title}</a>` : "<span></span>");
}

const LANGS = { dart: "dart", kt: "kotlin", kts: "kotlin", yaml: "yaml", yml: "yaml", swift: "swift", xml: "xml" };

function codePanel(label, labelClass, file) {
  const lang = LANGS[file.split(".").pop()] || "plaintext";
  return `
    <div>
      <span class="part-label ${labelClass}">${label}</span>
      <div class="code-panel">
        <div class="panel-head"><span>${file}</span><button class="copy-btn" type="button">複製</button></div>
        <pre><code class="language-${lang}" data-snippet="${file}">載入中…</code></pre>
      </div>
    </div>`;
}

// 把 <div class="example"> 展開成「左：Android/Compose 代碼 | 右：Flutter 代碼 + 實際呈現」。
//   data-id           右欄 snippet（預設 <id>.dart）與 demo 的 id
//   data-kotlin       左欄對照用的 Compose snippet id（<id>.kt），可省略
//   data-left         左欄改用指定檔名的 snippet（例如 build-gradle.kts），搭配 data-left-label
//   data-right        右欄改用指定檔名的 snippet（例如 main-activity.kt），搭配 data-right-label
//   data-demo         設為 "none" 時只顯示代碼，不放實際畫面（例如原生端代碼）
// 必須在 flutter_bootstrap.js 之前同步執行，Flutter 才找得到 [data-demo] 節點。
function renderExamples() {
  document.querySelectorAll(".example[data-id]").forEach((el) => {
    const { id, kotlin, hint, demo } = el.dataset;
    const left = el.dataset.left || (kotlin && `${kotlin}.kt`);
    const right = el.dataset.right || `${id}.dart`;
    const height = el.dataset.height || "300";
    if (!left) el.classList.add("single");
    const preview = demo === "none" ? "" : `
      <div class="preview-panel">
        <div>
          <span class="part-label">實際呈現（Flutter Web）</span>
          <div class="device">
            <div class="screen">
              <div class="demo" data-demo="${id}" style="height:${height}px"></div>
              <div class="loading">Flutter 載入中…</div>
            </div>
          </div>
        </div>
        ${hint ? `<p class="preview-hint">${hint}</p>` : ""}
      </div>`;
    el.innerHTML =
      (left ? codePanel(el.dataset.leftLabel || "Compose（Kotlin）", el.dataset.leftClass || "kotlin", left) : "") +
      codePanel(el.dataset.rightLabel || "Flutter（Dart）", el.dataset.rightClass || "dart", right) +
      preview;
  });
}

async function loadSnippets() {
  const blocks = document.querySelectorAll("code[data-snippet]");
  await Promise.all([...blocks].map(async (code) => {
    try {
      const res = await fetch(`snippets/${code.dataset.snippet}`);
      if (!res.ok) throw new Error(res.status);
      code.textContent = await res.text();
      if (window.hljs) hljs.highlightElement(code);
    } catch (e) {
      code.textContent = `// 無法載入代碼片段：${code.dataset.snippet}`;
    }
  }));
}

function setupCopyButtons() {
  document.addEventListener("click", async (e) => {
    const btn = e.target.closest(".copy-btn");
    if (!btn) return;
    const code = btn.closest(".code-panel").querySelector("code");
    try {
      await navigator.clipboard.writeText(code.textContent);
      btn.textContent = "已複製";
    } catch {
      btn.textContent = "複製失敗";
    }
    setTimeout(() => (btn.textContent = "複製"), 1500);
  });
}

function renderToc() {
  const toc = document.getElementById("toc");
  const sections = [...document.querySelectorAll(".lesson[id]")];
  if (!toc || sections.length === 0) return;
  toc.innerHTML = `<div class="title">本頁內容</div>` + sections
    .map((s) => `<a href="#${s.id}">${s.querySelector("h2").textContent}</a>`)
    .join("");
  const links = new Map([...toc.querySelectorAll("a")].map((a) => [a.hash.slice(1), a]));
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      links.forEach((a) => a.classList.remove("active"));
      links.get(entry.target.id)?.classList.add("active");
    });
  }, { rootMargin: "-80px 0px -70% 0px" });
  sections.forEach((s) => observer.observe(s));
}

function setupMenu() {
  document.querySelector(".menu-btn")?.addEventListener("click", () => {
    document.body.classList.toggle("nav-open");
  });
}

renderSidebar();
renderPager();
renderExamples();
renderToc();
setupMenu();
setupCopyButtons();
loadSnippets();
