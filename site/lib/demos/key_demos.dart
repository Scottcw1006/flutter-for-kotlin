import 'package:flutter/material.dart';

// [snippet:keys-swap]
class SwapDemo extends StatefulWidget {
  const SwapDemo({super.key});

  @override
  State<SwapDemo> createState() => _SwapDemoState();
}

class _SwapDemoState extends State<SwapDemo> {
  var _tiles = ['A', 'B'];
  var _useKeys = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 16,
        children: [
          Row(
            children: [
              Switch(
                value: _useKeys,
                onChanged: (v) => setState(() {
                  _useKeys = v;
                  _tiles = ['A', 'B'];
                }),
              ),
              const Text('加上 Key'),
              const Spacer(),
              FilledButton(
                onPressed: () => setState(() => _tiles = _tiles.reversed.toList()),
                child: const Text('交換'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              for (final label in _tiles)
                ColorTile(key: _useKeys ? ValueKey(label) : null, label: label),
            ],
          ),
        ],
      ),
    );
  }
}

class ColorTile extends StatefulWidget {
  const ColorTile({super.key, required this.label});

  final String label;

  @override
  State<ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  // 顏色是 State 的一部分，只在建立時決定一次：A 紅色、B 藍色
  late final _color = widget.label == 'A' ? Colors.red : Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(16)),
      child: Text(
        widget.label,
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
    );
  }
}
// [/snippet]

// [snippet:const-skip]
class ConstDemo extends StatefulWidget {
  const ConstDemo({super.key});

  @override
  State<ConstDemo> createState() => _ConstDemoState();
}

class _ConstDemoState extends State<ConstDemo> {
  var _ticks = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          FilledButton(
            onPressed: () => setState(() => _ticks++),
            child: Text('重建父層（$_ticks）'),
          ),
          // 同一個 const 物件：Flutter 發現 widget 沒變，直接跳過它的 build
          const BuildCounter(label: 'const 子元件'),
          // 每次都是新物件，即使參數相同也會重建
          BuildCounter(label: '非 const 子元件'),
        ],
      ),
    );
  }
}

class BuildCounter extends StatefulWidget {
  const BuildCounter({super.key, required this.label});

  final String label;

  @override
  State<BuildCounter> createState() => _BuildCounterState();
}

class _BuildCounterState extends State<BuildCounter> {
  var _builds = 0;

  @override
  Widget build(BuildContext context) {
    _builds++;
    return Text('${widget.label}：build 了 $_builds 次');
  }
}
// [/snippet]
