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
- Android, `android/app/src/main/AndroidManifest.xml`: `POST_NOTIFICATIONS` (present). Scheduling and action buttons need more (Setup).
- Android, `android/app/build.gradle.kts`: the plugin's README asks every app to enable core library desugaring; the starter doesn't yet (Setup).
- iOS: no `Info.plist` key. The plugin's README asks for the notification-center delegate in `ios/Runner/AppDelegate.swift` (Setup). The `PERMISSION_NOTIFICATIONS=1` macro in `ios/Podfile` (present) is for the permission prompt in core.
- The OS permission is asked through core's `NotificationPermission.ensure(context)` ([permissions](../core/permissions.md)).

## Setup

1. Android desugaring, in `android/app/build.gradle.kts`:
   ```kotlin
   android {
       compileOptions {
           isCoreLibraryDesugaringEnabled = true
           // keep the existing sourceCompatibility / targetCompatibility
       }
   }
   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
   }
   ```
2. iOS: in `application(_:didFinishLaunchingWithOptions:)` of `ios/Runner/AppDelegate.swift`, before `return super.application(...)`, add `UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate`.
3. Status-bar icon: notifications use `@mipmap/ic_launcher`. For a proper monochrome icon, add `android/app/src/main/res/drawable/ic_notification.png` and pass `'ic_notification'` to `AndroidInitializationSettings` in `LocalNotificationsRepositoryImpl.initialize` (and in `fcmBackgroundDisplayHandler` if you use it). Keep it out of resource shrinking (`res/raw/keep.xml`, see the plugin README).
4. Only if you schedule: add `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` inside `<manifest>`, and inside `<application>`:
   ```xml
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
       <intent-filter>
           <action android:name="android.intent.action.BOOT_COMPLETED"/>
           <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
           <action android:name="android.intent.action.QUICKBOOT_POWERON" />
           <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
       </intent-filter>
   </receiver>
   ```
5. Only if you use action buttons: add `<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />` inside `<application>` (and read the action bullet in Hidden details).
6. Ask for the permission when it makes sense (an onboarding step, the first reminder the user turns on): `await NotificationPermission.ensure(context);`.
7. To handle the tap that launched the app, pass `onLaunch:` to the `NotificationService.instance.initialize()` call in `lib/main.dart`.

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
5. Native: remove anything you added in Setup (receivers, `RECEIVE_BOOT_COMPLETED`, the AppDelegate line, the icon, desugaring if nothing else needs it). Keep `POST_NOTIFICATIONS` and `PERMISSION_NOTIFICATIONS=1` while fcm is there.
6. `dart run build_runner build` (drops `NotificationPayloadMapper` from `lib/core/di/injection.config.dart`), then `flutter analyze`.

## Hidden details

- Two channels are created on Android at start-up: `default` ("General", normal importance) and `high_priority` ("High priority", max importance), plus your `additionalChannels`. A notification on an unknown channel id makes the plugin create that channel on the spot, named after its id.
- Android 8+ uses the channel's importance and sound, fixed when the channel is first created, and ignores the per-notification `priority`. Notifications on `default` don't pop up as banners; use `high_priority` for that. To change a channel's settings, give it a new id (or reinstall).
- The tap envelope is JSON with `id`, `title`, `body`, `data` and `channel` only. On a tap, `event.payload` carries those; `sound`, `priority` and `actions` come back as defaults. Put what the tap needs in `data`.
- `onTap` is a broadcast stream: a tap with nobody listening is lost. The tap that started the app never goes there; it goes to `onLaunch`, which `lib/main.dart` doesn't pass yet.
- iOS start-up asks for nothing (`requestAlertPermission: false` and the rest). Ask with `NotificationPermission.ensure(context)`; `NotificationService.instance.requestPermissions()` is the plain plugin call without the settings fallback.
- `permissionStatus()` knows only Android (`granted` / `denied`); elsewhere it returns `notDetermined`. Use `NotificationPermission.isGranted` for a real answer.
- `schedule` is inexact (`AndroidScheduleMode.inexactAllowWhileIdle`): Android may deliver a few minutes late, and no exact-alarm permission is needed. The time zone stays UTC (`tz.local` is never set): a one-off time still fires at the right moment, but repeating schedules by wall-clock time would need the device's zone.
- Android action buttons: the repository sets only `cancelNotification: !foreground` and leaves `showsUserInterface` false. Per the plugin, such a tap goes to a background isolate this module doesn't register, so `onTap` doesn't see it, and a `foreground` action keeps the notification up. Set `showsUserInterface: a.foreground` in `_platformDetails` if actions should open the app. `destructive` isn't used; on iOS, buttons need `DarwinNotificationCategory`s registered at `initialize` (none are), with `channel` as the category id.
- `largeIconUrl` on the payload isn't used by `LocalNotificationsRepositoryImpl`.
- Mobile only: `initialize()` reads `dart:io`'s `Platform`, which throws on web. Guard the call in `lib/main.dart` with `if (!kIsWeb)` if you build for the web.
- Calling `show` before `initialize()` throws a `StateError`.
