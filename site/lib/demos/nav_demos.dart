import 'package:flutter/material.dart';

// [snippet:nav-push]
class PushDemo extends StatefulWidget {
  const PushDemo({super.key});

  @override
  State<PushDemo> createState() => _PushDemoState();
}

class _PushDemoState extends State<PushDemo> {
  var _picked = '尚未選擇';

  Future<void> _pick() async {
    // push 回傳 Future，等使用者返回時拿到結果
    final color = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const ColorPickerPage()),
    );
    if (color != null && mounted) setState(() => _picked = color);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text('選擇的顏色：$_picked'),
          FilledButton(onPressed: _pick, child: const Text('選擇顏色')),
        ],
      ),
    );
  }
}

class ColorPickerPage extends StatelessWidget {
  const ColorPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('選擇顏色')),
      body: ListView(
        children: [
          for (final color in ['紅色', '綠色', '藍色'])
            ListTile(
              title: Text(color),
              onTap: () => Navigator.of(context).pop(color), // 帶著結果返回
            ),
        ],
      ),
    );
  }
}
// [/snippet]

// [snippet:nav-tabs]
class TabsDemo extends StatefulWidget {
  const TabsDemo({super.key});

  @override
  State<TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<TabsDemo> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack 會保留每個分頁的 State，切回來時計數還在
      body: IndexedStack(
        index: _index,
        children: const [
          TabCounter(label: '首頁'),
          TabCounter(label: '搜尋'),
          TabCounter(label: '設定'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首頁'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜尋'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: '設定'),
        ],
      ),
    );
  }
}

class TabCounter extends StatefulWidget {
  const TabCounter({super.key, required this.label});

  final String label;

  @override
  State<TabCounter> createState() => _TabCounterState();
}

class _TabCounterState extends State<TabCounter> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text('${widget.label}：點了 $_count 次'),
          FilledButton(
            onPressed: () => setState(() => _count++),
            child: const Text('+1'),
          ),
        ],
      ),
    );
  }
}
// [/snippet]

// [snippet:nav-hero]
const heroColors = [Colors.red, Colors.green, Colors.blue, Colors.orange];

class HeroDemo extends StatelessWidget {
  const HeroDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 16,
        children: [
          for (var i = 0; i < heroColors.length; i++)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HeroDetailPage(index: i)),
              ),
              // 前後兩頁用同一個 tag，切換時就會在兩個位置之間飛過去
              child: Hero(
                tag: 'color-$i',
                child: CircleAvatar(radius: 28, backgroundColor: heroColors[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class HeroDetailPage extends StatelessWidget {
  const HeroDetailPage({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Hero(
          tag: 'color-$index',
          child: CircleAvatar(radius: 96, backgroundColor: heroColors[index]),
        ),
      ),
    );
  }
}
// [/snippet]
