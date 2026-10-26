import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/user/domain/entity/entity.dart';
import 'package:flutter_starter/modules/user/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

/// The signed-in person as the phone last saved them, or null.
@injectable
class GetSavedUserUseCase extends UseCase<UserEntity?, NoParams> {
  GetSavedUserUseCase(this._local);

  final LocalUserRepository _local;

  @override
  UserEntity? execute(NoParams params) => _local.user;
}
