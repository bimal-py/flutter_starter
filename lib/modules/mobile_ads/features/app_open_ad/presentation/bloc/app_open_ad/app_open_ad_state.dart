part of 'app_open_ad_cubit.dart';

enum AppOpenAdStatus { initial, loading, loaded, failed, showing }

class AppOpenAdState extends Equatable {
  const AppOpenAdState({this.status = AppOpenAdStatus.initial, this.error});

  final AppOpenAdStatus status;
  final String? error;

  AppOpenAdState copyWith({AppOpenAdStatus? status, String? error}) {
    return AppOpenAdState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
