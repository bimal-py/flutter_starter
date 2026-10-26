import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:flutter_starter/modules/user/user.dart';
import 'package:injectable/injectable.dart';

/// App start: returns the remembered session, or clears one that the user
/// didn't ask to keep ("Remember me" off), together with the saved user.
@injectable
class RestoreAuthSessionUseCase extends UseCase<AuthSessionEntity?, NoParams> {
  RestoreAuthSessionUseCase(this._local, this._users);

  final LocalAuthSessionRepository _local;
  final LocalUserRepository _users;

  @override
  Future<AuthSessionEntity?> execute(NoParams params) async {
    final session = await _local.getSession();
    if (session == null) {
      await _users.clear();
      return null;
    }
    final token = await _local.getRefreshToken();
    if (session.remember != true || token == null || token.isEmpty) {
      await _local.clearSession();
      await _users.clear();
      return null;
    }
    return session;
  }
}
