import 'package:flutter_starter/modules/notifications/domain/entity/entity.dart';
import 'package:flutter_starter/modules/notifications/utils/constants/constants.dart';

class NotificationChannelEntity {
  const NotificationChannelEntity({
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

class NotificationChannelsEntity {
  NotificationChannelsEntity._();

  static const String defaultChannelId = 'default';
  static const String highPriorityChannelId = 'high_priority';

  static const List<NotificationChannelEntity> defaults = [
    NotificationChannelEntity(
      id: defaultChannelId,
      name: NotificationsStrings.generalChannelName,
      description: NotificationsStrings.generalChannelDescription,
    ),
    NotificationChannelEntity(
      id: highPriorityChannelId,
      name: NotificationsStrings.highPriorityChannelName,
      description: NotificationsStrings.highPriorityChannelDescription,
      importance: NotificationPriority.max,
    ),
  ];
}
