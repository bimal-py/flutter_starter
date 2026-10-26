import 'package:flutter_starter/modules/fcm/domain/entity/entity.dart';

abstract class RemoteFcmRepository {
  Future<void> initialize({
    void Function(FcmRemoteMessageEntity)? onForegroundMessage,
    void Function(FcmRemoteMessageEntity)? onMessageOpenedApp,
    bool requestPermissionOnInit = false,
    List<String> defaultTopics = const [],
  });

  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<FcmRemoteMessageEntity?> getInitialMessage();

  Stream<FcmRemoteMessageEntity> get onMessage;
  Stream<FcmRemoteMessageEntity> get onMessageOpenedApp;
  Stream<String> get onTokenRefresh;
}
