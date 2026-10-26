import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendVerificationCodeUseCase
    extends UseCase<VerificationCodeEntity, SendVerificationCodeUseCaseParams> {
  SendVerificationCodeUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<VerificationCodeEntity> execute(
    SendVerificationCodeUseCaseParams params,
  ) => _repository.sendVerificationCode(
    email: params.email.trim().toLowerCase(),
  );
}

class SendVerificationCodeUseCaseParams extends Equatable {
  const SendVerificationCodeUseCaseParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
