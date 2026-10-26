import 'package:equatable/equatable.dart';

/// The signed-in person, as `users/me/` describes them.
class UserEntity extends Equatable {
  const UserEntity({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.phone,
    this.gender,
    this.joinedAt,
    this.avatar,
    this.birthday,
  });

  final String? id;
  final String? fullName;
  final String? username;
  final String? email;
  final String? phone;
  final String? gender;
  final DateTime? joinedAt;

  /// `avatar_url`.
  final String? avatar;

  /// `dob`.
  final DateTime? birthday;

  /// Up to two capitals for an avatar placeholder ("Ada Lovelace" → "AL").
  String get initials {
    final parts = (fullName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    username,
    email,
    phone,
    gender,
    joinedAt,
    avatar,
    birthday,
  ];
}
