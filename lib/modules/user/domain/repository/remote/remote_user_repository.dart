import 'package:flutter_starter/modules/user/domain/entity/entity.dart';

/// The signed-in person's account on the server.
abstract class RemoteUserRepository {
  /// `GET users/me/`.
  Future<UserEntity> fetchUser();
}
