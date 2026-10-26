import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangePasswordUseCase extends UseCase<void, ChangePasswordUseCaseParams> {
  ChangePasswordUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<void> execute(ChangePasswordUseCaseParams params) =>
      _repository.changePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}

class ChangePasswordUseCaseParams extends Equatable {
  const ChangePasswordUseCaseParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
