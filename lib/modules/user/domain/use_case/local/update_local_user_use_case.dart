import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/user/domain/entity/entity.dart';
import 'package:flutter_starter/modules/user/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

/// Puts a user the server answered with (a profile edit, a screen that loads
/// `me`) in place of the saved one, so `AuthBloc` and every screen show it.
/// Only for the person who signed in: a reply about anyone else is ignored.
@injectable
class UpdateLocalUserUseCase extends UseCase<void, UserEntity> {
  UpdateLocalUserUseCase(this._local);

  final LocalUserRepository _local;

  @override
  Future<void> execute(UserEntity params) async {
    final signedIn = _local.user;
    if (params.id == null || (signedIn != null && signedIn.id != params.id)) {
      return;
    }
    await _local.saveUser(params);
  }
}
