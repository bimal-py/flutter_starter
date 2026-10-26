import 'package:flutter_starter/modules/notifications/domain/domain.dart';

/// Transport / persistence shape for [NotificationPayloadEntity]. Only the
/// fields that need to round-trip through the underlying plugin's `payload`
/// string live here — display-time concerns (sound, priority, actions,
/// largeIcon) are passed to the plugin directly via its native types and don't
/// belong in the JSON envelope.
class NotificationPayloadModel {
  const NotificationPayloadModel({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
    this.channel = NotificationChannelsEntity.defaultChannelId,
  });

  final int id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String channel;

  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) =>
      NotificationPayloadModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
        channel:
            json['channel'] as String? ??
            NotificationChannelsEntity.defaultChannelId,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'data': data,
    'channel': channel,
  };
}
