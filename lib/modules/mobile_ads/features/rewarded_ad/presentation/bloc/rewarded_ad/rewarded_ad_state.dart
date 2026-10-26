part of 'rewarded_ad_cubit.dart';

enum RewardedAdStatus { initial, loading, loaded, failed, showing }

class RewardedAdState extends Equatable {
  const RewardedAdState({this.status = RewardedAdStatus.initial, this.error});

  final RewardedAdStatus status;
  final String? error;

  RewardedAdState copyWith({RewardedAdStatus? status, String? error}) {
    return RewardedAdState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
