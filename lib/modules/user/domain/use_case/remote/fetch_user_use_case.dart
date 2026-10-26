import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/user/domain/entity/entity.dart';
import 'package:flutter_starter/modules/user/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

/// Reads the signed-in person again (`GET users/me/`) and keeps them.
/// `AuthBloc` follows the saved copy.
@injectable
class FetchUserUseCase extends UseCase<UserEntity, NoParams> {
  FetchUserUseCase(this._remote, this._local);

  final RemoteUserRepository _remote;
  final LocalUserRepository _local;

  @override
  Future<UserEntity> execute(NoParams params) async {
    final user = await _remote.fetchUser();
    await _local.saveUser(user);
    return user;
  }
}
