// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'data_demos.freezed.dart';
part 'data_demos.g.dart';

// [snippet:data-json]
@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    Address? address,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

@freezed
abstract class Address with _$Address {
  const factory Address({required String city}) = _Address;

  factory Address.fromJson(Map<String, Object?> json) => _$AddressFromJson(json);
}

const raw = '{"id": 1, "name": "Leanne Graham", "email": "leanne@example.com", '
    '"phone": "1-770-736-8031", "address": {"city": "Gwenborough"}}';

void jsonDemo() {
  // 沒有對應欄位的 "phone" 會被直接忽略
  final user = User.fromJson(jsonDecode(raw) as Map<String, Object?>);
  print(user);
  print(user.address?.city);

  final renamed = user.copyWith(name: 'Leanne');
  print(renamed == user);
  print(jsonEncode(renamed.toJson()));
}
// [/snippet]

// [snippet:data-http]
class UserApi {
  UserApi(this._dio);

  final Dio _dio;

  Future<List<User>> fetchUsers() async {
    final response = await _dio.get<List<Object?>>('/users');
    return [
      for (final json in response.data!) User.fromJson(json as Map<String, Object?>),
    ];
  }
}

final dioProvider = Provider(
  (ref) => Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
);
final userApiProvider = Provider((ref) => UserApi(ref.watch(dioProvider)));
final usersProvider = FutureProvider((ref) => ref.watch(userApiProvider).fetchUsers());

class UserListDemo extends ConsumerWidget {
  const UserListDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(usersProvider)) {
      AsyncData(value: final users) => RefreshIndicator(
          onRefresh: () => ref.refresh(usersProvider.future),
          child: ListView(
            children: [
              for (final user in users)
                ListTile(
                  leading: CircleAvatar(child: Text('${user.id}')),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
            ],
          ),
        ),
      AsyncError(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('載入失敗：$error'),
              FilledButton(
                onPressed: () => ref.invalidate(usersProvider),
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
// [/snippet]

// [snippet:data-prefs]
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<bool> build() async => await _prefs.getBool('dark_mode') ?? false;

  Future<void> toggle() async {
    final value = !(state.value ?? false);
    state = AsyncData(value); // 先更新畫面
    await _prefs.setBool('dark_mode', value); // 再寫入儲存
  }
}

class SettingsDemo extends ConsumerWidget {
  const SettingsDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    return Theme(
      data: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: dark ? Brightness.dark : Brightness.light,
        fontFamilyFallback: const ['NotoSansTCSubset'],
      ),
      child: Builder(
        builder: (context) => ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: SwitchListTile(
              title: const Text('深色模式'),
              subtitle: const Text('重新整理網頁後設定仍會保留'),
              value: dark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
        ),
      ),
    );
  }
}
// [/snippet]
