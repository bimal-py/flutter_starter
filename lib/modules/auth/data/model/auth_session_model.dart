import 'dart:convert';

class AuthSessionModel {
  final String? userId;
  final String? email;
  final bool? remember;

  AuthSessionModel({this.userId, this.email, this.remember});

  AuthSessionModel copyWith({String? userId, String? email, bool? remember}) =>
      AuthSessionModel(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        remember: remember ?? this.remember,
      );

  factory AuthSessionModel.fromRawJson(String str) =>
      AuthSessionModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        userId: json["user_id"]?.toString(),
        email: json["email"]?.toString(),
        remember: json["remember"] as bool?,
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "email": email,
    "remember": remember,
  };
}
