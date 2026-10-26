import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase extends UseCase<void, LogoutUseCaseParams> {
  LogoutUseCase(this._logoutHandler);

  final LogoutHandler _logoutHandler;

  @override
  Future<void> execute(LogoutUseCaseParams params) => _logoutHandler.logout(
    wasStillAuthenticated: params.wasStillAuthenticated,
  );
}

class LogoutUseCaseParams extends Equatable {
  const LogoutUseCaseParams({this.wasStillAuthenticated = true});

  final bool wasStillAuthenticated;

  @override
  List<Object?> get props => [wasStillAuthenticated];
}
