#!/bin/sh
# 用 Flutter SDK 內附的 Flutter.xcframework 對這裡的 Swift 程式碼做型別檢查。
# 不需要 Xcode 專案，但需要安裝 Xcode（使用 iOS Simulator SDK）。
# 第一次使用前執行 `flutter precache --ios` 下載 iOS 引擎。
set -eu
cd "$(dirname "$0")"
FLUTTER_ROOT="${FLUTTER_ROOT:-$(dirname "$(dirname "$(readlink -f "$(command -v flutter)")")")}"
FRAMEWORKS="$FLUTTER_ROOT/bin/cache/artifacts/engine/ios/Flutter.xcframework/ios-arm64_x86_64-simulator"
xcrun swiftc -typecheck -parse-as-library \
  -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios17.0-simulator \
  -F "$FRAMEWORKS" \
  Sources/*.swift
echo "Swift 型別檢查通過"
