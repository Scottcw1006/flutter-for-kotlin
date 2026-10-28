// ignore_for_file: avoid_print
import 'dart:math' as math;

// [snippet:syntax-variables]
const appName = 'Todo'; // 編譯期常數

void variables() {
  final name = 'Kotlin'; // 不可重新指定，相當於 val
  var count = 0; // 可重新指定
  count += 1;
  final double price = 9.5; // 型別寫在名稱前面
  final list = [1, 2, 3]; // List<int>，內容可以修改
  list.add(4);

  print('$appName: Hello, $name! count=$count');
  print('價格 ${price * 2}，共 ${list.length} 項');
  print('型別：${name.runtimeType}');
}
// [/snippet]

// [snippet:syntax-functions]
String greet(String name, {String greeting = 'Hello', bool excited = false}) {
  final mark = excited ? '!' : '.';
  return '$greeting, $name$mark';
}

int square(int x) => x * x;

extension Shout on String {
  String shout() => '${toUpperCase()}!';
}

void functions() {
  print(greet('Kotlin'));
  print(greet('Dart', excited: true));
  print(square(4));
  print('hi'.shout());

  int add(int a, int b) => a + b; // 區域函式
  print(add(1, 2));
  print([1, 2, 3].map((it) => it * 2).toList()); // lambda 沒有隱含的 it
}
// [/snippet]

// [snippet:syntax-null]
class User {
  User(this.name, this.email);

  final String name;
  final String? email;
}

String? lookupNickname(String name) => name == 'Amy' ? 'Ami' : null;

late String token; // 相當於 lateinit

void nullSafety() {
  final user = User('Amy', null);
  final length = user.email?.length; // int?
  final email = user.email ?? '（未提供）'; // ?: 改寫成 ??
  print('length=$length, email=$email');

  final nickname = lookupNickname(user.name);
  if (nickname != null) print(nickname.length); // 區域變數會自動轉型
  print(nickname!.toUpperCase()); // !! 改寫成 !

  // user.email 是公開欄位，不會自動轉型，要先存進區域變數
  final e = user.email;
  if (e != null) print(e.length);

  token = 'abc123';
  print('token=$token');
}
// [/snippet]

// [snippet:syntax-classes]
class Point {
  const Point(this.x, this.y);

  final int x;
  final int y;

  Point copyWith({int? x, int? y}) => Point(x ?? this.x, y ?? this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point(x=$x, y=$y)';
}

(int, int) minMax(List<int> values) =>
    (values.reduce(math.min), values.reduce(math.max));

void classes() {
  final p = Point(1, 2);
  final q = p.copyWith(y: 5);
  print(p);
  print(p == Point(1, 2));
  print(q);

  final (min, max) = minMax([3, 1, 4]); // record 解構
  print('min=$min, max=$max');
}
// [/snippet]

// [snippet:syntax-sealed]
sealed class LoadState {}

class Loading extends LoadState {}

class Success extends LoadState {
  Success(this.items);

  final List<String> items;
}

class Failure extends LoadState {
  Failure(this.message);

  final String message;
}

String describe(LoadState state) => switch (state) {
      Loading() => '載入中…',
      Success(items: []) => '沒有資料',
      Success(:final items) => '共 ${items.length} 筆',
      Failure(:final message) => '錯誤：$message',
    };

void sealedClasses() {
  final states = [Loading(), Success(['a', 'b']), Success([]), Failure('逾時')];
  for (final state in states) {
    print(describe(state));
  }
}
// [/snippet]

// [snippet:syntax-collections]
void collections() {
  final todos = ['買牛奶', '寫代碼', '運動', '讀書'];
  final showDone = todos.length > 3;
  final menu = ['首頁', if (showDone) '已完成', '設定']; // collection if

  print(todos.where((t) => t.length == 2).map((t) => '[$t]').toList());
  print({for (final (i, t) in todos.indexed) i: t}); // collection for
  print(menu);
  print(todos.fold<int>(0, (sum, t) => sum + t.length));
  print([...todos, '睡覺'].length); // spread

  // where、map 是惰性的，回傳 Iterable，行為像 Sequence
  final lazy = todos.map((t) {
    print('map $t');
    return t;
  });
  print('還沒執行 map');
  print(lazy.first);
}
// [/snippet]
