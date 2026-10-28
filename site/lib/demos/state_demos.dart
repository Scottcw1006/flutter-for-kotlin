import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [snippet:state-viewmodel]
final counterProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0; // 初始狀態

  void increment() => state++;
  void reset() => state = 0;
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [CounterLabel(), CounterButtons()],
      ),
    );
  }
}

class CounterLabel extends ConsumerWidget {
  const CounterLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider); // 訂閱：值變了就重建
    return Text('$count', style: Theme.of(context).textTheme.displayMedium);
  }
}

class CounterButtons extends ConsumerWidget {
  const CounterButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => ref.read(counterProvider.notifier).reset(),
          child: const Text('歸零'),
        ),
        FilledButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('+1'),
        ),
      ],
    );
  }
}
// [/snippet]

// [snippet:state-derived]
const cities = ['台北', '新北', '桃園', '台中', '台南', '高雄', '基隆', '新竹', '嘉義', '花蓮', '台東', '宜蘭'];

final queryProvider = NotifierProvider<QueryNotifier, String>(QueryNotifier.new);

class QueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String query) => state = query;
}

// 衍生狀態：只要 queryProvider 變了，這裡就會重新計算
final filteredCitiesProvider = Provider<List<String>>((ref) {
  final query = ref.watch(queryProvider);
  return cities.where((c) => c.contains(query)).toList();
});

class CitySearch extends ConsumerWidget {
  const CitySearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(filteredCitiesProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(hintText: '搜尋城市，例如「台」'),
            onChanged: (q) => ref.read(queryProvider.notifier).change(q),
          ),
        ),
        Expanded(
          child: ListView(
            children: [for (final city in results) ListTile(title: Text(city))],
          ),
        ),
      ],
    );
  }
}
// [/snippet]

// [snippet:state-async]
final simulateErrorProvider =
    NotifierProvider<SimulateErrorNotifier, bool>(SimulateErrorNotifier.new);

class SimulateErrorNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final weatherProvider = FutureProvider<String>(
  (ref) async {
    final fail = ref.watch(simulateErrorProvider); // 開關一變就重新載入
    await Future.delayed(const Duration(seconds: 1));
    if (fail) throw Exception('連線逾時');
    return '台北 23°C，多雲';
  },
  // 關掉 Riverpod 3 預設的自動重試，讓錯誤立刻顯示
  retry: (retryCount, error) => null,
);

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SwitchListTile(
            title: const Text('模擬連線失敗'),
            value: ref.watch(simulateErrorProvider),
            onChanged: (_) => ref.read(simulateErrorProvider.notifier).toggle(),
          ),
          SizedBox(
            height: 64,
            child: Center(
              // 重新整理時 AsyncValue 會保留舊資料並把 isLoading 設為 true
              child: weather.isLoading
                  ? const CircularProgressIndicator()
                  : switch (weather) {
                      AsyncData(:final value) =>
                        Text(value, style: Theme.of(context).textTheme.titleLarge),
                      AsyncError(:final error) => Text(
                          '錯誤：$error',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      _ => const SizedBox.shrink(),
                    },
            ),
          ),
          FilledButton(
            onPressed: () => ref.invalidate(weatherProvider),
            child: const Text('重新整理'),
          ),
        ],
      ),
    );
  }
}
// [/snippet]
