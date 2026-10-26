# FCM

Push notifications through Firebase Cloud Messaging: the token, topics, permission, foreground and tap streams, and a background handler. With the [notifications](notifications.md) module, a bridge also shows foreground pushes (and, if you want, data-only background pushes with action buttons) as local notifications. Keep it when your backend sends pushes.

## What it provides

- `FcmService` (`utils/helper/`): `initialize(onForegroundMessage:, onMessageOpenedApp:, requestPermissionOnInit:, defaultTopics:)`, `ensureNotificationPermission(context)`, `requestPermissionIfNeeded()`, `getToken()`, `deleteToken()`, `subscribeToTopic()`, `unsubscribeFromTopic()`, `onMessage`, `onMessageOpenedApp`, `onTokenRefresh`, `getInitialMessage()`, `dispose()`, and token-sync helpers `shouldSyncToken` / `markTokenSynced` / `clearTokenSyncCache`.
- `fcmBackgroundHandler` (`utils/helper/fcm_background_handler.dart`): the background entry point `lib/main.dart` registers.
- The bridge (`utils/helper/notifications_bridge.dart`, the only file that needs the notifications module): `buildNotificationBridge()`, `fcmBackgroundDisplayHandler`, `parseFcmActions()`.
- `RemoteFcmRepository` (domain) and `RemoteFcmRepositoryImpl` (data, DI `@LazySingleton`): the same calls behind an interface, for cubits and use cases (`getIt<RemoteFcmRepository>()`).
- `FcmRemoteMessageEntity` (message id, data, title, body, sent time), `FcmPermissionStatus`.
- `FcmConstants.defaultTopics`, `FcmSecureStorage` and `FcmStorageKeys` (secure-storage keys for the sync cache and the "asked once" flag).

## Depends on

- Firebase: `flutterfire configure` done and `FIREBASE_ENABLED=true` in `.env` (read through `EnvConfig.firebaseEnabled`).
- The notifications module, for the bridge only.
- Packages: `firebase_messaging` (only here and in `lib/main.dart`); shared: `firebase_core`, `flutter_local_notifications` (with the notifications module), `flutter_secure_storage` through `SecureStorageHelper`, `permission_handler` through `NotificationPermission`.
- iOS: the Push Notifications capability (an `aps-environment` entry in a `Runner.entitlements` file) and Background Modes → Remote notifications (`UIBackgroundModes` with `remote-notification` in `ios/Runner/Info.plist`). Neither is in the starter yet. An APNs key in the Firebase console. `PERMISSION_NOTIFICATIONS=1` in `ios/Podfile` (present) for the permission prompt.
- Android: `google-services.json` from `flutterfire configure`, `POST_NOTIFICATIONS` in `android/app/src/main/AndroidManifest.xml` (present).

## Setup

