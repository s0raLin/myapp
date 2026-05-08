// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  username: json['username'] as String,
  avatarURL: json['avatarURL'] as String?,
  email: json['email'] as String,
  token: json['token'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'username': instance.username,
  'avatarURL': instance.avatarURL,
  'email': instance.email,
  'token': instance.token,
};
