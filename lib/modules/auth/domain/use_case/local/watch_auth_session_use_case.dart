import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchAuthSessionUseCase
    extends StreamUseCase<AuthSessionEntity?, NoParams> {
  WatchAuthSessionUseCase(this._local);

  final LocalAuthSessionRepository _local;

  @override
  Stream<AuthSessionEntity?> execute(NoParams params) => _local.watchSession();
}
