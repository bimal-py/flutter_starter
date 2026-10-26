import 'package:flutter_starter/modules/user/domain/entity/entity.dart';

/// The signed-in person as last received from the server, kept on the phone
/// (the `user` key of the auth user box). `AuthBloc` follows it.
abstract class LocalUserRepository {
  UserEntity? get user;

  /// The saved user now, then every change.
  Stream<UserEntity?> watchUser();

  Future<void> saveUser(UserEntity user);

  /// Log-out: nobody is signed in.
  Future<void> clear();
}
