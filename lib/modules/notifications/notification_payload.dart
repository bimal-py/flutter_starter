enum NotificationPriority { min, low, normal, high, max }

/// Action button rendered inside a notification. Tapping fires a
/// [NotificationTapEvent] with [id] in the [actionId] field.
class NotificationAction {
  const NotificationAction({
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

/// Package-agnostic payload. [NotificationProvider] implementations translate
/// this to their underlying plugin's representation.
class NotificationPayload {
  const NotificationPayload({
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
  final List<NotificationAction> actions;
  final String? largeIconUrl;
}

class NotificationTapEvent {
  const NotificationTapEvent({required this.payload, this.actionId});
  final NotificationPayload payload;
  final String? actionId;
}

typedef NotificationTapHandler = void Function(NotificationTapEvent event);
