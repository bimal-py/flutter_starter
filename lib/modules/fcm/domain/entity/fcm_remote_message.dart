import 'package:firebase_messaging/firebase_messaging.dart';

/// Framework-agnostic wrapper around [RemoteMessage]. Lets bridges (e.g. the
/// notifications-glue file) consume FCM events without a transitive
/// firebase_messaging import.
class FcmRemoteMessage {
  const FcmRemoteMessage({
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

  factory FcmRemoteMessage.fromRemoteMessage(RemoteMessage m) =>
      FcmRemoteMessage(
        messageId: m.messageId,
        data: Map<String, dynamic>.from(m.data),
        title: m.notification?.title,
        body: m.notification?.body,
        sentAt: m.sentTime,
      );
}

enum FcmPermissionStatus { authorized, denied, provisional, notDetermined }
