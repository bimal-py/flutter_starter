import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/auth/domain/entity/entity.dart';
import 'package:flutter_starter/modules/auth/domain/repository/repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RequestPasswordResetUseCase
    extends UseCase<VerificationCodeEntity, RequestPasswordResetUseCaseParams> {
  RequestPasswordResetUseCase(this._repository);

  final RemoteAuthRepository _repository;

  @override
  Future<VerificationCodeEntity> execute(
    RequestPasswordResetUseCaseParams params,
  ) => _repository.requestPasswordReset(
    email: params.email.trim().toLowerCase(),
  );
}

class RequestPasswordResetUseCaseParams extends Equatable {
  const RequestPasswordResetUseCaseParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
