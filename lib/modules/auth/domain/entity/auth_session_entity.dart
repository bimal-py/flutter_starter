import 'package:equatable/equatable.dart';

/// Who is signed in. Tokens are kept in secure storage, not here.
class AuthSessionEntity extends Equatable {
  final String? userId;
  final String? email;

  /// "Remember me": when false the session ends with the app process.
  final bool? remember;

  const AuthSessionEntity({this.userId, this.email, this.remember});

  @override
  List<Object?> get props => [userId, email, remember];
}
