import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchAuthUserUseCase extends StreamUseCase<AuthUser?, NoParams> {
  WatchAuthUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AuthUser?> execute(NoParams params) => _repository.watchUser();
}
