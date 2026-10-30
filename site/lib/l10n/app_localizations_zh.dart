// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get cartTitle => '購物車';

  @override
  String itemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '購物車裡有 $count 件商品',
      zero: '購物車是空的',
    );
    return '$_temp0';
  }

  @override
  String greeting(String name) {
    return '$name，你好！';
  }
}
