import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase extends UseCase<void, LoginUseCaseParams> {
  LoginUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<void> execute(LoginUseCaseParams params) => _repository.login(
    email: params.email.trim(),
    password: params.password,
    remember: params.remember,
  );
}

class LoginUseCaseParams extends Equatable {
  const LoginUseCaseParams({
    required this.email,
    required this.password,
    this.remember = false,
  });

  final String email;
  final String password;
  final bool remember;

  @override
  List<Object?> get props => [email, password, remember];
}
