import 'dart:convert';

/// `users/me/` → `user`.
class UserModel {
  final String? id;
  final String? fullName;
  final String? username;
  final String? email;
  final String? phone;
  final String? gender;
  final DateTime? joinedAt;
  final String? avatarUrl;
  final DateTime? dob;

  UserModel({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.phone,
    this.gender,
    this.joinedAt,
    this.avatarUrl,
    this.dob,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? gender,
    DateTime? joinedAt,
    String? avatarUrl,
    DateTime? dob,
  }) => UserModel(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    username: username ?? this.username,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    gender: gender ?? this.gender,
    joinedAt: joinedAt ?? this.joinedAt,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    dob: dob ?? this.dob,
  );

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"]?.toString(),
    fullName: json["full_name"]?.toString(),
    username: json["username"]?.toString(),
    email: json["email"]?.toString(),
    phone: json["phone"]?.toString(),
    gender: json["gender"]?.toString(),
    joinedAt: DateTime.tryParse(json["joined_at"]?.toString() ?? '')?.toLocal(),
    avatarUrl: json["avatar_url"]?.toString(),
    dob: DateTime.tryParse(json["dob"]?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "username": username,
    "email": email,
    "phone": phone,
    "gender": gender,
    "joined_at": joinedAt?.toUtc().toIso8601String(),
    "avatar_url": avatarUrl,
    "dob": dob?.toIso8601String().substring(0, 10),
  };
}
