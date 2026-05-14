import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginWithGoogleUseCase extends UseCase<void, NoParams> {
  LoginWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureOr<void> execute(NoParams params) => _repository.loginWithGoogle();
}
