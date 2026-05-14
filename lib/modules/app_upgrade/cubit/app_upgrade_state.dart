part of 'app_upgrade_cubit.dart';

enum AppUpgradeStatus { idle, checking, updateAvailable, upToDate }

extension AppUpgradeStatusX on AppUpgradeStatus {
  bool get isIdle => this == AppUpgradeStatus.idle;
  bool get isChecking => this == AppUpgradeStatus.checking;
  bool get isUpdateAvailable => this == AppUpgradeStatus.updateAvailable;
  bool get isUpToDate => this == AppUpgradeStatus.upToDate;
}

class AppUpgradeState extends Equatable {
  const AppUpgradeState({
    this.status = AppUpgradeStatus.idle,
    this.latestVersion,
    this.updateMessage,
    this.isForceUpdate = false,
  });

  final AppUpgradeStatus status;
  final String? latestVersion;
  final String? updateMessage;
  final bool isForceUpdate;

  AppUpgradeState copyWith({
    AppUpgradeStatus? status,
    String? latestVersion,
    String? updateMessage,
    bool? isForceUpdate,
  }) => AppUpgradeState(
    status: status ?? this.status,
    latestVersion: latestVersion ?? this.latestVersion,
    updateMessage: updateMessage ?? this.updateMessage,
    isForceUpdate: isForceUpdate ?? this.isForceUpdate,
  );

  @override
  List<Object?> get props => [status, latestVersion, updateMessage, isForceUpdate];
}
