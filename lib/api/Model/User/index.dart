

import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class User {
  final String username;
  final String? avatarURL;
  final String email;
  String? token;

  User({
    required this.username,
    required this.avatarURL,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
