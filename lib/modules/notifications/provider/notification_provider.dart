import 'package:flutter_starter/modules/notifications/notification_channels.dart';
import 'package:flutter_starter/modules/notifications/notification_payload.dart';
import 'package:flutter_starter/modules/notifications/notification_permissions.dart';

/// Plugin-agnostic notifications backend. The default app wires
/// [FlutterLocalNotificationsProvider]; swap by implementing this interface
/// (e.g. AwesomeNotificationsProvider) and passing it to
/// `NotificationService.instance.initialize(provider: ...)`.
abstract class NotificationProvider {
  bool get isInitialized;

  Future<void> initialize({
    List<NotificationChannel> channels = const [],
    NotificationTapHandler? onLaunch,
  });

  Future<void> show(NotificationPayload payload);
  Future<void> schedule(NotificationPayload payload, DateTime when);
  Future<void> cancel(int id);
  Future<void> cancelAll();

  Stream<NotificationTapEvent> get onTap;

  Future<NotificationPermissionStatus> requestPermissions();
  Future<NotificationPermissionStatus> permissionStatus();
}
