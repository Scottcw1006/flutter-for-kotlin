import 'package:flutter/material.dart';

// [snippet:layout-constraints]
class ConstraintsDemo extends StatefulWidget {
  const ConstraintsDemo({super.key});

  @override
  State<ConstraintsDemo> createState() => _ConstraintsDemoState();
}

class _ConstraintsDemoState extends State<ConstraintsDemo> {
  var _parent = 0;

  @override
  Widget build(BuildContext context) {
    // 想要 100 × 100 的方塊；LayoutBuilder 顯示它實際收到的 constraints
    final box = LayoutBuilder(
      builder: (context, constraints) => Container(
        width: 100,
        height: 100,
        color: Colors.teal.shade200,
        alignment: Alignment.center,
        child: Text(describe(constraints), textAlign: TextAlign.center),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('直接放')),
              ButtonSegment(value: 1, label: Text('Center')),
              ButtonSegment(value: 2, label: Text('SizedBox')),
            ],
            showSelectedIcon: false,
            selected: {_parent},
            onSelectionChanged: (s) => setState(() => _parent = s.first),
          ),
        ),
        Expanded(
          child: switch (_parent) {
            0 => box,
            1 => Center(child: box),
            _ => Center(child: SizedBox(width: 200, height: 60, child: box)),
          },
        ),
      ],
    );
  }
}

String describe(BoxConstraints c) {
  String range(double min, double max) =>
      min == max ? '${min.round()}（緊）' : '${min.round()}–${max.round()}';
  return '寬 ${range(c.minWidth, c.maxWidth)}\n高 ${range(c.minHeight, c.maxHeight)}';
}
// [/snippet]

// [snippet:layout-flex]
class FlexDemo extends StatefulWidget {
  const FlexDemo({super.key});

  @override
  State<FlexDemo> createState() => _FlexDemoState();
}

class _FlexDemoState extends State<FlexDemo> {
  var _flex = 1;

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(color: Colors.white);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('藍色 flex: $_flex，綠色 flex: 1'),
          Slider(
            value: _flex.toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            onChanged: (v) => setState(() => _flex = v.round()),
          ),
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: _flex,
                  child: const ColoredBox(
                    color: Colors.blue,
                    child: Center(child: Text('Expanded', style: label)),
                  ),
                ),
                const Expanded(
                  child: ColoredBox(
                    color: Colors.green,
                    child: Center(child: Text('Expanded', style: label)),
                  ),
                ),
                const Flexible(
                  child: ColoredBox(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      // widthFactor: 1 讓 Center 的寬度只包住文字，不撐滿
                      child: Center(widthFactor: 1, child: Text('Flexible', style: label)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// [/snippet]

// [snippet:layout-stack]
class StackDemo extends StatelessWidget {
  const StackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            radius: 48,
            child: Text('K', style: TextStyle(fontSize: 40)),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text('99+', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
// [/snippet]

// [snippet:layout-responsive]
class ResponsiveDemo extends StatefulWidget {
  const ResponsiveDemo({super.key});

  @override
  State<ResponsiveDemo> createState() => _ResponsiveDemoState();
}

class _ResponsiveDemoState extends State<ResponsiveDemo> {
  var _width = 300.0;

  @override
  Widget build(BuildContext context) {
    const labels = ['收件匣', '已排程', '已完成'];
    return Column(
      children: [
        Slider(
          value: _width,
          min: 120,
          max: 300,
          onChanged: (v) => setState(() => _width = v),
        ),
        Text('容器寬度 ${_width.round()}'),
        SizedBox(
          width: _width,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 220) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final l in labels) InfoTile(label: l)],
                );
              }
              return Row(
                children: [for (final l in labels) Expanded(child: InfoTile(label: l))],
              );
            },
          ),
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
// [/snippet]
