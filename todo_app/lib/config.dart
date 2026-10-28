import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [snippet:flavor-config]
/// 編譯時決定的環境設定
abstract final class AppConfig {
  /// `flutter run --flavor dev` 的 flavor 名稱，Flutter 會自動帶入
  static const String? flavor = appFlavor;

  /// `--dart-define-from-file=config/dev.json` 傳入的值。
  /// 這些值在編譯時就寫進 App 裡，所以不能放密碼或 API 金鑰
  static const enableLogging = bool.fromEnvironment('ENABLE_LOGGING');

  static bool get isDev => flavor == 'dev';
}

/// 開發時把每次狀態變化印出來
final class LoggingObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    debugPrint('[${context.provider}] $newValue');
  }
}
// [/snippet]
