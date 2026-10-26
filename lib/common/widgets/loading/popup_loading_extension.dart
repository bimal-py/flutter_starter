import 'package:flutter/widgets.dart';
import 'package:flutter_starter/common/widgets/loading/loading.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// Blocking loader for submit-style flows (login, save, redeem…). Drive it from
/// a `BlocListener`: show on loading, hide on success and on failure.
extension PopupLoadingExtension on BuildContext {
  void showPopupLoading({String? message}) => loaderOverlay.show(
    showOverlay: true,
    widgetBuilder: (_) => PopupLoadingCard(message: message),
  );

  void hidePopupLoading() {
    if (loaderOverlay.visible) loaderOverlay.hide();
  }
}
