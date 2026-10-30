import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// [snippet:images]
class ImagesDemo extends StatefulWidget {
  const ImagesDemo({super.key});

  @override
  State<ImagesDemo> createState() => _ImagesDemoState();
}

class _ImagesDemoState extends State<ImagesDemo> {
  static const _url = 'https://raw.githubusercontent.com/Scottcw1006/flutter-for-kotlin/main/site/web/img/flavor-launcher.png';
  var _broken = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('打包在 App 裡的圖片'),
        const SizedBox(height: 8),
        // pubspec.yaml 宣告過 assets/images/，會依螢幕密度選 1x、2.0x 或 3.0x
        Image.asset('assets/images/app_icon.png', width: 48, height: 48, alignment: Alignment.centerLeft),
        const SizedBox(height: 16),
        Text(_broken ? '網路圖片（故意用錯誤的網址）' : '網路圖片'),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: Image.network(
            _broken ? '$_url-not-found' : _url,
            key: ValueKey(_broken), // 網址改變時重新載入
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            // 相當於 Coil 的 placeholder 與 error
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) =>
                const Row(spacing: 8, children: [Icon(Icons.broken_image), Text('載入失敗')]),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => setState(() => _broken = !_broken),
            child: Text(_broken ? '改回正確網址' : '改用錯誤網址'),
          ),
        ),
      ],
    );
  }
}
// [/snippet]

/// 多語系 demo 的外框：切換語系與數量
class I18nDemo extends StatefulWidget {
  const I18nDemo({super.key});

  @override
  State<I18nDemo> createState() => _I18nDemoState();
}

class _I18nDemoState extends State<I18nDemo> {
  var _locale = const Locale('zh');
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    // [snippet:i18n-app]
    return MaterialApp(
      // gen-l10n 產生的 delegate，以及 Material 元件本身的翻譯
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // 不指定時跟隨系統語系；這裡為了示範改成手動切換
      locale: _locale,
      // theme、home 等其他參數照常設定
      // [/snippet]
      theme: Theme.of(context),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'zh', label: Text('中文')),
                  ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {_locale.languageCode},
                onSelectionChanged: (s) => setState(() => _locale = Locale(s.first)),
              ),
              CartSummary(count: _count),
              Row(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _count == 0 ? null : () => setState(() => _count--),
                    child: const Text('−1'),
                  ),
                  FilledButton(onPressed: () => setState(() => _count++), child: const Text('+1')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [snippet:i18n-usage]
class CartSummary extends StatelessWidget {
  const CartSummary({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    // 相當於 stringResource(R.string.…)，依目前語系回傳對應的字串
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cartTitle, style: Theme.of(context).textTheme.titleLarge),
        Text(l10n.greeting('Kotlin 開發者')),
        // 複數規則寫在 .arb 裡，相當於 pluralStringResource
        Text(l10n.itemsInCart(count)),
      ],
    );
  }
}
// [/snippet]
