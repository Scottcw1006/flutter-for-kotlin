import 'package:flutter/material.dart';

// [snippet:app-skeleton]
void main() => runApp(const SkeletonApp());

class SkeletonApp extends StatefulWidget {
  const SkeletonApp({super.key});

  @override
  State<SkeletonApp> createState() => _SkeletonAppState();
}

class _SkeletonAppState extends State<SkeletonApp> {
  var _themeMode = ThemeMode.system; // 跟隨系統，相當於 isSystemInDarkTheme()
  Color _seed = Colors.teal;

  // 從一個種子色產生整套 Material 3 配色，淺色與深色各一份
  ThemeData _theme(Brightness brightness) => ThemeData(
        colorSchemeSeed: _seed,
        brightness: brightness,
        // 網站專用：指定內附的中文字型（一般 App 不需要這一行）
        fontFamilyFallback: const ['NotoSansTCSubset'],
      );

  @override
  Widget build(BuildContext context) {
    final dark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return MaterialApp(
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App 骨架'),
          actions: [
            TextButton(
              onPressed: () => setState(
                () => _themeMode = dark ? ThemeMode.light : ThemeMode.dark,
              ),
              child: Text(dark ? '淺色' : '深色'),
            ),
          ],
        ),
        body: SeedPicker(
          seed: _seed,
          onChanged: (c) => setState(() => _seed = c),
        ),
        // Builder 提供 Scaffold「底下」的 context，才找得到 ScaffoldMessenger
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('按下了 FAB'))),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class SeedPicker extends StatelessWidget {
  const SeedPicker({super.key, required this.seed, required this.onChanged});

  final Color seed;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    // 讀取目前的主題，相當於 MaterialTheme.colorScheme / typography
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('標題文字', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Text('primary 色的文字', style: TextStyle(color: theme.colorScheme.primary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final c in [Colors.teal, Colors.indigo, Colors.pink, Colors.orange])
              ChoiceChip(
                label: const Text('種子色'),
                avatar: CircleAvatar(backgroundColor: c),
                selected: c == seed,
                onSelected: (_) => onChanged(c),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          spacing: 8,
          children: [
            FilledButton(onPressed: () {}, child: const Text('FilledButton')),
            Switch(value: true, onChanged: (_) {}),
          ],
        ),
      ],
    );
  }
}
// [/snippet]
