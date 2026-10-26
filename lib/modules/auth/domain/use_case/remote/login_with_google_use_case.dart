import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:flutter_starter/modules/auth/domain/use_case/remote/remote.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginWithGoogleUseCase extends UseCase<void, SocialLoginUseCaseParams> {
  LoginWithGoogleUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<void> execute(SocialLoginUseCaseParams params) =>
      _repository.loginWithGoogle(remember: params.remember);
}
