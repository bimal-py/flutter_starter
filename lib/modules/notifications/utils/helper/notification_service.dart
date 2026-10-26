import 'package:flutter_starter/modules/notifications/data/data.dart';
import 'package:flutter_starter/modules/notifications/domain/domain.dart';

/// Public singleton consumers depend on. Delegates to a [LocalNotificationsRepository]
/// — default [LocalNotificationsRepositoryImpl], swappable at init time.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  LocalNotificationsRepository? _provider;
  LocalNotificationsRepository get provider {
    final p = _provider;
    if (p == null) {
      throw StateError(
        'NotificationService.initialize() must be called before use.',
      );
    }
    return p;
  }

  bool get isInitialized => _provider?.isInitialized ?? false;

  Future<void> initialize({
    LocalNotificationsRepository? provider,
    List<NotificationChannelEntity> additionalChannels = const [],
    NotificationTapHandlerEntity? onLaunch,
  }) async {
    _provider = provider ?? LocalNotificationsRepositoryImpl();
    await _provider!.initialize(
      channels: additionalChannels,
      onLaunch: onLaunch,
    );
  }

  Future<void> show(NotificationPayloadEntity payload) =>
      provider.show(payload);

  Future<void> schedule(NotificationPayloadEntity payload, DateTime when) =>
      provider.schedule(payload, when);

  Future<void> cancel(int id) => provider.cancel(id);

  Future<void> cancelAll() => provider.cancelAll();

  Stream<NotificationTapEventEntity> get onTap => provider.onTap;

  Future<NotificationPermissionStatusEntity> requestPermissions() =>
      provider.requestPermissions();

  Future<NotificationPermissionStatusEntity> permissionStatus() =>
      provider.permissionStatus();
}
