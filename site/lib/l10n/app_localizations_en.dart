// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cartTitle => 'Shopping cart';

  @override
  String itemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in your cart',
      one: '1 item in your cart',
      zero: 'Your cart is empty',
    );
    return '$_temp0';
  }

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }
}
