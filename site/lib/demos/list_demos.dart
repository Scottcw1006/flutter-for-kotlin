import 'package:flutter/material.dart';

// [snippet:lists-builder]
class ContactListDemo extends StatelessWidget {
  const ContactListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 1000,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(child: Text(String.fromCharCode(65 + index % 26))),
        title: Text('聯絡人 #$index'),
        subtitle: const Text('捲到這裡才建立'),
      ),
    );
  }
}
// [/snippet]

// [snippet:lists-grid]
const palette = [
  Color(0xFFFFCDD2),
  Color(0xFFC8E6C9),
  Color(0xFFBBDEFB),
  Color(0xFFFFF9C4),
];

class GridDemo extends StatelessWidget {
  const GridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = ['全部', '工作', '生活', '學習', '運動', '旅行'];
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            // 橫向列表會把高度撐滿成 56，用 Center 讓 chip 維持自己的高度
            itemBuilder: (context, i) => Center(
              child: ActionChip(label: Text(categories[i]), onPressed: () {}),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 30,
            itemBuilder: (context, i) => DecoratedBox(
              decoration: BoxDecoration(
                color: palette[i % palette.length],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('$i')),
            ),
          ),
        ),
      ],
    );
  }
}
// [/snippet]

// [snippet:lists-keys]
const fruits = ['蘋果', '香蕉', '櫻桃', '葡萄'];

class KeysDemo extends StatefulWidget {
  const KeysDemo({super.key});

  @override
  State<KeysDemo> createState() => _KeysDemoState();
}

class _KeysDemoState extends State<KeysDemo> {
  var _items = fruits;
  var _useKeys = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Switch(
                value: _useKeys,
                onChanged: (v) => setState(() {
                  _useKeys = v;
                  _items = fruits;
                }),
              ),
              const Text('加上 Key'),
              const Spacer(),
              TextButton(
                onPressed: _items.isEmpty
                    ? null
                    : () => setState(() => _items = _items.sublist(1)),
                child: const Text('刪除第一項'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final fruit in _items)
                FruitTile(
                  key: _useKeys ? ValueKey(fruit) : null,
                  name: fruit,
                  initiallyChecked: fruit == '蘋果',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class FruitTile extends StatefulWidget {
  const FruitTile({super.key, required this.name, required this.initiallyChecked});

  final String name;
  final bool initiallyChecked;

  @override
  State<FruitTile> createState() => _FruitTileState();
}

class _FruitTileState extends State<FruitTile> {
  // 勾選狀態存在 State 裡，就像 item 裡的 remember
  late var _checked = widget.initiallyChecked;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.name),
      value: _checked,
      onChanged: (v) => setState(() => _checked = v!),
    );
  }
}
// [/snippet]
