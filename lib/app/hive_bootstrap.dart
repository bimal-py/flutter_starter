import 'package:flutter_starter/core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Registry of every Hive box opener across the app.
///
/// One entry per box. Each module owns its own opener (extension on
/// [HiveInterface]) and exposes it via the module's barrel; this list is the
/// only place the bootstrap layer needs to know about them.
final List<Future<dynamic> Function()> _boxOpeners = <Future<dynamic> Function()>[
  () => Hive.openAppBox(),
  // Add module box openers here, e.g.:
  // () => Hive.openReminderDataBox(),
  // () => Hive.openReminderCategoryDataBox(),
];

/// Mirror of [_boxOpeners] for "log out" / "reset app" flows.
final List<Future<dynamic> Function()> _boxClearers = <Future<dynamic> Function()>[
  () => Hive.clearAppBox(),
  // () => Hive.clearReminderDataBox(),
  // () => Hive.clearReminderCategoryDataBox(),
];

/// Composition-root extension. Lives in `lib/app/` (not `core/`) because it
/// imports from every feature module — `core/` must not depend on modules.
extension HiveBootstrapExtension on HiveInterface {
  /// Open every registered box in parallel. Call once after
  /// `Hive.initFlutter()` during app startup.
  Future<void> openAllBoxes() async {
    await Future.wait(_boxOpeners.map((open) => open()));
  }

  /// Wipe every registered box. Useful for log-out / reset-app flows.
  Future<void> clearAllBoxes() async {
    await Future.wait(_boxClearers.map((clear) => clear()));
  }
}
