import 'package:equatable/equatable.dart';

class SocialLoginUseCaseParams extends Equatable {
  const SocialLoginUseCaseParams({this.remember = false});

  final bool remember;

  @override
  List<Object?> get props => [remember];
}
