import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/fcm/domain/domain.dart';
import 'package:flutter_starter/modules/fcm/utils/constants/constants.dart';
import 'package:flutter_starter/modules/fcm/utils/storage_helper/storage_helper.dart';

/// Wraps [FirebaseMessaging]. No-op when [EnvConfig.firebaseEnabled] is false
/// so the two main.dart lines stay benign while Firebase is opt-in.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FcmSecureStorage _storage = FcmSecureStorage();

  bool _initialized = false;
  Future<FcmPermissionStatus?>? _inFlightPermissionRequest;

  bool get isSupported => !kIsWeb && EnvConfig.firebaseEnabled;
  bool get isInitialized => _initialized;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;

  Future<void> initialize({
    void Function(FcmRemoteMessageEntity)? onForegroundMessage,
    void Function(FcmRemoteMessageEntity)? onMessageOpenedApp,
    bool requestPermissionOnInit = false,
    List<String> defaultTopics = FcmConstants.defaultTopics,
  }) async {
    if (!isSupported || _initialized) return;

    await _messaging.setAutoInitEnabled(true);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (onForegroundMessage != null) {
      _onMessageSub = FirebaseMessaging.onMessage.listen(
        (m) => onForegroundMessage(FcmRemoteMessageEntity.fromRemoteMessage(m)),
      );
    }
    if (onMessageOpenedApp != null) {
      _onOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => onMessageOpenedApp(FcmRemoteMessageEntity.fromRemoteMessage(m)),
      );
    }

    if (requestPermissionOnInit) {
      await requestPermissionIfNeeded();
    }

    // Subscribe last so a permission denial doesn't block delivery for users
    // who'd still receive topic-targeted data pushes.
    for (final topic in defaultTopics) {
      unawaited(_safeSubscribe(topic));
    }

    _initialized = true;
  }

  Future<void> _safeSubscribe(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (_) {
      // FCM retries on reconnect — no need to surface transient offline errors.
    }
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedAppSub?.cancel();
    _onMessageSub = null;
    _onOpenedAppSub = null;
    _initialized = false;
  }

  /// Preferred entry point for prompting notification permission once the
  /// app has UI context — runs the unified [NotificationPermission.ensure]
  /// flow (native prompt on first call, app-settings dialog on later denials).
  ///
  /// Returns `true` when notifications end up enabled at the OS level. Marks
  /// the prompt as shown, so [requestPermissionIfNeeded] won't ask again.
  Future<bool> ensureNotificationPermission(BuildContext context) async {
    if (!isSupported) return false;
    final granted = await NotificationPermission.ensure(context);
    await _storage.markPermissionPrompted();
    return granted;
  }

  /// Headless permission request — for callers without a [BuildContext]
  /// (e.g. background isolates). Prefer [ensureNotificationPermission].
  Future<FcmPermissionStatus?> requestPermissionIfNeeded() async {
    if (!isSupported) return null;

    final existing = _inFlightPermissionRequest;
    if (existing != null) return existing;

    final future = _doRequestPermission();
    _inFlightPermissionRequest = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightPermissionRequest, future)) {
        _inFlightPermissionRequest = null;
      }
    }
  }

  Future<FcmPermissionStatus?> _doRequestPermission() async {
    final current = await _messaging.getNotificationSettings();
    if (current.authorizationStatus != AuthorizationStatus.notDetermined) {
      return _mapAuthorizationStatus(current.authorizationStatus);
    }
    if (await _storage.wasPermissionPrompted()) {
      return _mapAuthorizationStatus(current.authorizationStatus);
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await _storage.markPermissionPrompted();
    return _mapAuthorizationStatus(settings.authorizationStatus);
  }

  // firebase_messaging 17 deprecates the token APIs for register() /
  // onRegistered, which hand out a Firebase Installation ID for FCM direct
  // send instead of the registration token most backends store. Keep the
  // token until the backend sends by installation ID.
  Future<String?> getToken() async {
    if (!isSupported) return null;
    // ignore: deprecated_member_use
    return _messaging.getToken();
  }

  Future<void> deleteToken() async {
    if (!isSupported) return;
    // ignore: deprecated_member_use
    await _messaging.deleteToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!isSupported) return;
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!isSupported) return;
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<bool> shouldSyncToken({
    required String token,
    required String userId,
  }) => _storage.shouldSyncToken(token: token, userId: userId);

  Future<void> markTokenSynced({
    required String token,
    required String userId,
  }) => _storage.markTokenSynced(token: token, userId: userId);

  Future<void> clearTokenSyncCache() => _storage.clearTokenSyncCache();

  Stream<FcmRemoteMessageEntity> get onMessage => isSupported
      ? FirebaseMessaging.onMessage.map(
          FcmRemoteMessageEntity.fromRemoteMessage,
        )
      : const Stream.empty();

  Stream<FcmRemoteMessageEntity> get onMessageOpenedApp => isSupported
      ? FirebaseMessaging.onMessageOpenedApp.map(
          FcmRemoteMessageEntity.fromRemoteMessage,
        )
      : const Stream.empty();

  Stream<String> get onTokenRefresh =>
      // ignore: deprecated_member_use
      isSupported ? _messaging.onTokenRefresh : const Stream.empty();

  Future<FcmRemoteMessageEntity?> getInitialMessage() async {
    if (!isSupported) return null;
    final m = await _messaging.getInitialMessage();
    return m == null ? null : FcmRemoteMessageEntity.fromRemoteMessage(m);
  }

  FcmPermissionStatus _mapAuthorizationStatus(AuthorizationStatus s) =>
      switch (s) {
        AuthorizationStatus.authorized => FcmPermissionStatus.authorized,
        AuthorizationStatus.denied ||
        AuthorizationStatus.deniedPermanently => FcmPermissionStatus.denied,
        AuthorizationStatus.provisional => FcmPermissionStatus.provisional,
        AuthorizationStatus.notDetermined => FcmPermissionStatus.notDetermined,
      };
}
