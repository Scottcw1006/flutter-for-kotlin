import 'package:flutter/material.dart';

// [snippet:tree-rebuild]
class RebuildDemo extends StatefulWidget {
  const RebuildDemo({super.key});

  @override
  State<RebuildDemo> createState() => _RebuildDemoState();
}

class _RebuildDemoState extends State<RebuildDemo> {
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
          // 每次父層 build 都會建立一個新的 ChildProbe 物件
          ChildProbe(ticks: _ticks),
        ],
      ),
    );
  }
}

class ChildProbe extends StatefulWidget {
  const ChildProbe({super.key, required this.ticks});

  final int ticks;

  @override
  State<ChildProbe> createState() => _ChildProbeState();
}

class _ChildProbeState extends State<ChildProbe> {
  @override
  Widget build(BuildContext context) {
    final widgetId = identityHashCode(widget) % 10000;
    final stateId = identityHashCode(this) % 10000;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Widget 物件 #$widgetId（每次都不同）\nState 物件 #$stateId（一直是同一個）'),
      ),
    );
  }
}
// [/snippet]

// [snippet:tree-context]
class ContextDemo extends StatelessWidget {
  const ContextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 把底下的主題換成紫色
    return Theme(
      data: ThemeData(colorSchemeSeed: Colors.deepPurple),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // context 是 ContextDemo 自己的位置，在 Theme「外面」，所以讀到的是外層的綠色
            Swatch(
              label: '用 build() 的 context',
              color: Theme.of(context).colorScheme.primary,
            ),
            // Builder 建立一個在 Theme「裡面」的新 context，讀到的是紫色
            Builder(
              builder: (innerContext) => Swatch(
                label: '用 Builder 的 context',
                color: Theme.of(innerContext).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Swatch extends StatelessWidget {
  const Swatch({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        ),
        Text(label),
      ],
    );
  }
}
// [/snippet]

// [snippet:tree-inherited]
/// 自訂的 InheritedWidget：把 scale 提供給整棵子樹，相當於 CompositionLocal
class TextScale extends InheritedWidget {
  const TextScale({super.key, required this.scale, required super.child});

  final double scale;

  // 慣例的 of(context)：往上找最近的 TextScale，並登記「我依賴它」
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TextScale>()?.scale ?? 1;

  // 值變了，依賴它的 widget 才需要重建
  @override
  bool updateShouldNotify(TextScale oldWidget) => scale != oldWidget.scale;
}

class InheritedDemo extends StatefulWidget {
  const InheritedDemo({super.key});

  @override
  State<InheritedDemo> createState() => _InheritedDemoState();
}

class _InheritedDemoState extends State<InheritedDemo> {
  var _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return TextScale(
      scale: _scale,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Slider(
              value: _scale,
              min: 0.8,
              max: 2,
              onChanged: (v) => setState(() => _scale = v),
            ),
            // 中間隔了好幾層，ScaledLabel 仍然拿得到 scale
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ScaledLabel('不用一層層傳參數'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaledLabel extends StatelessWidget {
  const ScaledLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 14 * TextScale.of(context)));
  }
}
// [/snippet]

// [snippet:tree-lifecycle]
class LifecycleProbe extends StatefulWidget {
  const LifecycleProbe({super.key, required this.label, required this.onEvent});

  final int label;
  final void Function(String event) onEvent;

  @override
  State<LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<LifecycleProbe> {
  @override
  void initState() {
    super.initState();
    widget.onEvent('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onEvent('didChangeDependencies');
  }

  @override
  void didUpdateWidget(LifecycleProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.onEvent('didUpdateWidget：${oldWidget.label} → ${widget.label}');
  }

  @override
  void dispose() {
    widget.onEvent('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onEvent('build');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('子元件，參數 label = ${widget.label}'),
      ),
    );
  }
}
// [/snippet]

/// 生命週期 demo 的外框：控制子元件的顯示與參數，並把事件列在下方
class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  final _log = ValueNotifier<List<String>>([]);
  var _visible = true;
  var _label = 1;

  // 事件可能在 build 或 dispose 途中發生，等這一幀結束再更新清單
  void _record(String event) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _log.value = [..._log.value, event];
    });
  }

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => setState(() => _visible = !_visible),
                child: Text(_visible ? '移除子元件' : '加回子元件'),
              ),
              FilledButton.tonal(
                onPressed: _visible ? () => setState(() => _label++) : null,
                child: const Text('改變參數'),
              ),
            ],
          ),
          if (_visible) LifecycleProbe(label: _label, onEvent: _record),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFF1B1F26),
              child: ValueListenableBuilder(
                valueListenable: _log,
                builder: (context, log, _) => ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    for (final e in log.reversed)
                      Text(e, style: const TextStyle(color: Color(0xFFE3E8EF), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// [snippet:tree-method]
// 不建議：用方法回傳 Widget
class ProfileWithMethod extends StatelessWidget {
  const ProfileWithMethod({super.key, required this.name});

  final String name;

  Widget _buildHeader(BuildContext context) {
    // 這裡的 context 是 ProfileWithMethod 的，沒有自己的位置
    return Text(name, style: Theme.of(context).textTheme.titleLarge);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(context), const Divider()]);
  }
}
// [/snippet]

// [snippet:tree-widget]
// 建議：拆成獨立的 Widget 類別
class ProfileWithWidget extends StatelessWidget {
  const ProfileWithWidget({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(children: [ProfileHeader(name: name), const Divider()]);
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // 有自己的 Element 與 context，可以單獨重建，也可以加 const
    return Text(name, style: Theme.of(context).textTheme.titleLarge);
  }
}
// [/snippet]
