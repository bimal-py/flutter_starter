# Notifications

Local notifications: show one now, schedule one for later, cancel, and react to taps. It works without Firebase; the [fcm](fcm.md) module uses it to show pushes. Behind `NotificationService` sits a repository interface, so you can swap `flutter_local_notifications` for another package. Keep it when the app notifies the user on its own, or when you keep fcm's bridge.

## What it provides

- `NotificationService` (`utils/helper/`): the singleton the app calls. `initialize({provider, additionalChannels, onLaunch})`, `show(payload)`, `schedule(payload, when)`, `cancel(id)`, `cancelAll()`, `onTap` (a stream of taps), `requestPermissions()`, `permissionStatus()`.
- Entities (`domain/entity/`): `NotificationPayloadEntity` (id, title, body, data, channel, sound, priority, actions), `NotificationActionEntity`, `NotificationTapEventEntity` (the payload plus the tapped `actionId`), `NotificationChannelEntity`, `NotificationChannelsEntity` (the two default channels), `NotificationPriority`, `NotificationPermissionStatusEntity`.
- `LocalNotificationsRepository` (domain) and `LocalNotificationsRepositoryImpl` (data, on `flutter_local_notifications` and `timezone`).
- `NotificationPayloadModel` and `NotificationPayloadMapper` (DI `@lazySingleton`): the JSON envelope a notification carries for its tap.
- `NotificationsStrings`: the channel names and descriptions users see in the phone's settings.

## Depends on

