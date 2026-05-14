import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/remote/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ResetPasswordUseCase extends UseCase<void, ResetPasswordParams> {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureOr<void> execute(ResetPasswordParams params) =>
      _repository.resetPassword(
        oldPassword: params.oldPassword,
        newPassword: params.newPassword,
      );
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
