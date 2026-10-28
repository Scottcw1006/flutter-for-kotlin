import 'package:flutter/material.dart';

// [snippet:anim-implicit]
class ImplicitDemo extends StatefulWidget {
  const ImplicitDemo({super.key});

  @override
  State<ImplicitDemo> createState() => _ImplicitDemoState();
}

class _ImplicitDemoState extends State<ImplicitDemo> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: _expanded ? 200 : 100,
          height: _expanded ? 120 : 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _expanded ? Colors.teal : Colors.orange,
            borderRadius: BorderRadius.circular(_expanded ? 32 : 12),
          ),
          child: Text(
            _expanded ? '點我縮小' : '點我',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
// [/snippet]

// [snippet:anim-switcher]
class SwitcherDemo extends StatefulWidget {
  const SwitcherDemo({super.key});

  @override
  State<SwitcherDemo> createState() => _SwitcherDemoState();
}

class _SwitcherDemoState extends State<SwitcherDemo> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$_count',
              key: ValueKey(_count), // 不同的 key 才會被視為新內容
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
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

// [snippet:anim-size]
class ExpandDemo extends StatefulWidget {
  const ExpandDemo({super.key});

  @override
  State<ExpandDemo> createState() => _ExpandDemoState();
}

class _ExpandDemoState extends State<ExpandDemo> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '什麼是 constraints？',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  ),
                  if (_expanded)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('父層告訴子元件可以多大，子元件在範圍內決定自己的大小，再由父層決定擺放的位置。'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// [/snippet]

// [snippet:anim-explicit]
class SpinnerDemo extends StatefulWidget {
  const SpinnerDemo({super.key});

  @override
  State<SpinnerDemo> createState() => _SpinnerDemoState();
}

class _SpinnerDemoState extends State<SpinnerDemo>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose(); // 不會自動釋放，一定要自己呼叫
    super.dispose();
  }

  void _toggle() => setState(() {
        if (_controller.isAnimating) {
          _controller.stop();
        } else {
          _controller.repeat();
        }
      });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          RotationTransition(
            turns: _controller,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          FilledButton(
            onPressed: _toggle,
            child: Text(_controller.isAnimating ? '暫停' : '繼續'),
          ),
        ],
      ),
    );
  }
}
// [/snippet]
