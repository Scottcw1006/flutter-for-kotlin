// 從 demo 原始碼中擷取 `// [snippet:id]` ... `// [/snippet]` 區塊
//（YAML 用 `# [snippet:id]` ... `# [/snippet]`），輸出成 web/snippets/<id>.<副檔名>，
// 讓網頁上顯示的代碼與實際執行、實際編譯的代碼永遠一致。
//
// 在 site/ 目錄下執行：dart run tool/extract_snippets.dart
import 'dart:io';

/// 要掃描的目錄（相對於 site/）
const sourceDirs = [
  'lib',
  '../todo_app',
  '../samples/android',
];

const extensions = {'.dart', '.kt', '.kts', '.yaml'};

final _start = RegExp(r'^\s*(?://|#) \[snippet:([\w-]+)\]\s*$');
final _end = RegExp(r'^\s*(?://|#) \[/snippet\]\s*$');

void main() {
  final out = Directory('web/snippets');
  if (out.existsSync()) out.deleteSync(recursive: true);
  out.createSync(recursive: true);

  final written = <String, String>{};
  for (final dir in sourceDirs) {
    final files = Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => !f.path.contains('/build/') && !f.path.contains('/.'))
        .where((f) => extensions.any(f.path.endsWith));
    for (final file in files) {
      final ext = extensions.firstWhere(file.path.endsWith);
      // snippet 可以巢狀：內層的行同時屬於外層，標記行本身不會出現在任何 snippet 裡
      final open = <(String, List<String>)>[];
      for (final line in file.readAsLinesSync()) {
        final m = _start.firstMatch(line);
        if (m != null) {
          open.add((m.group(1)!, <String>[]));
        } else if (open.isNotEmpty && _end.hasMatch(line)) {
          final (id, buf) = open.removeLast();
          final name = '$id$ext';
          if (written.containsKey(name)) {
            stderr.writeln('Duplicate snippet "$name" in ${file.path} and ${written[name]}');
            exit(1);
          }
          File('${out.path}/$name').writeAsStringSync('${_dedent(buf).trim()}\n');
          written[name] = file.path;
        } else {
          for (final (_, buf) in open) {
            buf.add(line);
          }
        }
      }
      if (open.isNotEmpty) {
        stderr.writeln('Unclosed snippet "${open.last.$1}" in ${file.path}');
        exit(1);
      }
    }
  }
  stdout.writeln('Extracted ${written.length} snippets to ${out.path}');
}

String _dedent(List<String> lines) {
  final indents = lines
      .where((l) => l.trim().isNotEmpty)
      .map((l) => l.length - l.trimLeft().length);
  final cut = indents.isEmpty ? 0 : indents.reduce((a, b) => a < b ? a : b);
  return lines.map((l) => l.length >= cut ? l.substring(cut) : l.trimLeft()).join('\n');
}
