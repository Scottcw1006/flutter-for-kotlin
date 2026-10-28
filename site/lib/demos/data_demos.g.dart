// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_demos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'address': instance.address,
};

_Address _$AddressFromJson(Map<String, dynamic> json) =>
    _Address(city: json['city'] as String);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'city': instance.city,
};
