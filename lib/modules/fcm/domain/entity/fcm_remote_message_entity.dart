import 'package:firebase_messaging/firebase_messaging.dart';

/// The fields of a [RemoteMessage] the app reads, so callers (like the
/// notifications bridge) don't work with firebase_messaging types.
class FcmRemoteMessageEntity {
  const FcmRemoteMessageEntity({
    required this.messageId,
    required this.data,
    this.title,
    this.body,
    this.sentAt,
  });

  final String? messageId;
  final Map<String, dynamic> data;
  final String? title;
  final String? body;
  final DateTime? sentAt;

  factory FcmRemoteMessageEntity.fromRemoteMessage(RemoteMessage m) =>
      FcmRemoteMessageEntity(
        messageId: m.messageId,
        data: Map<String, dynamic>.from(m.data),
        title: m.notification?.title,
        body: m.notification?.body,
        sentAt: m.sentTime,
      );
}

enum FcmPermissionStatus { authorized, denied, provisional, notDetermined }
