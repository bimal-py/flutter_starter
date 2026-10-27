import 'package:flutter/widgets.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';

/// The app's spacing scale. Use these instead of literal paddings so every
/// screen shares one gutter and one vertical rhythm; change a value here and
/// the whole app follows.
///
/// They scale with flutter_scale_kit, so they are getters, not constants.
class AppSpacing {
  AppSpacing._();

  /// Left and right inset of page content, list rows and fields.
  static double get gutter => 16.w;

  /// Wider side inset for narrow, centred content: error and empty states,
  /// dialogs.
  static double get gutterWide => 24.w;

  // Vertical rhythm: gaps between and around blocks.
  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get md => 12.h;
  static double get lg => 16.h;
  static double get xl => 24.h;

  /// The gutter on both sides, nothing above or below.
  static EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: gutter);

  /// A scrolling page's content: the gutter at the sides, [md] at the top and
  /// [xl] at the bottom so the last item clears the edge.
  static EdgeInsets get page => EdgeInsets.fromLTRB(gutter, md, gutter, xl);
}
