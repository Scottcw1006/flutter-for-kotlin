import 'package:flutter/material.dart';

// [snippet:ui-first-widget]
class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $name!', style: theme.textTheme.headlineSmall),
        Text(
          '歡迎來到 Flutter',
          style: TextStyle(color: theme.colorScheme.primary),
        ),
      ],
    );
  }
}

class GreetingDemo extends StatelessWidget {
  const GreetingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Greeting(name: 'Kotlin'),
    );
  }
}
// [/snippet]

// [snippet:ui-column-row]
class ContactRow extends StatelessWidget {
  const ContactRow({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          const Icon(Icons.account_circle, size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.titleMedium),
                Text(phone, style: textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.call, semanticLabel: '撥打'),
        ],
      ),
    );
  }
}

class ContactsDemo extends StatelessWidget {
  const ContactsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ContactRow(name: '王小明', phone: '0912-345-678'),
        ContactRow(name: '一個名字非常非常長的聯絡人', phone: '0987-654-321'),
      ],
    );
  }
}
// [/snippet]

// [snippet:ui-modifier]
class ModifierDemo extends StatelessWidget {
  const ModifierDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding( // .padding(16.dp)
          padding: const EdgeInsets.all(16),
          child: ClipRRect( // .clip(RoundedCornerShape(12.dp))
            borderRadius: BorderRadius.circular(12),
            child: Material( // .background(...)
              color: const Color(0xFFB2DFDB),
              child: InkWell( // .clickable { }
                onTap: () {},
                child: const Padding( // .padding(horizontal = 24.dp, ...)
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('點我看水波紋'),
                ),
              ),
            ),
          ),
        ),
        Container( // 常用組合的捷徑
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('外距在色塊外，內距在色塊內'),
        ),
      ],
    );
  }
}
// [/snippet]

// [snippet:ui-state]
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox( // .fillMaxWidth()
      width: double.infinity,
      child: Padding( // .padding(16.dp)
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('$_count', style: Theme.of(context).textTheme.displayMedium),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _count--),
                  child: const Text('−1'),
                ),
                FilledButton(
                  onPressed: () => setState(() => _count++),
                  child: const Text('+1'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// [/snippet]
