import 'dart:async';

import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ForgetPasswordUseCase extends UseCase<void, String> {
  ForgetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureOr<void> execute(String email) =>
      _repository.forgetPassword(email: email);
}
