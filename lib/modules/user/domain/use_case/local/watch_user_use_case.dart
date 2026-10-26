import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/user/domain/entity/entity.dart';
import 'package:flutter_starter/modules/user/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

/// The saved user now, then every change: what `AuthBloc` follows.
@injectable
class WatchUserUseCase extends StreamUseCase<UserEntity?, NoParams> {
  WatchUserUseCase(this._local);

  final LocalUserRepository _local;

  @override
  Stream<UserEntity?> execute(NoParams params) => _local.watchUser();
}
