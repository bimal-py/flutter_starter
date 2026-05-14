import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/helpers/dialog/confirmation_dialog.dart';
import 'package:flutter_starter/core/utils/helpers/dialog/dialog_type.dart';

class DialogUtils {
  const DialogUtils._();

  /// Shows a [ConfirmationDialog]. Resolves to `true` when the user confirms,
  /// `false` when they cancel or dismiss the barrier.
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    bool showCancelButton = true,
    DialogType dialogType = DialogType.info,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        showCancelButton: showCancelButton,
        dialogType: dialogType,
      ),
    );
    return result ?? false;
  }
}
