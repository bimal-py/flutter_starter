import 'package:flutter_starter/modules/notifications/domain/entity/entity.dart';

/// Plugin-agnostic notifications backend. The default app wires
/// [LocalNotificationsRepositoryImpl]; swap by implementing this interface
/// (e.g. AwesomeNotificationsRepository) and passing it to
/// `NotificationService.instance.initialize(provider: ...)`.
abstract class LocalNotificationsRepository {
  bool get isInitialized;

  Future<void> initialize({
    List<NotificationChannelEntity> channels = const [],
    NotificationTapHandlerEntity? onLaunch,
  });

  Future<void> show(NotificationPayloadEntity payload);
  Future<void> schedule(NotificationPayloadEntity payload, DateTime when);
  Future<void> cancel(int id);
  Future<void> cancelAll();

  Stream<NotificationTapEventEntity> get onTap;

  Future<NotificationPermissionStatusEntity> requestPermissions();
  Future<NotificationPermissionStatusEntity> permissionStatus();
}
