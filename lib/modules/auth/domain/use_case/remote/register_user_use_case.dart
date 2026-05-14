import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterUserUseCase extends UseCase<void, RegisterUserParams> {
  RegisterUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureOr<void> execute(RegisterUserParams params) => _repository.registerUser(
    email: params.email,
    password: params.password,
    fullName: params.fullName,
    code: params.code,
    phoneNumber: params.phoneNumber,
  );
}

class RegisterUserParams extends Equatable {
  const RegisterUserParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.code = '',
    this.phoneNumber,
  });

  final String email;
  final String password;
  final String fullName;
  final String code;
  final String? phoneNumber;

  @override
  List<Object?> get props => [email, password, fullName, code, phoneNumber];
}
