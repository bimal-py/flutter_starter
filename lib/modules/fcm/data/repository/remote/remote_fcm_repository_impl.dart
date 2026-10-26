import 'package:flutter_starter/modules/fcm/domain/domain.dart';
import 'package:flutter_starter/modules/fcm/utils/utils.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RemoteFcmRepository)
class RemoteFcmRepositoryImpl implements RemoteFcmRepository {
  final FcmService _service = FcmService.instance;

  @override
  Future<void> initialize({
    void Function(FcmRemoteMessageEntity)? onForegroundMessage,
    void Function(FcmRemoteMessageEntity)? onMessageOpenedApp,
    bool requestPermissionOnInit = false,
    List<String> defaultTopics = const [],
  }) => _service.initialize(
    onForegroundMessage: onForegroundMessage,
    onMessageOpenedApp: onMessageOpenedApp,
    requestPermissionOnInit: requestPermissionOnInit,
    defaultTopics: defaultTopics,
  );

  @override
  Future<String?> getToken() => _service.getToken();

  @override
  Future<void> deleteToken() => _service.deleteToken();

  @override
  Future<void> subscribeToTopic(String topic) =>
      _service.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _service.unsubscribeFromTopic(topic);

  @override
  Future<FcmRemoteMessageEntity?> getInitialMessage() =>
      _service.getInitialMessage();

  @override
  Stream<FcmRemoteMessageEntity> get onMessage => _service.onMessage;

  @override
  Stream<FcmRemoteMessageEntity> get onMessageOpenedApp =>
      _service.onMessageOpenedApp;

  @override
  Stream<String> get onTokenRefresh => _service.onTokenRefresh;
}