1. Set up Firebase ([getting started](../getting_started.md#3-set-up-firebase-only-if-you-use-it)) and uncomment the `firebase_options.dart` import and the `options:` line in `lib/core/services/firebase_service.dart`. Then set `FIREBASE_ENABLED=true`.
2. iOS: in Xcode, Runner → Signing & Capabilities, add Push Notifications and Background Modes with Remote notifications. Upload an APNs authentication key in the Firebase console (Project settings → Cloud Messaging).
3. Optional, Android: to have pushes the OS shows land in your channel, add inside `<application>` in `AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_channel_id"
       android:value="high_priority" />
   ```
4. Ask for the permission at a moment that explains it (an onboarding step, a "Turn on notifications" tile):
   ```dart
   final granted = await FcmService.instance.ensureNotificationPermission(context);
   ```
5. Set your topics in `FcmConstants.defaultTopics` (`utils/constants/fcm_constants.dart`), or pass `defaultTopics:` to `initialize()`; an empty list subscribes to none.
6. To show data-only pushes while the app is in the background, register `fcmBackgroundDisplayHandler` instead of `fcmBackgroundHandler` in `lib/main.dart`.

The two `lib/main.dart` lines are already there:

```dart
FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
// ...
await FcmService.instance.initialize(
  onForegroundMessage: buildNotificationBridge(),
);
```

## Use

```dart
// Send the token to your backend once per user and token.
final token = await FcmService.instance.getToken();
if (token != null &&
    await FcmService.instance.shouldSyncToken(token: token, userId: userId)) {
  await api.saveFcmToken(token);
  await FcmService.instance.markTokenSynced(token: token, userId: userId);
}
FcmService.instance.onTokenRefresh.listen(api.saveFcmToken);

// Topics
await FcmService.instance.subscribeToTopic('news');

// A push the OS showed was tapped: in the background, or it started the app.
FcmService.instance.onMessageOpenedApp.listen((msg) => openFrom(msg.data));
final initial = await FcmService.instance.getInitialMessage();
if (initial != null) openFrom(initial.data);

// A local notification from the bridge was tapped.
NotificationService.instance.onTap.listen((event) => openFrom(event.payload.data));

// On logout
await FcmService.instance.deleteToken();
await FcmService.instance.clearTokenSyncCache();
```

The payload for a push with action buttons is data-only (no `notification` key). FCM data values are strings, so `actions` is a JSON string:

```json
{
  "message": {
    "token": "<fcm token>",
    "data": {
      "title": "New message",
      "body": "Alex: are you online?",
      "channel": "high_priority",
      "actions": "[{\"id\":\"reply\",\"label\":\"Reply\"},{\"id\":\"mute\",\"label\":\"Mute\",\"foreground\":false}]",
      "chat_id": "1234"
    },
    "android": { "priority": "high" }
  }
}
```

`title` and `body` are read from `notification` first, then from `data`. `channel` picks the local channel (default `default`). The whole `data` map reaches the tap handler. An action is `{id, label, destructive?, foreground?}`; one without `id` or `label` is dropped, and a malformed `actions` value means no buttons rather than no notification.

## Remove

1. Delete `lib/modules/fcm/`.
2. `lib/main.dart`: remove `import 'package:firebase_messaging/firebase_messaging.dart';`, `import 'package:flutter_starter/modules/fcm/fcm.dart';`, `FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);` and the `await FcmService.instance.initialize(...)` call, each with its `// Optional.` comment.
3. `pubspec.yaml`: remove `firebase_messaging` and its comment. Keep `firebase_core` (core's `FirebaseService`, the app_upgrade module) and `FIREBASE_ENABLED` in `.env` (Crashlytics and Analytics read it).
4. Native: undo what Setup added (the iOS capabilities, the channel `meta-data`). Keep `POST_NOTIFICATIONS` and `PERMISSION_NOTIFICATIONS=1` while the notifications module stays.
5. `dart run build_runner build` (drops `RemoteFcmRepositoryImpl` from `lib/core/di/injection.config.dart`), then `flutter analyze`.

To keep fcm without the notifications module, see that module's Remove section.

## Hidden details

- Every Firebase call no-ops when `isSupported` is false: on the web, or with `FIREBASE_ENABLED` off. It checks the flag, not whether Firebase started: turn the flag on before Firebase is set up and `initialize()` throws in `main()` (`FirebaseMessaging.instance` needs a Firebase app).
- Nothing asks for the permission at launch (`requestPermissionOnInit` is false). `ensureNotificationPermission` runs core's `NotificationPermission.ensure` (system prompt, then a settings dialog after a denial) and records `fcm.permission_prompted`. `requestPermissionIfNeeded()` asks only when the OS says "not determined" and the app never asked; calls made at the same time share one request.
- Foreground: iOS shows pushes that have a `notification` payload by itself (`setForegroundNotificationPresentationOptions`), so the bridge skips those on iOS. Android doesn't, so the bridge shows them as local notifications. Data-only pushes are shown by the bridge on both.
- On Android 8+ the channel decides whether a notification pops up: the bridge's `priority: high` doesn't, and the `default` channel only makes a sound. Send `channel: high_priority` for a banner.
- Background or killed: the OS shows `notification` payloads; on Android in FCM's own default channel unless the message sets `android.notification.channel_id` or the manifest sets `default_notification_channel_id` (Setup step 3). `fcmBackgroundHandler` only starts Firebase. Data-only pushes show nothing unless `fcmBackgroundDisplayHandler` is registered; `android.priority: "high"` lets them wake a dozing phone. iOS delivers data-only background pushes unreliably by design.
- The background handler runs in its own isolate, so it can't use `NotificationService` or anything set up in `main()`; it must stay a top-level function with `@pragma('vm:entry-point')`.
- Taps: a push the OS showed comes through `onMessageOpenedApp`, or `getInitialMessage()` when it started the app. A notification the bridge showed comes through `NotificationService.instance.onTap`, or the notifications `onLaunch` when it started the app.
- Default topics (`app_update`, `promotions`) are subscribed on every launch without waiting, and errors are swallowed (FCM retries). `RemoteFcmRepository.initialize()` defaults to no topics, unlike `FcmService.instance.initialize()`.
- firebase_messaging 17 deprecates `getToken`, `deleteToken` and `onTokenRefresh` for `register()` / `onRegistered`, which give a Firebase Installation ID instead of the registration token backends store. `FcmService` keeps the token APIs until your backend sends by installation ID.
- The sync cache (`fcm.synced_token`, `fcm.synced_user_id` in secure storage) says "skip" while both the token and the user match. `deleteToken()` doesn't clear it. If your backend drops the token at logout, call `clearTokenSyncCache()` then too, or the same user signing in again with the same token isn't re-sent.
- iOS shows action buttons only for `DarwinNotificationCategory`s registered at launch (the notifications module registers none); the push's `channel` is used as the category id. Android takes buttons per notification.
- The local notification id is derived from the FCM message id (`idResolver` overrides it), so the same message replaces rather than duplicates.