- Packages only this module uses: `flutter_local_notifications` (also imported by fcm's bridge), `timezone`.
- DI: `NotificationPayloadMapper` is registered by injectable, so keep `initialize()` after `configureDependencyInjection()` (as in `lib/main.dart`).
- Android, `android/app/src/main/AndroidManifest.xml` (all present): `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, and the plugin's three receivers: `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` (scheduled notifications, kept across reboots and app updates) and `ActionBroadcastReceiver` (action buttons).
- Android, `android/app/build.gradle.kts`: core library desugaring is on (`isCoreLibraryDesugaringEnabled` plus `desugar_jdk_libs`); the plugin doesn't build without it.
- iOS: no `Info.plist` key. `ios/Runner/AppDelegate.swift` sets the notification-center delegate (present), so banners show while the app is open and taps arrive. The `PERMISSION_NOTIFICATIONS=1` macro in `ios/Podfile` (present) is for the permission prompt in core.
- The OS permission is asked through core's `NotificationPermission.ensure(context)` ([permissions](../core/permissions.md)).

## Setup

The native setup the plugin asks for is already in the template (Depends on). What's left:

1. Status-bar icon: notifications use `@mipmap/ic_launcher`. For a proper monochrome icon, add `android/app/src/main/res/drawable/ic_notification.png` and pass `'ic_notification'` to `AndroidInitializationSettings` in `LocalNotificationsRepositoryImpl.initialize` (and in `fcmBackgroundDisplayHandler` if you use it). Keep it out of resource shrinking (`res/raw/keep.xml`, see the plugin README).
2. Ask for the permission when it makes sense (an onboarding step, the first reminder the user turns on): `await NotificationPermission.ensure(context);`.
3. To handle the tap that launched the app, pass `onLaunch:` to the `NotificationService.instance.initialize()` call in `lib/main.dart`.

## Use

```dart
await NotificationService.instance.show(
  const NotificationPayloadEntity(
    id: 42,
    title: 'Reminder',
    body: 'Your meeting starts in 10 minutes',
    channel: NotificationChannelsEntity.highPriorityChannelId,
    priority: NotificationPriority.high,
    data: {'meetingId': '7'},
  ),
);

await NotificationService.instance.schedule(
  const NotificationPayloadEntity(id: 43, title: 'Stand-up', body: 'In 5 minutes'),
  DateTime.now().add(const Duration(hours: 1)),
);

await NotificationService.instance.cancel(43);

// Taps while the app runs (in front or in the background).
NotificationService.instance.onTap.listen((event) {
  final meetingId = event.payload.data['meetingId'];
  // event.actionId is set when an action button was tapped
});
```

Channels of your own, and the launch tap, in `lib/main.dart`:

```dart
await NotificationService.instance.initialize(
  additionalChannels: const [
    NotificationChannelEntity(
      id: 'reminders',
      name: 'Reminders',
      description: 'Reminders you set',
      importance: NotificationPriority.high,
    ),
  ],
  onLaunch: (event) => pendingTap = event, // route once the router is up
);
```

Another package: implement `LocalNotificationsRepository` and pass it as `provider:`.

## Remove

1. Delete `lib/modules/notifications/`.
2. `lib/main.dart`: remove `import 'package:flutter_starter/modules/notifications/notifications.dart';` and `await NotificationService.instance.initialize();` with its `// Optional.` comment.
3. With the fcm module still there: delete `lib/modules/fcm/utils/helper/notifications_bridge.dart`, remove `export 'notifications_bridge.dart';` from `lib/modules/fcm/utils/helper/helper.dart`, and in `lib/main.dart` call `await FcmService.instance.initialize();` without `onForegroundMessage: buildNotificationBridge()` (and register `fcmBackgroundHandler` if you had switched to `fcmBackgroundDisplayHandler`). Pushes then appear only when the OS shows them: `notification` payloads in the background, and in the foreground on iOS.
4. `pubspec.yaml`: remove `flutter_local_notifications` and `timezone` (and their comment).
5. Native, `android/app/src/main/AndroidManifest.xml`: remove the three `com.dexterous.flutterlocalnotifications` receivers and `RECEIVE_BOOT_COMPLETED`. Keep `POST_NOTIFICATIONS` and `PERMISSION_NOTIFICATIONS=1` (`ios/Podfile`) while fcm is there, and the AppDelegate delegate line too (fcm uses it; without fcm it's harmless). Desugaring in `android/app/build.gradle.kts` can stay; remove it only if no other plugin needs it. Delete the status-bar icon if you added one.
6. `dart run build_runner build` (drops `NotificationPayloadMapper` from `lib/core/di/injection.config.dart`), then `flutter analyze`.

## Hidden details

- Two channels are created on Android at start-up: `default` ("General", normal importance) and `high_priority` ("High priority", max importance), plus your `additionalChannels`. A notification on an unknown channel id makes the plugin create that channel on the spot, named after its id.
- Android 8+ uses the channel's importance and sound, fixed when the channel is first created, and ignores the per-notification `priority`. Notifications on `default` don't pop up as banners; use `high_priority` for that. To change a channel's settings, give it a new id (or reinstall).
- The tap envelope is JSON with `id`, `title`, `body`, `data` and `channel` only. On a tap, `event.payload` carries those; `sound`, `priority` and `actions` come back as defaults. Put what the tap needs in `data`.
- `onTap` is a broadcast stream: a tap with nobody listening is lost. The tap that started the app never goes there; it goes to `onLaunch`, which `lib/main.dart` doesn't pass yet.
- iOS start-up asks for nothing (`requestAlertPermission: false` and the rest). Ask with `NotificationPermission.ensure(context)`; `NotificationService.instance.requestPermissions()` is the plain plugin call without the settings fallback.
- `permissionStatus()` knows only Android (`granted` / `denied`); elsewhere it returns `notDetermined`. Use `NotificationPermission.isGranted` for a real answer.
- `schedule` is inexact (`AndroidScheduleMode.inexactAllowWhileIdle`): Android may deliver a few minutes late, and no exact-alarm permission is needed. The time zone stays UTC (`tz.local` is never set): a one-off time still fires at the right moment, but repeating schedules by wall-clock time would need the device's zone.
- Android action buttons: a `foreground` action (the default) opens the app and its tap reaches `onTap` with `actionId` set; it leaves the notification up (`cancelNotification: false`), so cancel it yourself. A background action (`foreground: false`) closes the notification, but its tap goes to a background isolate this module doesn't register, so nobody hears it. On iOS, buttons need `DarwinNotificationCategory`s registered at `initialize` (none are), with `channel` as the category id; a background action there also needs `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` in `AppDelegate.swift` (see the plugin README). `destructive` isn't used.
- `largeIconUrl` on the payload isn't used by `LocalNotificationsRepositoryImpl`.
- Mobile only: `initialize()` reads `dart:io`'s `Platform`, which throws on web. Guard the call in `lib/main.dart` with `if (!kIsWeb)` if you build for the web.
- Calling `show` before `initialize()` throws a `StateError`.
