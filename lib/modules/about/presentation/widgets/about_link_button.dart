import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class AboutLinkButton extends StatelessWidget {
  const AboutLinkButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onTap;

  Future<void> _open(BuildContext context) async {
    try {
      await onTap();
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          type: ToastType.error,
          message: AppErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20.r),
      tooltip: tooltip,
      onPressed: () => _open(context),
    );
  }
}
