import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase extends UseCase<void, LogoutParams> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureOr<void> execute(LogoutParams params) =>
      _repository.logout(wasStillAuthenticated: params.wasStillAuthenticated);
}

class LogoutParams {
  const LogoutParams({this.wasStillAuthenticated = true});
  final bool wasStillAuthenticated;
}
