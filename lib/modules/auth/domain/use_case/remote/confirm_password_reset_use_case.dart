import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ConfirmPasswordResetUseCase
    extends UseCase<void, ConfirmPasswordResetUseCaseParams> {
  ConfirmPasswordResetUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<void> execute(ConfirmPasswordResetUseCaseParams params) =>
      _repository.confirmPasswordReset(
        email: params.email.trim(),
        code: params.code.trim(),
        newPassword: params.newPassword,
      );
}

class ConfirmPasswordResetUseCaseParams extends Equatable {
  const ConfirmPasswordResetUseCaseParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;

  @override
  List<Object?> get props => [email, code, newPassword];
}
