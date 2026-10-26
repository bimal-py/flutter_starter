import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/app_upgrade/utils/utils.dart';

part 'app_upgrade_state.dart';

/// Decides "is an update available?" by reading Remote Config and comparing
/// against `package_info_plus`. Honours per-platform kill switches, the
/// "ignore this version" preference (bypassed by `force_update`).
class AppUpgradeCubit extends Cubit<AppUpgradeState> {
  AppUpgradeCubit() : super(const AppUpgradeState());

  final RemoteConfigService _service = RemoteConfigService.instance;
  final RemoteConfigHelper _helper = RemoteConfigHelper();

  Future<void> checkForUpdate() async {
    if (state.status == AppUpgradeStatus.checking) return;
    emit(state.copyWith(status: AppUpgradeStatus.checking));
    try {
      await _service.init();
      if (!_service.isInitialized) {
        emit(state.copyWith(status: AppUpgradeStatus.upToDate));
        return;
      }

      final platformEnabled = Platform.isIOS
          ? _service.enabledOnIos
          : _service.enabledOnAndroid;
      if (!platformEnabled) {
        emit(state.copyWith(status: AppUpgradeStatus.upToDate));
        return;
      }

      final latest = _service.latestReleasedVersion;
      final current = await _helper.currentAppVersion();
      if (latest.isEmpty || !_helper.isVersionLower(current, latest)) {
        emit(state.copyWith(status: AppUpgradeStatus.upToDate));
        return;
      }

      final forceUpdate = _service.forceUpdate;
      if (!forceUpdate) {
        final ignored = _helper.readIgnoredVersion();
        if (ignored == latest) {
          emit(state.copyWith(status: AppUpgradeStatus.upToDate));
          return;
        }
      }

      emit(
        state.copyWith(
          status: AppUpgradeStatus.updateAvailable,
          latestVersion: latest,
          updateMessage: _service.updateMessage,
          isForceUpdate: forceUpdate,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AppUpgradeStatus.upToDate));
    }
  }

  Future<void> ignoreCurrentReleasedVersion() async {
    if (state.isForceUpdate) return;
    final v = state.latestVersion;
    if (v == null || v.isEmpty) return;
    await _helper.markVersionIgnored(v);
    emit(state.copyWith(status: AppUpgradeStatus.upToDate));
  }
}
