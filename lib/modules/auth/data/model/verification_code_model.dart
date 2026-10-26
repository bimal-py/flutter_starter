import 'dart:convert';

class VerificationCodeModel {
  final bool? alreadySent;
  final int? expiresIn;

  VerificationCodeModel({this.alreadySent, this.expiresIn});

  VerificationCodeModel copyWith({bool? alreadySent, int? expiresIn}) =>
      VerificationCodeModel(
        alreadySent: alreadySent ?? this.alreadySent,
        expiresIn: expiresIn ?? this.expiresIn,
      );

  factory VerificationCodeModel.fromRawJson(String str) =>
      VerificationCodeModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory VerificationCodeModel.fromJson(Map<String, dynamic> json) =>
      VerificationCodeModel(
        alreadySent: json["already_sent"] as bool?,
        expiresIn: (json["expires_in"] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
    "already_sent": alreadySent,
    "expires_in": expiresIn,
  };
}
