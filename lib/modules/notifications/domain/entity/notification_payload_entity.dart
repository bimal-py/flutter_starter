enum NotificationPriority { min, low, normal, high, max }

/// Action button rendered inside a notification. Tapping fires a
/// [NotificationTapEventEntity] with [id] in the [actionId] field.
class NotificationActionEntity {
  const NotificationActionEntity({
    required this.id,
    required this.label,
    this.destructive = false,
    this.foreground = true,
  });
  final String id;
  final String label;
  final bool destructive;
  final bool foreground;
}

/// Package-agnostic payload. [LocalNotificationsRepository] implementations translate
/// this to their underlying plugin's representation.
class NotificationPayloadEntity {
  const NotificationPayloadEntity({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
    this.channel = 'default',
    this.sound = true,
    this.priority = NotificationPriority.normal,
    this.actions = const [],
    this.largeIconUrl,
  });

  final int id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String channel;
  final bool sound;
  final NotificationPriority priority;
  final List<NotificationActionEntity> actions;
  final String? largeIconUrl;
}

class NotificationTapEventEntity {
  const NotificationTapEventEntity({required this.payload, this.actionId});
  final NotificationPayloadEntity payload;
  final String? actionId;
}

typedef NotificationTapHandlerEntity = void Function(
  NotificationTapEventEntity event,
);
