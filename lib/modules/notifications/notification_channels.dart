import 'package:flutter_starter/modules/notifications/notification_payload.dart';

class NotificationChannel {
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = NotificationPriority.normal,
    this.sound = true,
    this.showBadge = true,
  });

  final String id;
  final String name;
  final String description;
  final NotificationPriority importance;
  final bool sound;
  final bool showBadge;
}

class NotificationChannels {
  NotificationChannels._();

  static const String defaultChannelId = 'default';
  static const String highPriorityChannelId = 'high_priority';

  static const List<NotificationChannel> defaults = [
    NotificationChannel(
      id: defaultChannelId,
      name: 'General',
      description: 'General app notifications',
    ),
    NotificationChannel(
      id: highPriorityChannelId,
      name: 'High priority',
      description: 'Time-sensitive notifications',
      importance: NotificationPriority.max,
    ),
  ];
}
