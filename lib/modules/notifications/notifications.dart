/// Native config required for this module to work end-to-end:
/// - Android: add POST_NOTIFICATIONS permission, RECEIVE_BOOT_COMPLETED for
///   scheduled notifications, and the flutter_local_notifications `<receiver>`
///   entries from the plugin docs. Provide a small @drawable/ic_notification
///   for the status-bar icon.
/// - iOS: ensure UNUserNotificationCenter delegate is set in AppDelegate.
/// To replace the underlying package, implement [NotificationProvider] and
/// pass it to `NotificationService.instance.initialize(provider: ...)`.
library;

export 'notification_channels.dart';
export 'notification_payload.dart';
export 'notification_permissions.dart';
export 'notification_service.dart';
export 'provider/flutter_local_notifications_provider.dart';
export 'provider/notification_provider.dart';
