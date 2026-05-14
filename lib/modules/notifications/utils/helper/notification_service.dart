import 'package:flutter_starter/modules/notifications/domain/entity/notification_channels.dart';
import 'package:flutter_starter/modules/notifications/domain/entity/notification_payload.dart';
import 'package:flutter_starter/modules/notifications/domain/entity/notification_permissions.dart';
import 'package:flutter_starter/modules/notifications/data/repository/flutter_local_notifications_provider.dart';
import 'package:flutter_starter/modules/notifications/domain/repository/notification_provider.dart';

/// Public singleton consumers depend on. Delegates to a [NotificationProvider]
/// — default [FlutterLocalNotificationsProvider], swappable at init time.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  NotificationProvider? _provider;
  NotificationProvider get provider {
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
    NotificationProvider? provider,
    List<NotificationChannel> additionalChannels = const [],
    NotificationTapHandler? onLaunch,
  }) async {
    _provider = provider ?? FlutterLocalNotificationsProvider();
    await _provider!.initialize(
      channels: additionalChannels,
      onLaunch: onLaunch,
    );
  }

  Future<void> show(NotificationPayload payload) => provider.show(payload);

  Future<void> schedule(NotificationPayload payload, DateTime when) =>
      provider.schedule(payload, when);

  Future<void> cancel(int id) => provider.cancel(id);

  Future<void> cancelAll() => provider.cancelAll();

  Stream<NotificationTapEvent> get onTap => provider.onTap;

  Future<NotificationPermissionStatus> requestPermissions() =>
      provider.requestPermissions();

  Future<NotificationPermissionStatus> permissionStatus() =>
      provider.permissionStatus();
}
