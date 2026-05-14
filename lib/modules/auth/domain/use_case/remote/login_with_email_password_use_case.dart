import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginWithEmailPasswordUseCase
    extends UseCase<void, LoginWithEmailPasswordParams> {
  LoginWithEmailPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureOr<void> execute(LoginWithEmailPasswordParams params) =>
      _repository.loginWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
}

class LoginWithEmailPasswordParams extends Equatable {
  const LoginWithEmailPasswordParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
