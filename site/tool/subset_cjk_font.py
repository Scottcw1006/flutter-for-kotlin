"""產生 demo 用的中文字型子集。

Flutter Web 遇到 Roboto 沒有的中文字時，會在執行期從網路載入備用字型，
這條路徑量出來的文字寬高不準（chip 只顯示一個字、段落下方多出空白）。
所以把 demo 實際用到的中文字從 Noto Sans TC 切出子集，打包進網站，
再由 lib/main.dart 的 fontFamilyFallback 明確指定使用。

需要 fonttools：pip install fonttools

產生子集（在 site/ 目錄下執行，原始字型從 Google Fonts 下載）：
  python3 tool/subset_cjk_font.py NotoSansTC[wght].ttf

檢查子集是否涵蓋所有用到的字（CI 會執行）：
  python3 tool/subset_cjk_font.py --check
"""

import pathlib
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

SOURCES = [pathlib.Path("lib"), pathlib.Path("../todo_app/lib")]
OUT_DIR = pathlib.Path("fonts")
# Material 3 的文字樣式只用到 400（內文）和 500（標題、按鈕）
WEIGHTS = {400: "Regular", 500: "Medium"}


def used_chars() -> set[str]:
    chars = set()
    for root in SOURCES:
        for path in root.rglob("*.dart"):
            chars.update(c for c in path.read_text(encoding="utf-8") if ord(c) > 0x7F)
    return chars


def out_path(style: str) -> pathlib.Path:
    return OUT_DIR / f"NotoSansTC-Subset-{style}.ttf"


def build(source: str) -> None:
    chars = used_chars()
    OUT_DIR.mkdir(exist_ok=True)
    for weight, style in WEIGHTS.items():
        font = instancer.instantiateVariableFont(TTFont(source), {"wght": weight})
        cmap = font.getBestCmap()
        options = subset.Options()
        options.layout_features = ["*"]
        subsetter = subset.Subsetter(options)
        subsetter.populate(unicodes=[ord(c) for c in chars if ord(c) in cmap])
        subsetter.subset(font)
        font.save(out_path(style))
        print(f"{out_path(style)}: {out_path(style).stat().st_size // 1024} KB")
    print(f"涵蓋 {len(chars)} 個非 ASCII 字元")


def check() -> None:
    chars = used_chars()
    covered = set(chr(u) for u in TTFont(out_path("Regular")).getBestCmap())
    # 子集之外、但 Roboto 本來就有的字（例如 → – …）不需要涵蓋
    missing = sorted(c for c in chars - covered if 0x2E80 <= ord(c) <= 0xFFEF)
    if missing:
        print(f"中文字型子集缺少 {len(missing)} 個字：{''.join(missing)}")
        print("請在 site/ 執行 python3 tool/subset_cjk_font.py <NotoSansTC 字型檔> 重新產生")
        sys.exit(1)
    print(f"中文字型子集涵蓋所有用到的字（{len(chars)} 個非 ASCII 字元）")


if __name__ == "__main__":
    if sys.argv[1:] == ["--check"]:
        check()
    elif len(sys.argv) == 2:
        build(sys.argv[1])
    else:
        print(__doc__)
        sys.exit(2)
