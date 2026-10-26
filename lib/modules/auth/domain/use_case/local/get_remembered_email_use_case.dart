import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

/// The email to prefill on the login form ("Remember me" was on), or null.
@injectable
class GetRememberedEmailUseCase extends UseCase<String?, NoParams> {
  GetRememberedEmailUseCase(this._local);

  final LocalAuthSessionRepository _local;

  @override
  String? execute(NoParams params) => _local.rememberedEmail();
}
