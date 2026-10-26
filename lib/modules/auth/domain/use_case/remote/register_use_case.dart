import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

/// Creates the account with the emailed code and signs in. Returns false
/// when the account was created but signing in failed: the user then logs in.
@injectable
class RegisterUseCase extends UseCase<bool, RegisterUseCaseParams> {
  RegisterUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<bool> execute(RegisterUseCaseParams params) => _repository.register(
    email: params.email.trim().toLowerCase(),
    code: params.code.trim(),
    password: params.password,
  );
}

class RegisterUseCaseParams extends Equatable {
  const RegisterUseCaseParams({
    required this.email,
    required this.code,
    required this.password,
  });

  final String email;
  final String code;
  final String password;

  @override
  List<Object?> get props => [email, code, password];
}
