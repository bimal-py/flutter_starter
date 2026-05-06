part of 'splash_bloc.dart';

class SplashState extends Equatable {
  const SplashState({this.status = AppLoadingState.initial});

  final AppLoadingState status;

  SplashState copyWith({AppLoadingState? status}) =>
      SplashState(status: status ?? this.status);

  @override
  List<Object?> get props => [status];
}